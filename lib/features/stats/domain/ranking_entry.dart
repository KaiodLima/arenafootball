import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

/// Um jogador no ranking, com o valor que conta e a posição (empates dividem
/// a posição).
class RankingEntry extends Equatable {
  final PlayerDTO player;
  final int value;
  final int position;

  const RankingEntry({required this.player, required this.value, required this.position});

  /// Cache local (ver `CacheStore`).
  factory RankingEntry.fromCache(Map<String, dynamic> json) => RankingEntry(
        player: PlayerDTO.fromCache(Map<String, dynamic>.from(json['player'] as Map)),
        value: (json['value'] as num?)?.toInt() ?? 0,
        position: (json['position'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toCache() => {'player': player.toCache(), 'value': value, 'position': position};

  @override
  List<Object?> get props => [player, value, position];
}

/// Resultado do ranking: as entradas em ordem e os escudos dos times da
/// região (nome do time → URL), para não reler a coleção de times na UI.
class StatsRanking extends Equatable {
  final List<RankingEntry> entries;
  final Map<String, String> crests;

  const StatsRanking({this.entries = const [], this.crests = const {}});

  /// Cache local (ver `CacheStore`).
  factory StatsRanking.fromCache(Map<String, dynamic> json) => StatsRanking(
        entries: [
          for (final item in (json['entries'] as List?) ?? const [])
            RankingEntry.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
        crests: {
          for (final entry in ((json['crests'] as Map?) ?? const {}).entries)
            entry.key.toString(): entry.value.toString(),
        },
      );

  Map<String, dynamic> toCache() => {
        'entries': [for (final entry in entries) entry.toCache()],
        'crests': crests,
      };

  @override
  List<Object?> get props => [entries, crests];
}

/// Posições no estilo "competition ranking" (1, 1, 3…): quem empata com o
/// anterior herda a posição dele. [players] já vem ordenado de forma
/// decrescente pelo quesito.
List<RankingEntry> buildRanking(List<PlayerDTO> players, StatsRankingType type) {
  final entries = <RankingEntry>[];
  for (var i = 0; i < players.length; i++) {
    final value = type.valueOf(players[i]);
    final tied = entries.isNotEmpty && entries.last.value == value;
    entries.add(RankingEntry(player: players[i], value: value, position: tied ? entries.last.position : i + 1));
  }
  return entries;
}
