import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/goal_cards.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Cards de gol do "Editar placar": cada gol novo vira um card (como o
/// "Notificar gol", ligado à partida e ao gol pelo `id_gol`, com o placar
/// daquele momento); gol removido apaga o card dele e gol editado atualiza
/// autor/garçom. **Não** mexe nos números dos atletas (o `UpdateMatchGoalsUseCase`
/// já acertou). Escudos e cores vêm do cache dos times. Devolve quantos
/// cards novos saíram.
class PublishGoalCardsUseCase {
  final CreateNewsUseCase _createNews;
  final INewsRepository _news;
  final GetTeamsCacheFirstUseCase _getTeams;

  PublishGoalCardsUseCase(this._createNews, this._news, this._getTeams);

  Future<Either<Failure, int>> call({
    required MatchDTO match,
    required List<MatchGoal> before,
    required List<MatchGoal> after,
    String? season,
  }) async {
    final plan = GoalCardsPlan.of(before, after);
    if (plan.isEmpty) return const Right(0);

    // Gols removidos/editados: os cards deles (uma consulta).
    final touched = [...plan.removed, ...plan.changed].map((g) => g.id).toList();
    if (touched.isNotEmpty) {
      final cards = await _news.getGoalCardsByGoalIds(touched);
      if (cards.isLeft) return Left(cards.left);
      final changed = {for (final g in plan.changed) g.id: g};
      for (final card in cards.right) {
        final goal = changed[card.goalId];
        final response = goal == null
            ? await _news.deleteNews(card.id)
            : await _news.updateNews(card.copyWith(
                scorerId: goal.scorerId,
                scorerName: goal.scorerName,
                assistantId: goal.hasAssistant ? goal.assistantId : '',
                assistantName: goal.hasAssistant ? goal.assistantName : '',
              ));
        if (response.isLeft) return Left(response.left);
      }
    }

    if (plan.added.isEmpty) return const Right(0);
    final teams = await _getTeams(season: season).last;
    final byId = teams.fold((_) => const <String, TeamDTO>{}, (list) => {for (final t in list) t.id: t});
    for (final item in plan.added) {
      final response = await _createNews(news: goalCard(match, item, byId, season: season ?? ''));
      if (response.isLeft) return Left(response.left);
    }
    return Right(plan.added.length);
  }

  /// O card de um gol novo (igual ao do "Notificar gol").
  static NewsDTO goalCard(MatchDTO match, GoalCardItem item, Map<String, TeamDTO> teams, {String season = ''}) {
    final goal = item.goal;
    final home = goal.side == MatchSide.home;
    final scoringId = home ? match.homeTeamId : match.awayTeamId;
    final scoring = teams[scoringId];
    return NewsDTO(
      tag: NewsDTO.goalTag,
      isVisible: true,
      region: match.region,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      homeGoals: '${item.homeGoals}',
      awayGoals: '${item.awayGoals}',
      scorerId: goal.scorerId,
      scorerName: goal.scorerName,
      assistantId: goal.hasAssistant ? goal.assistantId : '',
      assistantName: goal.hasAssistant ? goal.assistantName : '',
      season: goal.hasScorer ? season : '',
      scoringTeam: home ? match.homeTeam : match.awayTeam,
      scoringTeamCrest: scoring?.imageUrl ?? '',
      homeTeamId: match.homeTeamId,
      awayTeamId: match.awayTeamId,
      scoringTeamId: scoringId,
      scoringTeamPrimaryColor: scoring?.primaryColor ?? '',
      scoringTeamSecondaryColor: scoring?.secondaryColor ?? '',
      matchId: match.id,
      championshipId: match.championshipId > 0 ? match.championshipId : null,
      goalId: goal.id,
    );
  }
}
