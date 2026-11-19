import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';

/// Tabela de pontos do Arena Fantasy mostrada na tela de regras.
/// Espelha POINTS em functions/src/fantasy_scoring.ts: mude junto.
class FantasyScoringRules {
  const FantasyScoringRules._();

  static const int base = 10;
  static const int goal = 5;
  static const int assist = 5;
  static const int win = 3;
  static const int draw = 0;
  static const int loss = -3;
  static const int yellow = -3;
  static const int red = -5;

  /// Por gol sofrido com o atleta em campo, pela posição.
  static const Map<FantasySlot, int> conceded = {
    FantasySlot.goalkeeper: -3,
    FantasySlot.defender: -2,
    FantasySlot.midfielder: -1,
    FantasySlot.forward: -1,
  };

  /// Bônus de sem sofrer gols, pela posição.
  static const Map<FantasySlot, int> cleanSheet = {
    FantasySlot.goalkeeper: 5,
    FantasySlot.defender: 3,
    FantasySlot.midfielder: 2,
    FantasySlot.forward: 2,
  };

  /// Meio-campista: por gol da equipe com ele em campo.
  static const int teamGoalMidfielder = 1;

  /// Gols da equipe pela posição (só o MEI pontua; nulo = não vale).
  static int? teamGoalsFor(FantasySlot slot) => slot == FantasySlot.midfielder ? teamGoalMidfielder : null;

  /// "+5", "−3" (sinal de menos de verdade) ou "0".
  static String signed(int value) {
    if (value > 0) return '+$value';
    if (value < 0) return '−${value.abs()}';
    return '0';
  }
}
