import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_today_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/add_player_stats_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Publica um card de gol (notícia com tag "gol") com o placar da partida e,
/// opcionalmente, grava o mesmo placar na partida de hoje correspondente e
/// soma o gol/a assistência nos jogadores informados.
class GoalNotificationCubit extends Cubit<GoalNotificationState> {
  final CreateNewsUseCase createNewsUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final GetTodayMatchesUseCase getTodayMatchesUseCase;
  final UpdateMatchScoreUseCase updateMatchScoreUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final AddPlayerStatsUseCase addPlayerStatsUseCase;
  final GetRegionChampionshipsCacheFirstUseCase getRegionChampionshipsCacheFirstUseCase;
  String? _season;

  /// Confronto cujos elencos estão carregados (ou carregando).
  String? _squadHome;
  String? _squadAway;

  /// Card de gol de partida (feed): usado só no primeiro carregamento.
  NewsDTO? _initial;

  /// Partida tocada na lista (admin): usada só no primeiro carregamento.
  MatchDTO? _initialMatch;

  GoalNotificationCubit(
    this.createNewsUseCase,
    this.getRegionsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.getTodayMatchesUseCase,
    this.updateMatchScoreUseCase,
    this.watchTeamPlayersUseCase,
    this.addPlayerStatsUseCase,
    this.getRegionChampionshipsCacheFirstUseCase,
  ) : super(const EditingGoalNotificationState());

  /// Toda edição passa por aqui: se o confronto mudou, autor e assistência
  /// deixam de valer e os elencos do novo confronto são carregados.
  void _edit(GoalFormData form) {
    if (isClosed) return;
    final changed = form.homeTeam != _squadHome || form.awayTeam != _squadAway;
    if (changed) {
      form = form.copyWith(homeSquad: const [], awaySquad: const [], clearScorer: true, clearScoringTeam: true);
    }
    emit(EditingGoalNotificationState(form: form));
    if (changed) _loadSquads(form.homeTeam, form.awayTeam);
  }

  /// Elencos do mandante e do visitante. Falhar só deixa a escolha vazia.
  Future<void> _loadSquads(String? home, String? away) async {
    _squadHome = home;
    _squadAway = away;
    if (home == null || away == null) return;
    final form = state.form;
    final homeFuture = watchTeamPlayersUseCase(teamId: form.teamIdOf(home), teamName: home, season: _season).first;
    final awayFuture = watchTeamPlayersUseCase(teamId: form.teamIdOf(away), teamName: away, season: _season).first;
    final homeResponse = await homeFuture;
    final awayResponse = await awayFuture;
    // Descarta se o confronto mudou enquanto carregava.
    if (isClosed || home != _squadHome || away != _squadAway) return;
    List<PlayerDTO> sorted(List<PlayerDTO> list) =>
        [...list]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    emit(EditingGoalNotificationState(
      form: state.form.copyWith(
        homeSquad: homeResponse.fold((_) => const [], sorted),
        awaySquad: awayResponse.fold((_) => const [], sorted),
      ),
    ));
  }

  /// Autor do gol e quem deu o passe, escolhidos no painel aberto pelo "+"
  /// (nulos = não informado). Um novo gol substitui os anteriores: o card
  /// registra um gol só.
  void setScorer(PlayerDTO? scorer, PlayerDTO? assistant) {
    final form = state.form;
    if (scorer == null) {
      _edit(form.copyWith(clearScorer: true));
      return;
    }
    // A assistência só vale se for outro jogador do mesmo time (no elenco
    // do time do autor nesta competição).
    final side = form.sideOf(scorer);
    final valid = assistant != null && assistant.id != scorer.id && side != null && form.sideOf(assistant) == side;
    _edit(form.copyWith(
      scorer: scorer,
      assistant: valid ? assistant : null,
      clearAssistant: !valid,
      scoringTeam: side ?? scorer.team,
    ));
  }

  /// Competição do gol nas chips (quando a partida não diz qual é). O autor
  /// escolhido pode não jogar nela: escolhe de novo.
  void selectChampionship(int championshipId) {
    if (championshipId == state.form.championshipId) return;
    _edit(state.form.copyWith(selectedChampionshipId: () => championshipId, clearScorer: true));
  }

