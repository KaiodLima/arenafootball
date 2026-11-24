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

  /// Por gol da equipe com o atleta em campo, pela posição.
  static const Map<FantasySlot, double> teamGoal = {
    FantasySlot.goalkeeper: 0.5,
    FantasySlot.defender: 0.5,
    FantasySlot.midfielder: 0.5,
    FantasySlot.forward: 0.5,
  };

  /// Gols da equipe pela posição (nulo = não vale).
  static double? teamGoalsFor(FantasySlot slot) => teamGoal[slot];

  /// "+5", "−3" (sinal de menos de verdade), "+0,5" ou "0"; [decimal] = separador.
  static String signed(num value, {String decimal = ','}) {
    final abs = value.abs();
    final text = abs == abs.roundToDouble() ? abs.round().toString() : abs.toString().replaceAll('.', decimal);
    if (value > 0) return '+$text';
    if (value < 0) return '−$text';
    return '0';
  }
}
