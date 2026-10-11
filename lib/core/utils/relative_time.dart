import 'package:arena_soccer/l10n/app_localizations.dart';

/// "agora", "há 5 min", "há 2 h", "ontem" ou dd/MM.
class RelativeTime {
  static String format(DateTime date, AppLocalizations l10n, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(date);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);

    final today = DateTime(reference.year, reference.month, reference.day);
    final day = DateTime(date.year, date.month, date.day);
    if (today.difference(day).inDays == 1) return l10n.timeYesterday;

    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return date.year == reference.year ? '$dd/$mm' : '$dd/$mm/${date.year}';
  }
}