  Future<void> load({
    required String initialRegion,
    String? season,
    NewsDTO? initial,
    MatchDTO? initialMatch,
  }) async {
    _season = season;
    _initial = initial;
    _initialMatch = initialMatch;
    _edit(state.form.copyWith(regions: [initialRegion], selectedRegion: initialRegion));
    final loadRegion = _loadRegionData(initialRegion);

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadRegion;
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _initial = null;
    _initialMatch = null;
    _edit(state.form.copyWith(
      selectedRegion: region,
      teams: const [],
      todayMatches: const [],
      updateMatch: false,
      clearPinned: true,
      clearTeams: true,
    ));
    await _loadRegionData(region);
  }

  /// Times da temporada corrente e partidas de hoje da região. Como no app
  /// antigo, o mandante começa no primeiro time e o visitante no último.
  Future<void> _loadRegionData(String region) async {
    // Cache-first: fica com a última emissão (o remoto quando revalidou).
    final teamsFuture = getTeamsCacheFirstUseCase(region: region).last;
    final matchesFuture = getTodayMatchesUseCase(region: region, season: _season);
    final championshipsFuture = getRegionChampionshipsCacheFirstUseCase(region: region, season: _season ?? '').last;
    final teamsResponse = await teamsFuture;
    final matchesResponse = await matchesFuture;
    final championshipsResponse = await championshipsFuture;
    if (isClosed || state.form.selectedRegion != region) return;
    final teams = teamsResponse.fold((_) => const <TeamDTO>[], (list) => list);
    // Sem as partidas de hoje, só não aparece o atalho.
    final matches = matchesResponse.fold((_) => const <MatchDTO>[], (list) => list);
    // Sem as competições, o gol soma só no total.
    final championships = championshipsResponse.fold((_) => const <ChampionshipDTO>[], (list) => list);

    final form = state.form.copyWith(teams: teams, todayMatches: matches, championships: championships);
    final initialMatch = _initialMatch;
    _initialMatch = null;
    if (initialMatch != null) {
      // Veio do card de partida: parte do placar dela e já liga a atualização.
      _initial = null;
      _edit(form.copyWith(
        homeTeam: initialMatch.homeTeam,
        awayTeam: initialMatch.awayTeam,
        homeGoals: initialMatch.homeGoals.clamp(0, GoalFormData.maxGoals),
        awayGoals: initialMatch.awayGoals.clamp(0, GoalFormData.maxGoals),
        pinnedMatch: initialMatch,
        updateMatch: true,
      ));
      return;
    }
    final initial = _initial;
    _initial = null;
    if (initial != null && initial.homeTeam.isNotEmpty && initial.awayTeam.isNotEmpty) {
      // Parte do card tocado no feed (mesmo que o time não esteja mais na lista).
      _edit(form.copyWith(
        homeTeam: initial.homeTeam,
        awayTeam: initial.awayTeam,
        homeGoals: _goals(initial.homeGoals),
        awayGoals: _goals(initial.awayGoals),
      ));
      return;
    }
    _edit(teams.isEmpty
        ? form.copyWith(clearTeams: true)
        : form.copyWith(homeTeam: teams.first.name, awayTeam: teams.last.name));
  }

  /// Gols gravados como texto no card ("2"); vazio ou inválido = 0.
  static int _goals(String value) => (int.tryParse(value.trim()) ?? 0).clamp(0, GoalFormData.maxGoals);

  void selectHomeTeam(String team) => _edit(state.form.copyWith(homeTeam: team));

  void selectAwayTeam(String team) => _edit(state.form.copyWith(awayTeam: team));

  void incrementHome() {
    _setGoals(home: state.form.homeGoals + 1);
    _edit(state.form.copyWith(scoringTeam: state.form.homeTeam));
  }

  /// Desfazer o gol do time do autor desfaz também autor e assistência.
  void decrementHome() {
    _setGoals(home: state.form.homeGoals - 1);
    if (state.form.sideOf(state.form.scorer) == state.form.homeTeam) setScorer(null, null);
    if (state.form.scoringTeam == state.form.homeTeam) _edit(state.form.copyWith(clearScoringTeam: true));
  }

  void incrementAway() {
    _setGoals(away: state.form.awayGoals + 1);
    _edit(state.form.copyWith(scoringTeam: state.form.awayTeam));
  }

  void decrementAway() {
    _setGoals(away: state.form.awayGoals - 1);
    if (state.form.sideOf(state.form.scorer) == state.form.awayTeam) setScorer(null, null);
    if (state.form.scoringTeam == state.form.awayTeam) _edit(state.form.copyWith(clearScoringTeam: true));
  }

