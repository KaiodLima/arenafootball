import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Tipo de ranking: artilharia (gols) ou líderes de assistência.
enum StatsRankingType {
  goals,
  assists;

  /// Valor do jogador que conta para este ranking.
  int valueOf(PlayerDTO player) => this == goals ? player.goals : player.assists;

  /// Campo do Firestore que ordena este ranking.
  String get field => this == goals ? PlayerDTO.goalsField : PlayerDTO.assistsField;
}
