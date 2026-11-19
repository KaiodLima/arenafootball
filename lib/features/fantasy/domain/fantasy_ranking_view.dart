import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';

/// Quem a conta persegue no ranking: o mais perto com mais pontos.
class FantasyChase {
  final String name;
  final double gap;

  /// 0..1: os pontos da conta em relação aos do perseguido.
  final double progress;

  const FantasyChase({required this.name, required this.gap, required this.progress});
}

/// Contas puras das telas de ranking do Fantasy (sem leitura nova: só as
/// entradas já carregadas no `FantasyRankingState`).
class FantasyRankingView {
  const FantasyRankingView._();

  /// Tamanho da página do ranking (top N lido pelo `FantasyDataSource`).
  static const int rankingLimit = 50;

  /// Fração da barra da linha [index]: pontos / pontos do líder (0..1).
  static double barFraction(List<FantasyRankingEntry> entries, int index) {
    if (entries.isEmpty || index < 0 || index >= entries.length) return 0;
    final leader = entries.first.points;
    if (leader <= 0) return 0;
    return (entries[index].points / leader).clamp(0.0, 1.0);
  }

  /// Diferença para quem está logo acima da linha [index] (0 = empate ou o 1º).
  static double gapToAbove(List<FantasyRankingEntry> entries, int index) {
    if (index <= 0 || index >= entries.length) return 0;
    final gap = entries[index - 1].points - entries[index].points;
    return gap > 0 ? gap : 0;
  }

  /// Se a linha [index] divide a posição com outra (empate nos pontos).
  static bool isTied(List<int> positions, int index) {
    if (index < 0 || index >= positions.length) return false;
    final position = positions[index];
    return (index > 0 && positions[index - 1] == position) ||
        (index < positions.length - 1 && positions[index + 1] == position);
  }

  /// O mais perto acima dos [points] da conta [uid] nas [entries] ordenadas
  /// (`sortFantasyRanking`). Nulo = a conta lidera (ou não há ninguém acima).
  /// Fora da lista (além do top), persegue o último com mais pontos.
  static FantasyChase? chase(List<FantasyRankingEntry> entries, String uid, double points) {
    FantasyRankingEntry? target;
    for (final entry in entries) {
      if (entry.uid == uid) continue;
      if (entry.points > points) target = entry;
    }
    if (target == null) return null;
    final gap = target.points - points;
    final progress = target.points <= 0 ? 0.0 : (points / target.points).clamp(0.0, 1.0);
    return FantasyChase(name: target.name, gap: gap, progress: progress);
  }

  /// Participantes mostrados no cabeçalho: as entradas carregadas; se a lista
  /// bateu no limite da consulta, o [total] do campeonato (quando maior).
  static int participants(List<FantasyRankingEntry> entries, {int limit = rankingLimit, int total = 0}) =>
      entries.length >= limit && total > entries.length ? total : entries.length;
}
