import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// "Placar exato: 10 pts · vencedor e saldo: 7 · vencedor: 5" pelas [rules].
String predictionRulesText(AppLocalizations l10n, PredictionRules rules) =>
    l10n.predictionRules(rules.exact, rules.winnerAndDiff, rules.winner);
