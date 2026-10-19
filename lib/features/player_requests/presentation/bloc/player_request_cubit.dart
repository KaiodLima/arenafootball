import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// "Sou jogador": acompanha o pedido do usuário em tempo real e cuida do
/// formulário (enviar, editar enquanto pendente, reenviar após rejeição).
class PlayerRequestCubit extends Cubit<PlayerRequestState> {
  final WatchMyPlayerRequestUseCase watchMyPlayerRequestUseCase;
  final SubmitPlayerRequestUseCase submitPlayerRequestUseCase;
  final CancelPlayerRequestUseCase cancelPlayerRequestUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final GetRegionChampionshipsCacheFirstUseCase getRegionChampionshipsCacheFirstUseCase;

  StreamSubscription<Either<Failure, PlayerRequestDTO?>>? _subscription;
  late String _userId;
  late String _userName;
  late String _email;
  late String _initialRegion;

  PlayerRequestCubit(
    this.watchMyPlayerRequestUseCase,
    this.submitPlayerRequestUseCase,
    this.cancelPlayerRequestUseCase,
    this.getRegionsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.watchTeamPlayersUseCase,
    this.getRegionChampionshipsCacheFirstUseCase,
  ) : super(const LoadingPlayerRequestState());

  Future<void> start({
    required String userId,
    required String userName,
    required String email,
    required String initialRegion,
  }) async {
    _userId = userId;
    _userName = userName;
    _email = email;
    _initialRegion = initialRegion;
    await _load();
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    emit(const LoadingPlayerRequestState());
    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorPlayerRequestState(errorMessage: regions.isLeft ? regions.left.toString() : ''));
      return;
    }
    final list = regions.right;
    final region = list.contains(_initialRegion) ? _initialRegion : list.first;
    emit(ReadyPlayerRequestState(form: PlayerRequestForm(regions: list, selectedRegion: region, name: _userName)));

    _subscription?.cancel();
    _subscription = watchMyPlayerRequestUseCase(_userId).listen(_onRequest);
    await _loadTeams(region);
  }

  void _onRequest(Either<Failure, PlayerRequestDTO?> response) {
    if (response.isLeft) {
      if (state is LoadingPlayerRequestState) {
        emit(LoadErrorPlayerRequestState(errorMessage: response.left.toString()));
      } else {
        emit(ErrorPlayerRequestState(state, errorMessage: response.left.toString()));
      }
      return;
    }
    final request = response.right;
    // Editando: o pedido muda por baixo (ex.: admin respondeu), mas o
    // formulário em edição fica como está.
    if (state.editing) {
      _emitReady(request: request, form: state.form, editing: true);
      return;
    }
    final regionChanged = request != null && request.region.isNotEmpty && request.region != state.form.selectedRegion;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
    // Escudo do time do pedido: precisa dos times da região dele.
    if (regionChanged) _loadTeams(request.region);
  }

  /// Formulário preenchido com o pedido (para mostrar o escudo e para editar).
  PlayerRequestForm _formFrom(PlayerRequestDTO request, PlayerRequestForm form) {
    return form.copyWith(
      selectedRegion: request.region.isEmpty ? null : request.region,
      selectedTeam: () => request.team,
      championshipId: () => request.championshipId,
      claimedPlayer: () => null,
      unlinkedPlayers: const [],
      name: request.name,
      position: request.position,
      message: request.message,
      photo: () => null,
      imageUrl: request.imageUrl,
    );
  }

  void _emitReady({PlayerRequestDTO? request, required PlayerRequestForm form, required bool editing}) {
    emit(ReadyPlayerRequestState(request: request, form: form, editing: editing));
  }

  void _updateForm(PlayerRequestForm form) => _emitReady(request: state.request, form: form, editing: state.editing);

  Future<void> _loadTeams(String region) async {
    _updateForm(state.form.copyWith(selectedRegion: region, loadingTeams: true));
    unawaited(_loadChampionships(region));
    await for (final response in getTeamsCacheFirstUseCase(region: region)) {
      // Só aplica se a região não mudou enquanto carregava.
      if (isClosed || state.form.selectedRegion != region) return;
      response.fold(
        (failure) {
          _updateForm(state.form.copyWith(teams: const [], loadingTeams: false));
          emit(ErrorPlayerRequestState(state, errorMessage: failure.toString()));
        },
        (teams) {
          final keep = teams.any((t) => t.name == state.form.selectedTeam);
          _updateForm(state.form.copyWith(
            teams: teams,
            loadingTeams: false,
            selectedTeam: keep ? null : () => null,
          ));
        },
      );
    }
  }

  /// Competições da região na temporada atual (chips antes do time).
  Future<void> _loadChampionships(String region) async {
    await for (final response
        in getRegionChampionshipsCacheFirstUseCase(region: region, season: SeasonCollection.currentSeason)) {
      if (isClosed || state.form.selectedRegion != region) return;
      if (response.isLeft) continue;
      final championships = [...response.right]..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      final current = state.form.championshipId;
      final keep = championships.any((c) => c.championshipId == current);
      _updateForm(state.form.copyWith(
        championships: championships,
        // Uma competição só: já vem escolhida.
        championshipId: keep ? null : () => championships.length == 1 ? championships.first.championshipId : null,
      ));
    }
  }

  /// Competição em que quer jogar: o time escolhido precisa jogar nela.
  Future<void> selectChampionship(int championshipId) async {
    if (championshipId == state.form.championshipId) return;
    final form = state.form.copyWith(championshipId: () => championshipId);
    final team = form.selectedTeam;
    final teamStays = team != null && form.selectableTeams.any((t) => t.name == team);
    _updateForm(form.copyWith(
      selectedTeam: teamStays ? null : () => null,
      claimedPlayer: () => null,
      unlinkedPlayers: teamStays ? null : const [],
    ));
    if (teamStays) await _loadUnlinkedPlayers(team);
  }

  /// Atleta aprovado pedindo para jogar também em outra competição (por outro
  /// time ou pelo mesmo): formulário novo; o pedido anterior é substituído ao
  /// enviar (a inscrição aprovada continua no atleta).
  void startNewRequest() {
    final form = state.form.copyWith(
      selectedTeam: () => null,
      championshipId: () => null,
      claimedPlayer: () => null,
      unlinkedPlayers: const [],
      name: _userName,
      message: '',
      photo: () => null,
      imageUrl: '',
    );
    _emitReady(request: state.request, form: form, editing: true);
  }

  /// Abre o formulário sobre o pedido atual (corrigir pendente ou reenviar).
  void startEditing() {
    final request = state.request;
    final form = request == null ? state.form : _formFrom(request, state.form);
    _emitReady(request: request, form: form, editing: true);
    // Atletas sem conta do time do pedido (e o "sou eu" que já estava marcado).
    final team = form.selectedTeam;
    if (team != null) _loadUnlinkedPlayers(team, restoreClaimId: request?.claimedPlayerId ?? '');
  }

  void stopEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _updateForm(state.form.copyWith(selectedTeam: () => null));
    await _loadTeams(region);
  }

  /// Escolher o time limpa o "sou eu" e carrega os atletas dele sem conta.
  Future<void> selectTeam(String team) async {
    if (team == state.form.selectedTeam) return;
    _updateForm(state.form.copyWith(
      selectedTeam: () => team,
      claimedPlayer: () => null,
      unlinkedPlayers: const [],
    ));
    await _loadUnlinkedPlayers(team);
  }

  /// Uma leitura do elenco (não fica ouvindo): só os atletas sem conta.
  Future<void> _loadUnlinkedPlayers(String team, {String restoreClaimId = ''}) async {
    final teamId = state.form.selectedTeamId;
    _updateForm(state.form.copyWith(loadingPlayers: true));
    final response = await watchTeamPlayersUseCase(
      teamId: teamId,
      teamName: team,
      season: SeasonCollection.currentSeason,
    ).first;
    if (isClosed || state.form.selectedTeam != team) return;
    final championshipId = state.form.championshipId;
    final players = response.isRight
        ? (response.right
            .where((p) =>
                p.userId.isEmpty &&
                (championshipId == null || p.playsIn(championshipId, teamId: teamId, teamName: team)))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())))
        : const <PlayerDTO>[];
    final restored = players.where((p) => p.id == restoreClaimId).firstOrNull;
    _updateForm(state.form.copyWith(
      unlinkedPlayers: players,
      loadingPlayers: false,
      claimedPlayer: restored == null ? null : () => restored,
    ));
  }

  /// "Sou eu": marca o atleta (nulo ou o mesmo de novo = desmarca).
  void claimPlayer(PlayerDTO? player) {
    final same = player != null && player.id == state.form.claimedPlayer?.id;
    final claimed = same ? null : player;
    _updateForm(state.form.copyWith(
      claimedPlayer: () => claimed,
      name: claimed?.name ?? (state.form.isClaim ? _userName : state.form.name),
      position: claimed == null ? null : PlayerPosition.fromKey(claimed.position),
    ));
  }

  void changeName(String name) => _updateForm(state.form.copyWith(name: name));

  void selectPosition(PlayerPosition position) => _updateForm(state.form.copyWith(position: position));

  void changeMessage(String message) => _updateForm(state.form.copyWith(message: message));

  void setPhoto(File photo) => _updateForm(state.form.copyWith(photo: () => photo));

  void clearPhoto() => _updateForm(state.form.copyWith(photo: () => null, imageUrl: ''));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingPlayerRequestState) return;
    final current = state;
    emit(SubmittingPlayerRequestState(current));

    final request = PlayerRequestDTO(
      userId: _userId,
      userName: _userName,
      email: _email,
      name: form.name,
      team: form.selectedTeam!,
      teamId: form.selectedTeamId,
      region: form.selectedRegion ?? '',
      season: SeasonCollection.currentSeason,
      position: form.position,
      message: form.message,
      imageUrl: form.imageUrl.isEmpty && form.photo == null ? form.claimedPlayer?.imageUrl ?? '' : form.imageUrl,
      claimedPlayerId: form.claimedPlayer?.id ?? '',
      championshipId: form.selectedChampionship?.championshipId,
      championship: form.selectedChampionship?.title ?? '',
    );
    final response = await submitPlayerRequestUseCase(request, photo: form.photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(SubmittedPlayerRequestState(current)),
    );
  }

  Future<void> cancelRequest() async {
    if (state is SubmittingPlayerRequestState) return;
    final current = state;
    emit(SubmittingPlayerRequestState(current));
    final response = await cancelPlayerRequestUseCase(_userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(CancelledPlayerRequestState(current)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
