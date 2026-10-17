import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// "30/10/2026" no idioma do app.
String teamChangeDate(BuildContext context, DateTime date) =>
    DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(date);

/// Aviso de troca de time antes do prazo de 15 dias ([nextAt] nulo = sem data).
Future<void> showTeamChangeLocked(BuildContext context, DateTime? nextAt) {
  final l10n = AppLocalizations.of(context);
  return showArenaNotice(
    context,
    title: l10n.teamChangeLockedTitle,
    message: nextAt == null
        ? l10n.teamChangeLockedMessageNoDate
        : l10n.teamChangeLockedMessage(teamChangeDate(context, nextAt)),
    icon: Icons.lock_clock_outlined,
  );
}
