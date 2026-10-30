import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/domain/usecases/manage_album_usecase.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Aviso de ação concluída no painel do álbum.
enum ManageAlbumNotice { saved, activated, testing, deactivated, deleted, generated, stickerSaved, stickerDeleted }

class ManageAlbumState extends Equatable {
  final List<AlbumEventDTO> events;

  /// Evento aberto no editor (nulo = só a lista) e as figurinhas dele.
  final AlbumEventDTO? editing;
  final List<StickerDTO> stickers;

  /// Times da temporada (escolha das páginas e o escudo).
  final List<TeamDTO> teams;

  /// Competições da temporada ("Gerar do elenco" por competição).
  final List<ChampionshipDTO> championships;
  final bool loading;
  final bool busy;

  const ManageAlbumState({
    this.events = const [],
    this.editing,
    this.stickers = const [],
    this.teams = const [],
    this.championships = const [],
    this.loading = true,
    this.busy = false,
  });

  List<AlbumTeamPage> get pages => editing == null ? const [] : AlbumLayout.pages(editing!, stickers);

  /// Competições em que o time [teamId] está inscrito.
  List<ChampionshipDTO> championshipsOf(String teamId) {
    final team = teams.where((t) => t.id == teamId).firstOrNull;
    final name = team?.name ?? editing?.teamName(teamId) ?? '';
    return championships.where((c) => c.hasTeam(id: teamId, name: name)).toList();
  }

