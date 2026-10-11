import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Partidas de uma mesma data ("dd/MM"). [date] vazio = sem data válida.
class MatchDay extends Equatable {
  final String date;
  final List<MatchDTO> matches;

  const MatchDay({required this.date, required this.matches});

  @override
  List<Object?> get props => [date, matches];
}

/// Agrupa por data, da mais recente para a mais antiga; dentro do dia, pelo
/// horário. A data é texto "dd/MM" (sem ano): só dá para ordenar por mês/dia
/// dentro da temporada. Datas que não seguem o formato vão para um grupo
/// final sem data.
List<MatchDay> groupMatchesByDate(List<MatchDTO> matches) {
  final byDate = <String, List<MatchDTO>>{};
  for (final match in matches) {
    final key = _sortKey(match.date) == null ? '' : match.date.trim();
    byDate.putIfAbsent(key, () => []).add(match);
  }

  final dates = byDate.keys.toList()
    ..sort((a, b) {
      final ka = _sortKey(a);
      final kb = _sortKey(b);
      if (ka == null) return kb == null ? 0 : 1;
      if (kb == null) return -1;
      return kb.compareTo(ka);
    });

  return [
    for (final date in dates)
      MatchDay(
        date: date,
        matches: [...byDate[date]!]..sort((a, b) => _minutes(a.time).compareTo(_minutes(b.time))),
      ),
  ];
}

/// "dd/MM" → mês * 100 + dia; null se inválida.
int? _sortKey(String date) {
  final parts = date.trim().split('/');
  if (parts.length < 2) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (day == null || month == null || day < 1 || day > 31 || month < 1 || month > 12) return null;
  return month * 100 + day;
}

/// "HH:mm" → minutos do dia; sem horário válido vai para o fim do dia.
int _minutes(String time) {
  final parts = time.trim().split(':');
  final hour = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
  if (hour == null || minute == null) return 24 * 60;
  return hour * 60 + minute;
}

/// Totais de um recorte de partidas.
class MatchesSummary extends Equatable {
  final int games;
  final int goals;

  const MatchesSummary({required this.games, required this.goals});

  factory MatchesSummary.of(List<MatchDTO> matches) => MatchesSummary(
        games: matches.length,
        goals: matches.fold(0, (sum, match) => sum + match.homeGoals + match.awayGoals),
      );

  /// Gols por jogo (0 sem jogos).
  double get average => games == 0 ? 0 : goals / games;

  @override
  List<Object?> get props => [games, goals];
}
