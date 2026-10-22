import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delete_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_status_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Partidas de um campeonato em tempo real + ações do admin (placar,
/// abrir/fechar votação, excluir). As ações gravam na mesma temporada da
/// lista; o stream traz a atualização. Também guarda o filtro por time e os
/// escudos (da coleção de times da região).
class MatchesCubit extends Cubit<MatchesState> {
  final WatchMatchesUseCase watchMatchesUseCase;
  final UpdateMatchScoreUseCase updateMatchScoreUseCase;
  final ToggleMatchVotingUseCase toggleMatchVotingUseCase;
  final DeleteMatchUseCase deleteMatchUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final SetMatchStatusUseCase setMatchStatusUseCase;
  StreamSubscription<Either<Failure, List<MatchDTO>>>? _subscription;
  String? _region;
  String? _season;
  int? _championshipId;
  MatchesFilter? _filter;

  /// Já houve um [watch] (o campeonato pode ser nulo = todas as competições).
  bool _started = false;

  /// Conta as cargas de escudos: só a mais recente é aplicada.
  int _crestsLoad = 0;

  MatchesCubit(
    this.watchMatchesUseCase,
    this.updateMatchScoreUseCase,
    this.toggleMatchVotingUseCase,
    this.deleteMatchUseCase,
    this.getTeamsCacheFirstUseCase,
    this.setMatchStatusUseCase,
  ) : super(const LoadingMatchesState());

  /// Recorte (dia) que está sendo ouvido; nulo antes do primeiro [watch].
  MatchesFilter? get filter => _filter;

  /// Já ouve as partidas deste campeonato na região/temporada.
  bool isWatching({int? championshipId, required String region, required String season}) =>
      _subscription != null && _championshipId == championshipId && _region == region && _season == season;

  /// Ouve as partidas do campeonato na região/temporada. Na aba de tabelas o
  /// cubit vive na home: voltar à aba com o mesmo campeonato/região/temporada
  /// não reabre a consulta (só troca o dia, se mudou); qualquer outra troca
  /// começa do zero (lista, filtro por time e escudos).
  void watch({
    int? championshipId,
    required MatchesFilter filter,
    required String region,
    required String season,
  }) {
    if (isWatching(championshipId: championshipId, region: region, season: season)) {
      if (filter != _filter) _subscribe(filter);
      return;
    }
    _region = region;
    _season = season;
    _championshipId = championshipId;
    _started = true;
    emit(const LoadingMatchesState());
    _loadCrests(region: region, season: season);
    _subscribe(filter);
  }

  /// Troca o dia da aba de tabelas (ontem/hoje/amanhã) sem recarregar os
  /// escudos; a lista anterior fica na tela até chegar a nova.
  void selectDay(MatchesFilter filter) {
    if (!_started) return;
    _subscribe(filter);
  }

  void _subscribe(MatchesFilter filter) {
    _subscription?.cancel();
    _filter = filter;
    emit(LoadingMatchesState(
        matches: state.matches, teamFilter: state.teamFilter, crests: state.crests, colors: state.colors));
    _subscription = watchMatchesUseCase(
      championshipId: _championshipId,
      filter: filter,
      region: _region,
      season: _season,
    ).listen(
      (response) {
        response.fold(
          (failure) => emit(ErrorMatchesState(
            errorMessage: failure.toString(),
            matches: state.matches,
            teamFilter: state.teamFilter,
            crests: state.crests,
            colors: state.colors,
          )),
          (matches) => emit(SuccessMatchesState(
              matches: matches, teamFilter: state.teamFilter, crests: state.crests, colors: state.colors)),
        );
      },
    );
  }

  /// Escudos e cores são só decoração: se falhar, o card mostra o ícone padrão.
  Future<void> _loadCrests({required String region, required String season}) async {
    final load = ++_crestsLoad;
    await for (final response in getTeamsCacheFirstUseCase(region: region, season: season)) {
      if (isClosed || load != _crestsLoad) return;
      response.fold((_) => null, (teams) {
        final crests = {
          for (final team in teams)
            if (team.imageUrl.isNotEmpty) normalizeTeamName(team.name): team.imageUrl,
        };
        final colors = {
          for (final team in teams)
            if (team.primaryColor.isNotEmpty) normalizeTeamName(team.name): team.primaryColor,
        };
        _emitWith(crests: crests, colors: colors);
      });
    }
  }

  /// Mostra só as partidas de [team] (null = todas).
  void setTeamFilter(String? team) {
    if (team == state.teamFilter) return;
    _emitWith(teamFilter: team, clearFilter: team == null);
  }

  /// Reemite o estado atual trocando filtro/escudos. Um erro de ação (com a
  /// lista na tela) já virou snackbar e não é reemitido, para não repetir.
  void _emitWith(
      {String? teamFilter, bool clearFilter = false, Map<String, String>? crests, Map<String, String>? colors}) {
    final s = state;
    final filter = clearFilter ? null : (teamFilter ?? s.teamFilter);
    final newCrests = crests ?? s.crests;
    final newColors = colors ?? s.colors;
    emit(switch (s) {
      ErrorMatchesState() when s.matches.isEmpty => ErrorMatchesState(
          errorMessage: s.errorMessage,
          matches: s.matches,
          teamFilter: filter,
          crests: newCrests,
          colors: newColors,
        ),
      LoadingMatchesState() =>
        LoadingMatchesState(matches: s.matches, teamFilter: filter, crests: newCrests, colors: newColors),
      _ => SuccessMatchesState(matches: s.matches, teamFilter: filter, crests: newCrests, colors: newColors),
    });
  }

  Future<void> updateScore(MatchDTO match, {required String homeGoals, required String awayGoals}) async {
    final response = await updateMatchScoreUseCase(
      match: match,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      season: _season,
    );
    _emitIfFailed(response);
  }

  Future<void> toggleVoting(MatchDTO match) async {
    _emitIfFailed(await toggleMatchVotingUseCase(match: match, season: _season));
  }

  /// Admin: inicia ([live]) ou encerra a partida na mão.
  Future<void> setLive(MatchDTO match, bool live) async {
    _emitIfFailed(await setMatchStatusUseCase(match: match, live: live, season: _season));
  }

  Future<void> delete(MatchDTO match) async {
    _emitIfFailed(await deleteMatchUseCase(matchId: match.id, season: _season));
  }

  void _emitIfFailed(Either<Failure, Object?> response) {
    if (isClosed || response.isRight) return;
    emit(ErrorMatchesState(
      errorMessage: response.left.toString(),
      matches: state.matches,
      teamFilter: state.teamFilter,
      crests: state.crests,
      colors: state.colors,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
