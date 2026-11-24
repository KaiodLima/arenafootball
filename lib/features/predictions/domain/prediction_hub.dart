import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_time.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';

/// Momento de um jogo da aba Palpitar: aberto para palpite ou já começado
/// (fica até terminar, travado).
enum HubMatchPhase { open, live, halfTime, waiting }

/// Contas da central do bolão (puras): início das partidas, "fecha em",
/// quem a conta persegue no ranking e o aproveitamento.
abstract final class PredictionHub {
  /// Partidas da aba "Palpitar" e as candidatas a "Seus últimos palpites".
  static const int upcomingLimit = 6;
  static const int recentCandidates = 8;
  static const int recentLimit = 5;

  /// Pontos de um placar exato (o máximo por palpite).
  static const int maxPointsPerPrediction = 10;

  /// Fase do jogo na aba Palpitar pelo status do card; terminado (ou sem
  /// data para saber) = nulo, fora da lista.
  static HubMatchPhase? phaseOf({
    required bool upcoming,
    required bool live,
    required bool halfTime,
    required bool waiting,
  }) {
    if (halfTime) return HubMatchPhase.halfTime;
    if (live) return HubMatchPhase.live;
    if (waiting) return HubMatchPhase.waiting;
    if (upcoming) return HubMatchPhase.open;
    return null;
  }

  /// Instante (UTC) do início pela data "dd/MM" e o horário "HH:mm" de
  /// Brasília; data sem ano = a mais perto de [now] (janeiro visto em
  /// dezembro é do ano que vem). Sem data ou horário legível, nulo.
  static DateTime? kickoffOf(MatchDTO match, DateTime now) {
    final date = match.date.split('/');
    final day = int.tryParse(date.first.trim());
    final month = date.length > 1 ? int.tryParse(date[1].trim()) : null;
    final explicitYear = date.length > 2 ? int.tryParse(date[2].trim()) : null;
    final time = match.time.split(':');
    final hour = int.tryParse(time.first.trim());
    final minute = time.length > 1 ? int.tryParse(time[1].trim()) : 0;
    if (day == null || month == null || hour == null || minute == null) return null;
    final today = MatchTime.today(now);
    var year = explicitYear ?? today.year;
    if (explicitYear == null) {
      final diff = DateTime.utc(year, month, day).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
      if (diff < -180) year += 1;
      if (diff > 180) year -= 1;
    }
    return MatchTime.instant(year, month, day, hour, minute);
  }

  /// "2d 4h", "5h 20min", "12min" até [kickoff]; já começou = vazio.
  static String closesIn(DateTime kickoff, DateTime now) {
    final left = kickoff.difference(now);
    if (left.isNegative) return '';
    if (left.inDays > 0) return '${left.inDays}d ${left.inHours % 24}h';
    if (left.inHours > 0) return '${left.inHours}h ${left.inMinutes % 60}min';
    return '${left.inMinutes < 1 ? 1 : left.inMinutes}min';
  }

  /// Ordena pelo início (sem início legível, no fim), do mais cedo ao mais tarde.
  static List<MatchDTO> byKickoff(Iterable<MatchDTO> matches, DateTime now, {bool descending = false}) {
    final far = DateTime.utc(9999);
    final list = matches.toList()
      ..sort((a, b) {
        final ka = kickoffOf(a, now) ?? far;
        final kb = kickoffOf(b, now) ?? far;
        return descending ? kb.compareTo(ka) : ka.compareTo(kb);
      });
    return list;
  }

  /// Quem está logo acima da conta (mais pontos) e quantos pontos faltam
  /// para passar; líder ou sem pontos/ranking = nulo.
  static ({String name, int gap})? chase(List<PredictionRankingEntry> top, PredictionRankingEntry? mine) {
    if (mine == null) return null;
    PredictionRankingEntry? above;
    for (final entry in top) {
      if (entry.uid == mine.uid) continue;
      if (entry.points > mine.points && (above == null || entry.points < above.points)) above = entry;
    }
    if (above == null) return null;
    // Passar = ter um ponto a mais.
    return (name: above.name, gap: above.points - mine.points + 1);
  }

  /// Líder: ninguém do ranking com mais pontos (e já pontuou).
  static bool leads(List<PredictionRankingEntry> top, PredictionRankingEntry? mine) =>
      mine != null && mine.points > 0 && top.every((e) => e.uid == mine.uid || e.points <= mine.points);

  /// Aproveitamento (0–1): pontos ÷ máximo possível pelos palpites.
  static double hitRate(PredictionRankingEntry entry, {int maxPoints = maxPointsPerPrediction}) =>
      entry.count == 0 || maxPoints <= 0 ? 0 : (entry.points / (entry.count * maxPoints)).clamp(0.0, 1.0);
}
