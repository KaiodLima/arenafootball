import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// "Pênalti perdido · defendido por Fulano" / "· defendido" / "· para fora".
String penaltyMissLabel(AppLocalizations l10n, MatchMissedPenalty missed) =>
    '${l10n.reportPenaltyMissed} · ${penaltyMissHow(l10n, missed)}';

/// Só como perdeu: "defendido por Fulano", "defendido" ou "para fora".
String penaltyMissHow(AppLocalizations l10n, MatchMissedPenalty missed) => switch (missed.miss) {
      PenaltyMiss.saved =>
        missed.keeperName.isNotEmpty ? l10n.reportPenaltySavedBy(missed.keeperName) : l10n.reportPenaltySaved,
      PenaltyMiss.wide => l10n.reportPenaltyWide,
    };
