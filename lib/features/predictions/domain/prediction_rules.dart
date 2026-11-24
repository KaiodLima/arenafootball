import 'package:equatable/equatable.dart';

/// Pontos do bolão (editáveis pelo admin em `config/bolao`): placar exato,
/// vencedor + saldo (ou empate com outro placar) e só o vencedor. Mesmas
/// regras do `predictionRules` das functions (`functions/src/predictions.ts`):
/// inteiros de 0 a 50, exato ≥ saldo ≥ vencedor; inválido = padrões.
class PredictionRules extends Equatable {
  final int exact;
  final int winnerAndDiff;
  final int winner;

  static const int maxValue = 50;

  const PredictionRules({this.exact = 10, this.winnerAndDiff = 7, this.winner = 5});

  static const defaults = PredictionRules();

  bool get isValid => winner >= 0 && exact <= maxValue && exact >= winnerAndDiff && winnerAndDiff >= winner;

  factory PredictionRules.fromMap(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    int pick(String field, int fallback) {
      final value = map[field];
      return value is int && value >= 0 && value <= maxValue ? value : fallback;
    }

    final rules = PredictionRules(
      exact: pick('exato', defaults.exact),
      winnerAndDiff: pick('vencedorSaldo', defaults.winnerAndDiff),
      winner: pick('vencedor', defaults.winner),
    );
    return rules.isValid ? rules : defaults;
  }

  Map<String, dynamic> toMap() => {'exato': exact, 'vencedorSaldo': winnerAndDiff, 'vencedor': winner};

  PredictionRules copyWith({int? exact, int? winnerAndDiff, int? winner}) => PredictionRules(
        exact: (exact ?? this.exact).clamp(0, maxValue),
        winnerAndDiff: (winnerAndDiff ?? this.winnerAndDiff).clamp(0, maxValue),
        winner: (winner ?? this.winner).clamp(0, maxValue),
      );

  @override
  List<Object?> get props => [exact, winnerAndDiff, winner];
}
