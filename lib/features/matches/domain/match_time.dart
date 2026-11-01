/// Data e horário das partidas ("dd/MM" + "HH:mm") são sempre de Brasília,
/// qualquer que seja o fuso do aparelho. Mesma conta das functions
/// (`functions/src/voting_close.ts`, `BRASILIA_OFFSET_HOURS`).
class MatchTime {
  MatchTime._();

  /// Brasília não tem horário de verão desde 2019: UTC-3 fixo.
  static const Duration brasiliaOffset = Duration(hours: 3);

  /// Dia de hoje em Brasília no instante [now] (só ano, mês e dia).
  static DateTime today(DateTime now) {
    final local = now.toUtc().subtract(brasiliaOffset);
    return DateTime(local.year, local.month, local.day);
  }

  /// Instante (UTC) da hora de Brasília [hour]:[minute] no dia [year]/[month]/[day].
  static DateTime instant(int year, int month, int day, int hour, int minute) =>
      DateTime.utc(year, month, day, hour, minute).add(brasiliaOffset);
}
