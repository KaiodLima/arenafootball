import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Uma temporada no histórico do atleta: o cadastro dele nela e os troféus de
/// craque da partida.
class PlayerSeasonSummary extends Equatable {
  final String season;
  final PlayerDTO player;
  final int awards;

  const PlayerSeasonSummary({required this.season, required this.player, this.awards = 0});

  /// Cache local (ver `CacheStore`).
  factory PlayerSeasonSummary.fromCache(Map<String, dynamic> json) => PlayerSeasonSummary(
        season: json['season']?.toString() ?? '',
        player: PlayerDTO.fromCache(Map<String, dynamic>.from(json['player'] as Map)),
        awards: json['awards'] is num ? (json['awards'] as num).toInt() : 0,
      );

  Map<String, dynamic> toCache() => {'season': season, 'player': player.toCache(), 'awards': awards};

  @override
  List<Object?> get props => [season, player, awards];
}