  void _setGoals({int? home, int? away}) => _edit(state.form.copyWith(
        homeGoals: home?.clamp(0, GoalFormData.maxGoals),
        awayGoals: away?.clamp(0, GoalFormData.maxGoals),
      ));

  /// Atalho "jogos de hoje": preenche times e placar atual e liga a
  /// atualização da partida.
  void pickMatch(MatchDTO match) => _edit(state.form.copyWith(
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        updateMatch: true,
      ));

  void toggleUpdateMatch(bool value) => _edit(state.form.copyWith(updateMatch: value));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingGoalNotificationState) return;
    emit(SubmittingGoalNotificationState(form: form));

    final response = await createNewsUseCase(
      news: NewsDTO(
        tag: NewsDTO.goalTag,
        isVisible: true,
        region: form.selectedRegion ?? '',
        homeTeam: form.homeTeam!,
        awayTeam: form.awayTeam!,
        homeGoals: '${form.homeGoals}',
        awayGoals: '${form.awayGoals}',
        // Quem marcou fica no card (o feed mostra e leva à tela do atleta).
        scorerId: form.scorer?.id ?? '',
        scorerName: form.scorer?.name ?? '',
        assistantId: form.assistant != null && form.assistant!.id != form.scorer?.id ? form.assistant!.id : '',
        assistantName: form.assistant != null && form.assistant!.id != form.scorer?.id ? form.assistant!.name : '',
        season: form.scorer != null ? (_season ?? '') : '',
        scoringTeam: form.scoringTeam ?? '',
        scoringTeamCrest: form.crestOf(form.scoringTeam) ?? '',
        homeTeamId: form.teamIdOf(form.homeTeam),
        awayTeamId: form.teamIdOf(form.awayTeam),
        scoringTeamId: form.teamIdOf(form.scoringTeam),
        scoringTeamPrimaryColor: form.teamOf(form.scoringTeam)?.primaryColor ?? '',
        scoringTeamSecondaryColor: form.teamOf(form.scoringTeam)?.secondaryColor ?? '',
        championshipId: form.championshipId,
      ),
    );
    if (isClosed) return;
    if (response.isLeft) {
      emit(ErrorGoalNotificationState(form: form, errorMessage: response.left.toString()));
      return;
    }

    var next = form;
    var matchUpdated = false;
    final match = form.updateMatch ? form.linkedMatch : null;
    if (match != null) {
      final update = await updateMatchScoreUseCase(
        match: match,
        homeGoals: '${form.homeGoals}',
        awayGoals: '${form.awayGoals}',
        season: _season,
      );
      if (isClosed) return;
      if (update.isLeft) {
        emit(PartialGoalNotificationState(form: form, errorMessage: update.left.toString()));
        return;
      }
      // A lista local passa a ter o placar novo.
      final updated = update.right;
      next = next.copyWith(
        todayMatches: [for (final m in next.todayMatches) m.id == updated.id ? updated : m],
        pinnedMatch: next.pinnedMatch?.id == updated.id ? updated : next.pinnedMatch,
      );
      matchUpdated = true;
    }

    // O próximo gol escolhe o time de novo.
    next = next.copyWith(clearScoringTeam: true);
    final scorer = form.scorer;
    final assistant = form.assistant;
    if (scorer != null || assistant != null) {
      final stats = await addPlayerStatsUseCase(
        scorer: scorer,
        assistant: assistant,
        season: _season,
        championshipId: form.championshipId,
        teamId: form.teamIdOf(form.scoringTeam),
        team: form.scoringTeam ?? '',
      );
      if (isClosed) return;
      if (stats.isLeft) {
        emit(PartialGoalNotificationState(
          form: next,
          errorMessage: stats.left.toString(),
          failure: GoalPartialFailure.stats,
        ));
        return;
      }
      // Elencos locais com os números novos; autor e assistência ficam
      // livres para o próximo gol.
      PlayerDTO bump(PlayerDTO p) => p.copyWith(
            goals: p.goals + (p.id == scorer?.id ? 1 : 0),
            assists: p.assists + (p.id == assistant?.id && p.id != scorer?.id ? 1 : 0),
          );
      next = next.copyWith(
        homeSquad: next.homeSquad.map(bump).toList(),
        awaySquad: next.awaySquad.map(bump).toList(),
        clearScorer: true,
      );
    }
    emit(SuccessGoalNotificationState(
      form: next,
      matchUpdated: matchUpdated,
      scorer: scorer,
      assistant: assistant?.id == scorer?.id ? null : assistant,
    ));
  }
}
