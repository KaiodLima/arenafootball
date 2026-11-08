import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';

/// Gol novo do "Editar placar" com o placar daquele momento (o card mostra
/// 1×0, 2×0, 2×1... na ordem da lista).
typedef GoalCardItem = ({MatchGoal goal, int homeGoals, int awayGoals});

/// O que muda nos cards de gol ao salvar a lista: os gols novos viram card,
/// os removidos perdem o card e os editados (autor/garçom) atualizam o dele.
class GoalCardsPlan {
  final List<GoalCardItem> added;
  final List<MatchGoal> removed;
  final List<MatchGoal> changed;

  const GoalCardsPlan({this.added = const [], this.removed = const [], this.changed = const []});

  bool get isEmpty => added.isEmpty && removed.isEmpty && changed.isEmpty;

  /// Compara a lista de quando abriu ([before]) com a salva ([after]).
  static GoalCardsPlan of(List<MatchGoal> before, List<MatchGoal> after) {
    final previous = {for (final g in before) g.id: g};
    final kept = {for (final g in after) g.id};
    final added = <GoalCardItem>[];
    final changed = <MatchGoal>[];
    var home = 0;
    var away = 0;
    for (final goal in after) {
      goal.side == MatchSide.home ? home++ : away++;
      final old = previous[goal.id];
      if (old == null) {
        added.add((goal: goal, homeGoals: home, awayGoals: away));
      } else if (old.scorerId != goal.scorerId || old.assistantId != goal.assistantId) {
        changed.add(goal);
      }
    }
    return GoalCardsPlan(
      added: added,
      removed: [
        for (final g in before)
          if (!kept.contains(g.id)) g
      ],
      changed: changed,
    );
  }
}
