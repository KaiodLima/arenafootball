import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Tempo de jogo do relógio.
enum MatchClockPhase { firstHalf, halfTime, secondHalf }

/// Relógio estimado da partida em andamento (local, sem leitura nova):
/// 1º tempo a partir do início (`inicioEm` do admin ou o horário da partida),
/// parado no intervalo e, no 2º tempo, a partir da metade da duração (o 45 de
/// uma partida de 90). Sem nada marcado pelo admin, vira 2º tempo sozinho
/// passada a metade (relógio contínuo). Não conta pausas: é uma estimativa.
class MatchClock {
  final MatchClockPhase phase;

  /// Minuto corrente (1 em diante); nulo no intervalo ou sem início conhecido.
  final int? minute;

  /// Metade da duração (fim do 1º tempo) e a duração.
  final int half;
  final int duration;

  const MatchClock({required this.phase, required this.minute, required this.half, required this.duration});

  /// Acréscimo máximo do 1º tempo sem o admin marcar o intervalo; passou
  /// disso, o relógio segue no 2º tempo contínuo.
  static const int firstHalfStoppageLimit = 10;

  /// Pausa suposta do intervalo (fim esperado de quem ficou no intervalo).
  static const Duration halfTimeBreak = Duration(minutes: 15);

  /// Folga depois do fim esperado: partida iniciada na mão e esquecida em
  /// andamento/intervalo é encerrada sozinha (app e functions).
  static const Duration autoFinishMargin = Duration(minutes: 30);

  /// Início marcado pelo admin (partida antiga: o `statusEm` de quando iniciou).
  static DateTime? manualStartOf(MatchDTO match) =>
      match.startedAt ?? (match.manualStatus == MatchManualStatus.live ? match.statusAt : null);

  /// Fim esperado: 2º tempo marcado + o que falta; no intervalo, a pausa + o
  /// 2º tempo; iniciada na mão + duração; senão, horário + duração.
  static DateTime? expectedEnd(MatchDTO match, DateTime now) {
    final duration = match.durationMinutes;
    final secondHalfLength = Duration(minutes: duration - (duration / 2).round());
    final secondHalf = match.secondHalfAt;
    if (secondHalf != null) return secondHalf.add(secondHalfLength);
    final halfTimeAt = match.halfTimeAt;
    if (match.manualStatus == MatchManualStatus.halfTime && halfTimeAt != null) {
      return halfTimeAt.add(halfTimeBreak).add(secondHalfLength);
    }
    final start = manualStartOf(match) ?? kickoffOf(match, now);
    return start?.add(Duration(minutes: duration));
  }

  /// "23'", com acréscimos "45+2'" (1º tempo) e "90+3'" (2º tempo); nulo no intervalo.
  String? get minuteLabel {
    final m = minute;
    if (m == null) return null;
    final limit = phase == MatchClockPhase.firstHalf ? half : duration;
    return m > limit ? "$limit+${m - limit}'" : "$m'";
  }

  static int _elapsed(DateTime from, DateTime now) {
    final minutes = now.difference(from).inMinutes;
    return minutes < 0 ? 1 : minutes + 1;
  }

  /// Hora marcada da partida ("dd/MM" ou "dd/MM/aaaa" + "HH:mm"), no fuso do aparelho.
  static DateTime? kickoffOf(MatchDTO match, DateTime now) {
    final date = match.date.split('/');
    final time = match.time.split(':');
    final day = int.tryParse(date.first.trim());
    final month = date.length > 1 ? int.tryParse(date[1].trim()) : null;
    final year = date.length > 2 ? int.tryParse(date[2].trim()) : null;
    final hour = int.tryParse(time.first.trim());
    final minute = time.length > 1 ? int.tryParse(time[1].trim()) : 0;
    if (day == null || month == null || hour == null || minute == null) return null;
    return DateTime(year ?? now.year, month, day, hour, minute);
  }

  static MatchClock of(MatchDTO match, DateTime now) {
    final duration = match.durationMinutes;
    final half = (duration / 2).round();
    MatchClock clock(MatchClockPhase phase, int? minute) =>
        MatchClock(phase: phase, minute: minute, half: half, duration: duration);

    if (match.manualStatus == MatchManualStatus.halfTime) return clock(MatchClockPhase.halfTime, null);
    final secondHalf = match.secondHalfAt;
    if (secondHalf != null) return clock(MatchClockPhase.secondHalf, half + _elapsed(secondHalf, now));

    final manualStart = manualStartOf(match);
    final start = manualStart ?? kickoffOf(match, now);
    if (start == null) return clock(MatchClockPhase.firstHalf, null);
    final minute = _elapsed(start, now);
    // Automático (admin não mexeu): passada a metade, 2º tempo contínuo. Com
    // início manual, o 1º tempo tem acréscimo até +10 sem o intervalo marcado.
    final limit = manualStart == null ? half : half + firstHalfStoppageLimit;
    if (minute > limit) return clock(MatchClockPhase.secondHalf, minute);
    return clock(MatchClockPhase.firstHalf, minute);
  }
}