  ManageAlbumState copyWith({
    List<AlbumEventDTO>? events,
    AlbumEventDTO? Function()? editing,
    List<StickerDTO>? stickers,
    List<TeamDTO>? teams,
    List<ChampionshipDTO>? championships,
    bool? loading,
    bool? busy,
  }) {
    return ManageAlbumState(
      events: events ?? this.events,
      editing: editing != null ? editing() : this.editing,
      stickers: stickers ?? this.stickers,
      teams: teams ?? this.teams,
      championships: championships ?? this.championships,
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [events, editing, stickers, teams, championships, loading, busy];
}

class NoticeManageAlbumState extends ManageAlbumState {
  final ManageAlbumNotice notice;
  final int count;

  NoticeManageAlbumState(ManageAlbumState from, this.notice, {this.count = 0})
      : super(
          events: from.events,
          editing: from.editing,
          stickers: from.stickers,
          teams: from.teams,
          championships: from.championships,
          loading: false,
        );

  @override
  List<Object?> get props => [...super.props, notice, count];
}

class ErrorManageAlbumState extends ManageAlbumState {
  final String errorMessage;

  ErrorManageAlbumState(ManageAlbumState from, this.errorMessage)
      : super(
          events: from.events,
          editing: from.editing,
          stickers: from.stickers,
          teams: from.teams,
          championships: from.championships,
          loading: false,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Painel do admin "Álbum de figurinhas": eventos (criar, ligar/desligar,
/// apagar) e o editor do evento (times, figurinhas geradas do elenco, foto,
/// nome e ordem de cada uma).
class ManageAlbumCubit extends Cubit<ManageAlbumState> {
  final ManageAlbumUseCase manageAlbumUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final GetSeasonChampionshipsUseCase getSeasonChampionshipsUseCase;
  StreamSubscription<Either<Failure, List<AlbumEventDTO>>>? _events;
  StreamSubscription<Either<Failure, List<StickerDTO>>>? _stickers;

  ManageAlbumCubit(
    this.manageAlbumUseCase,
    this.getTeamsCacheFirstUseCase,
    this.watchTeamPlayersUseCase,
    this.getSeasonChampionshipsUseCase,
  ) : super(const ManageAlbumState());

  void watch() {
    _events?.cancel();
    _events = manageAlbumUseCase.watchEvents().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorManageAlbumState(state, failure.toString())),
        (events) {
          final editing = state.editing;
          final fresh = editing == null ? null : events.where((e) => e.id == editing.id).firstOrNull;
          emit(state.copyWith(events: events, editing: () => fresh ?? editing, loading: false));
        },
      );
    });
    _loadTeams();
    _loadChampionships();
  }

  /// Competições da temporada atual. Falha: "Gerar do elenco" usa o geral.
  Future<void> _loadChampionships() async {
    final response = await getSeasonChampionshipsUseCase(SeasonCollection.currentSeason);
    if (isClosed || response.isLeft) return;
    emit(state.copyWith(championships: response.right));
  }

  /// Times da temporada atual (todas as regiões). Falha só esvazia a escolha.
  Future<void> _loadTeams() async {
    final response = await getTeamsCacheFirstUseCase().last;
    if (isClosed || response.isLeft) return;
    final teams = [...response.right]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    emit(state.copyWith(teams: teams));
  }

  /// Abre o evento no editor (nulo fecha).
  void edit(AlbumEventDTO? event) {
    _stickers?.cancel();
    emit(state.copyWith(editing: () => event, stickers: const []));
    if (event == null || event.id.isEmpty) return;
    _stickers = manageAlbumUseCase.watchStickers(event.id).listen((response) {
      if (isClosed || response.isLeft) return;
      emit(state.copyWith(stickers: response.right));
    });
  }

  Future<void> _run(Future<Either<Failure, Object?>> Function() action, ManageAlbumNotice notice) async {
    emit(state.copyWith(busy: true));
    final response = await action();
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorManageAlbumState(state.copyWith(busy: false), failure.toString())),
      (_) => emit(NoticeManageAlbumState(state.copyWith(busy: false), notice)),
    );
  }

  /// Cria ou salva o evento; o novo já abre no editor.
  Future<void> saveEvent(AlbumEventDTO event) async {
    emit(state.copyWith(busy: true));
    final response = await manageAlbumUseCase.saveEvent(event);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorManageAlbumState(state.copyWith(busy: false), failure.toString())),
      (id) {
        emit(NoticeManageAlbumState(state.copyWith(busy: false), ManageAlbumNotice.saved));
        edit(event.copyWith(id: id));
      },
    );
  }

  Future<void> setMode(AlbumEventDTO event, AlbumEventMode mode) => _run(
        () => manageAlbumUseCase.setMode(event.id, mode),
        switch (mode) {
          AlbumEventMode.off => ManageAlbumNotice.deactivated,
          AlbumEventMode.test => ManageAlbumNotice.testing,
          AlbumEventMode.all => ManageAlbumNotice.activated,
        },
      );

  Future<void> deleteEvent(AlbumEventDTO event) async {
    if (state.editing?.id == event.id) edit(null);
    await _run(() => manageAlbumUseCase.deleteEvent(event.id), ManageAlbumNotice.deleted);
  }

  /// "Gerar do elenco": escudo + atletas do time que ainda não estão no álbum.
  /// Figurinhas do elenco do time; [championshipId] = só os inscritos nessa
  /// competição pelo time (nulo = elenco geral).
  Future<void> generateFromSquad(String teamId, {int? championshipId}) async {
    final event = state.editing;
    if (event == null || event.id.isEmpty) return;
    final team = state.teams.where((t) => t.id == teamId).firstOrNull;
    final teamName = team?.name ?? event.teamName(teamId);
    emit(state.copyWith(busy: true));
    final players = await watchTeamPlayersUseCase(teamId: teamId, teamName: teamName).first;
    if (isClosed) return;
    if (players.isLeft) {
      emit(ErrorManageAlbumState(state.copyWith(busy: false), players.left.toString()));
      return;
    }
    final added = AlbumLayout.fromSquad(
      teamId: teamId,
      team: teamName,
      crestUrl: team?.imageUrl ?? '',
      players: AlbumLayout.squadIn(players.right, championshipId: championshipId, teamId: teamId, team: teamName),
      existing: state.stickers,
    );
    final response = await manageAlbumUseCase.addStickers(event: event, added: added);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorManageAlbumState(state.copyWith(busy: false), failure.toString())),
      (_) =>
          emit(NoticeManageAlbumState(state.copyWith(busy: false), ManageAlbumNotice.generated, count: added.length)),
    );
  }

  Future<void> saveSticker(StickerDTO sticker, {File? image}) async {
    final event = state.editing;
    if (event == null) return;
    await _run(() => manageAlbumUseCase.saveSticker(event: event, sticker: sticker, image: image),
        ManageAlbumNotice.stickerSaved);
  }

  Future<void> deleteSticker(StickerDTO sticker) async {
    final event = state.editing;
    if (event == null) return;
    await _run(() => manageAlbumUseCase.deleteSticker(event, sticker), ManageAlbumNotice.stickerDeleted);
  }

  @override
  Future<void> close() {
    _events?.cancel();
    _stickers?.cancel();
    return super.close();
  }
}
