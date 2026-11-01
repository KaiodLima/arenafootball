import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/publish_goal_cards_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';

/// "Salvar súmula": os gols (se mudaram) pelo [UpdateMatchGoalsUseCase], que
/// acerta os números dos atletas pela diferença; depois os cards de gol dos
/// gols novos ([publishCards]); e, numa gravação, cartões, escalação,
/// árbitro, observações e os dados do jogo. Devolve a partida salva e
/// quantos cards saíram (−1 = o card falhou; o resto ficou salvo).
class SaveMatchReportUseCase {
  final UpdateMatchGoalsUseCase _goals;
  final PublishGoalCardsUseCase _cards;
  final IMatchesRepository _matches;

  SaveMatchReportUseCase(this._goals, this._cards, this._matches);

  Future<Either<Failure, ({MatchDTO match, int publishedCards})>> call({
    required MatchDTO original,
    required List<MatchGoal> goalsBefore,
    required MatchDTO edited,
    bool publishCards = true,
    String? season,
  }) async {
    var saved = edited;
    var published = 0;
    final goalsChanged = goalsBefore.length != edited.goals.length ||
        [for (var i = 0; i < goalsBefore.length; i++) goalsBefore[i] == edited.goals[i]].contains(false);
    if (goalsChanged) {
      final goals = await _goals(match: original, before: goalsBefore, after: edited.goals, season: season);
      if (goals.isLeft) return Left(goals.left);
      saved = edited.copyWith(homeGoals: goals.right.homeGoals, awayGoals: goals.right.awayGoals);
      if (publishCards) {
        final cards = await _cards(match: original, before: goalsBefore, after: edited.goals, season: season);
        published = cards.fold((_) => -1, (count) => count);
      }
    }
    final report = await _matches.updateReport(saved, season: season);
    if (report.isLeft) return Left(report.left);
    return Right((match: saved, publishedCards: published));
  }
}
