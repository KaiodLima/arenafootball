import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Tipo de conflito de um cadastro de partida com as já existentes.
enum MatchConflictType {
  /// Um dos times já joga na mesma data.
  teamSameDay,

  /// O local já tem jogo na mesma data e horário.
  venueTaken,
}

class MatchConflict extends Equatable {
  final MatchConflictType type;

  /// Time (em [MatchConflictType.teamSameDay]) ou local (em
  /// [MatchConflictType.venueTaken]).
  final String subject;

  /// Horários dos jogos que conflitam.
  final List<String> times;

  const MatchConflict({required this.type, required this.subject, required this.times});

  @override
  List<Object?> get props => [type, subject, times];
}

/// Sugestões e checagens do cadastro de partida, tiradas das partidas já
/// cadastradas (funções puras).
class MatchFormHints {
  MatchFormHints._();

  static List<String> _byFrequency(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values.map((v) => v.trim()).where((v) => v.isNotEmpty)) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return entries.map((e) => e.key).toList();
  }

  /// Horários mais usados (os [limit] primeiros), em ordem cronológica.
  static List<String> frequentTimes(List<MatchDTO> matches, {int limit = 4}) =>
      (_byFrequency(matches.map((m) => m.time)).take(limit).toList())..sort();

  /// Locais já usados, do mais usado ao menos usado.
  static List<String> frequentVenues(List<MatchDTO> matches) => _byFrequency(matches.map((m) => m.venue));

  /// Conflitos de [home] x [away] em [date] ("dd/MM") às [time] em [venue].
  static List<MatchConflict> conflicts(
    List<MatchDTO> matches, {
    required String? home,
    required String? away,
    required String date,
    required String time,
    required String venue,
  }) {
    if (date.isEmpty) return const [];
    final sameDay = matches.where((m) => m.date == date).toList();
    final result = <MatchConflict>[];

    for (final team in {home, away}.whereType<String>()) {
      final times = sameDay.where((m) => m.homeTeam == team || m.awayTeam == team).map((m) => m.time).toList()..sort();
      if (times.isNotEmpty) result.add(MatchConflict(type: MatchConflictType.teamSameDay, subject: team, times: times));
    }

    final place = venue.trim();
    if (place.isNotEmpty && time.isNotEmpty) {
      final taken = sameDay.any((m) => m.venue.trim().toLowerCase() == place.toLowerCase() && m.time == time);
      if (taken) result.add(MatchConflict(type: MatchConflictType.venueTaken, subject: place, times: [time]));
    }
    return result;
  }

  /// Atalhos de data: hoje, amanhã e o próximo sábado e domingo (sem repetir).
  static List<DateTime> quickDates(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dates = <DateTime>[today, today.add(const Duration(days: 1))];
    for (final weekday in [DateTime.saturday, DateTime.sunday]) {
      var day = today;
      while (day.weekday != weekday) {
        day = day.add(const Duration(days: 1));
      }
      if (!dates.contains(day)) dates.add(day);
    }
    return dates..sort();
  }
}
