import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';

/// Região escolhida ou o app inteiro.
enum FanRankingScope { region, overall }

/// Uma fatia da "Divisão das torcidas" (time ou "Outros", [entry] nulo).
class FanSlice {
  final FanRankingEntry? entry;
  final int fans;

  /// Fração (0–1) do total.
  final double share;

  const FanSlice({required this.entry, required this.fans, required this.share});

  bool get isOthers => entry == null;
}

/// Contas puras da tela "Guerra das torcidas".
abstract final class FanRankingView {
  /// Todos os times do app, do maior para o menor (empate: a ordem do doc).
  static List<FanRankingEntry> overall(FanRankingDTO? ranking) {
    final list = [...?ranking?.entries];
    final order = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final byFans = b.fans.compareTo(a.fans);
      return byFans != 0 ? byFans : order[a]!.compareTo(order[b]!);
    });
    return list;
  }

  static int total(List<FanRankingEntry> entries) => entries.fold(0, (sum, e) => sum + e.fans);

  /// Percentual inteiro de [fans] em [total]; sem total, 0.
  static int percent(int fans, int total) => total == 0 ? 0 : (fans * 100 / total).round();

  /// Os [top] maiores (com torcedores) e "Outros" com o resto; sem ninguém, vazio.
  static List<FanSlice> slices(List<FanRankingEntry> entries, {int top = 5}) {
    final sum = total(entries);
    if (sum == 0) return const [];
    final withFans = entries.where((e) => e.fans > 0).toList();
    final shown = withFans.take(top).toList();
    final rest = sum - total(shown);
    return [
      for (final e in shown) FanSlice(entry: e, fans: e.fans, share: e.fans / sum),
      if (rest > 0) FanSlice(entry: null, fans: rest, share: rest / sum),
    ];
  }

  /// Os que dividem o topo (mesmo número de torcedores do 1º, que tem algum).
  static List<FanRankingEntry> leaders(List<FanRankingEntry> entries) {
    if (entries.isEmpty || entries.first.fans == 0) return const [];
    return entries.where((e) => e.fans == entries.first.fans).toList();
  }

  /// Quem está logo acima de [mine] e quantos torcedores faltam para passar
  /// (um a mais); no topo (ou empatado nele), nulo.
  static ({FanRankingEntry team, int gap})? gapToNext(List<FanRankingEntry> entries, FanRankingEntry mine) {
    FanRankingEntry? above;
    for (final e in entries) {
      if (e == mine) continue;
      if (e.fans > mine.fans && (above == null || e.fans < above.fans)) above = e;
    }
    if (above == null) return null;
    return (team: above, gap: above.fans - mine.fans + 1);
  }
}
