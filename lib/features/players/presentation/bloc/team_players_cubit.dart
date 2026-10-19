import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/set_team_championships_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/set_player_championships_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_team_usecase.dart';

/// Elenco de um time em tempo real: o elenco geral (todas as competições da
/// temporada) e, nas chips, o de cada competição que o time joga; com busca e
/// ordenação. As edições do admin ficam na tela do atleta; aqui o admin pode
/// excluir o time.
class TeamPlayersCubit extends Cubit<TeamPlayersState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final DeleteTeamUseCase deleteTeamUseCase;
  final GetRegionChampionshipsCacheFirstUseCase getRegionChampionshipsCacheFirstUseCase;
  final GetSeasonChampionshipsUseCase? getSeasonChampionshipsUseCase;
  final SetTeamChampionshipsUseCase? setTeamChampionshipsUseCase;
  final SetPlayerChampionshipsUseCase? setPlayerChampionshipsUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _subscription;
  String _teamId = '';
  String? _teamName;
  String? _season;

  String _region = '';

  TeamPlayersCubit(
    this.watchTeamPlayersUseCase,
    this.deleteTeamUseCase,
    this.getRegionChampionshipsCacheFirstUseCase, [
    this.getSeasonChampionshipsUseCase,
    this.setTeamChampionshipsUseCase,
    this.setPlayerChampionshipsUseCase,
  ]) : super(const LoadingTeamPlayersState());

  /// [region] (a do time) carrega as competições; [championshipId] abre já
  /// na sublista dela.
  void watch({
    String teamId = '',
    required String teamName,
    required String season,
    String region = '',
    int? championshipId,
  }) {
    _teamId = teamId;
    _teamName = teamName;
    _season = season;
    _subscription?.cancel();
    final view = state.view.copyWith(
      teamId: teamId,
      teamName: teamName,
      championshipId: championshipId == null ? null : () => championshipId,
    );
    emit(LoadingTeamPlayersState(players: state.players, view: view));
    _subscription = watchTeamPlayersUseCase(teamId: teamId, teamName: teamName, season: season).listen((response) {
      response.fold(
        (failure) =>
            emit(ErrorTeamPlayersState(errorMessage: failure.toString(), players: state.players, view: state.view)),
        (players) => emit(SuccessTeamPlayersState(players: players, view: state.view)),
      );
    });
    _region = region;
    if (region.isNotEmpty) unawaited(_loadChampionships(region: region, season: season));
  }

  Future<void> _loadChampionships({required String region, required String season, bool force = false}) async {
    await for (final response
        in getRegionChampionshipsCacheFirstUseCase(region: region, season: season, force: force)) {
      if (isClosed || response.isLeft) return;
      final mine = response.right.where((c) => c.hasTeam(id: _teamId, name: _teamName ?? '')).toList()
        ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      emit(_withView(state.view.copyWith(championships: mine)));
    }
  }

  /// Competições da temporada em que o time pode jogar (municipais da região
  /// dele e intermunicipais); nulo se falhar.
  Future<List<ChampionshipDTO>?> eligibleChampionships(TeamDTO team) async {
    final useCase = getSeasonChampionshipsUseCase;
    if (useCase == null || _season == null) return null;
    final response = await useCase(_season!);
    if (response.isLeft) return null;
    return GetSeasonChampionshipsUseCase.eligibleFor(response.right, team);
  }

  /// Inscreve o time nas competições [selected] (entre as [offered]) e
  /// recarrega as chips. Devolve a falha (nula = ok).
  Future<String?> saveTeamChampionships(TeamDTO team, List<ChampionshipDTO> offered, Set<int> selected) async {
    final useCase = setTeamChampionshipsUseCase;
    if (useCase == null) return '';
    final response = await useCase(team: team, championships: offered, selected: selected);
    if (response.isLeft) return response.left.toString();
    if (_region.isNotEmpty && _season != null) {
      await _loadChampionships(region: _region, season: _season!, force: true);
    }
    return null;
  }

  /// Em quais competições do time o atleta joga por ele. Devolve a falha
  /// (nula = ok); o stream do elenco mostra o resultado.
  Future<String?> savePlayerChampionships(PlayerDTO player, Set<int> selected) async {
    final useCase = setPlayerChampionshipsUseCase;
    if (useCase == null) return '';
    final response = await useCase(
      player,
      teamId: _teamId,
      team: _teamName ?? '',
      selected: selected,
      teamChampionships: [for (final c in state.view.championships) c.championshipId],
      season: _season,
    );
    return response.isLeft ? response.left.toString() : null;
  }

  void setSort(PlayersSort sort) => emit(_withView(state.view.copyWith(sort: sort)));

  void setQuery(String query) => emit(_withView(state.view.copyWith(query: query)));

  /// Sublista da competição (nula = elenco geral).
  void selectChampionship(int? championshipId) =>
      emit(_withView(state.view.copyWith(championshipId: () => championshipId)));

  /// Mesmo estado (e tipo) com outra visão.
  TeamPlayersState _withView(TeamPlayersView view) {
    final s = state;
    if (s is LoadingTeamPlayersState) return LoadingTeamPlayersState(players: s.players, view: view);
    if (s is ErrorTeamPlayersState) {
      return ErrorTeamPlayersState(errorMessage: s.errorMessage, players: s.players, view: view);
    }
    if (s is DeletingTeamPlayersState) return DeletingTeamPlayersState(players: s.players, view: view);
    if (s is DeletedTeamPlayersState) return s;
    return SuccessTeamPlayersState(players: s.players, view: view);
  }

  Future<void> deleteTeam(TeamDTO team) async {
    if (state is DeletingTeamPlayersState) return;
    final before = state;
    // Sem isso, o elenco esvaziando aparece na tela antes do aviso.
    await _subscription?.cancel();
    _subscription = null;
    emit(DeletingTeamPlayersState(players: before.players, view: before.view));
    final response = await deleteTeamUseCase(team, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) {
        emit(ErrorTeamPlayersState(errorMessage: failure.toString(), players: before.players, view: before.view));
        // O time continua existindo: volta a acompanhar o elenco.
        if (_teamName != null && _season != null) {
          watch(teamId: _teamId, teamName: _teamName!, season: _season!, championshipId: before.championshipId);
        }
      },
      (_) => emit(DeletedTeamPlayersState(teamName: team.name)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
