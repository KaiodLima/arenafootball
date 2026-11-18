import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// Sigla da vaga no campinho ("GOL", "ZAG", "MEI", "ATA", "LIVRE").
String fantasySlotLabel(AppLocalizations l10n, FantasySlot slot) => switch (slot) {
      FantasySlot.goalkeeper => l10n.fantasySlotGoalkeeper,
      FantasySlot.defender => l10n.fantasySlotDefender,
      FantasySlot.midfielder => l10n.fantasySlotMidfielder,
      FantasySlot.forward => l10n.fantasySlotForward,
      FantasySlot.flex => l10n.fantasySlotFlex,
    };

/// Título da folha de atletas da vaga.
String fantasyPickTitle(AppLocalizations l10n, FantasySlot slot) => switch (slot) {
      FantasySlot.goalkeeper => l10n.fantasyPickGoalkeeper,
      FantasySlot.defender => l10n.fantasyPickDefender,
      FantasySlot.midfielder => l10n.fantasyPickMidfielder,
      FantasySlot.forward => l10n.fantasyPickForward,
      FantasySlot.flex => l10n.fantasyPickFlex,
    };

/// Sigla da posição do atleta (a vaga fixa dele).
String fantasyPositionLabel(AppLocalizations l10n, String position) {
  final slot = fantasySlotOf(position);
  return slot == null ? '' : fantasySlotLabel(l10n, slot);
}

/// "Fecha em 2d 4h" / "3h 20min" / "12min" até [closesAt].
String fantasyDeadlineLabel(AppLocalizations l10n, DateTime closesAt, DateTime now) {
  final left = closesAt.difference(now);
  if (left.isNegative) return l10n.fantasyRoundLocked;
  final days = left.inDays;
  final hours = left.inHours % 24;
  final minutes = left.inMinutes % 60;
  final text = days > 0
      ? '${days}d ${hours}h'
      : left.inHours > 0
          ? '${left.inHours}h ${minutes}min'
          : '${left.inMinutes < 1 ? 1 : left.inMinutes}min';
  return l10n.fantasyClosesIn(text);
}
