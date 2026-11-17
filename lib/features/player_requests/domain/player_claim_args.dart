import 'package:equatable/equatable.dart';

/// Abre o "Sou jogador" já com o atleta sem conta marcado ("É você?" do
/// perfil do atleta): time, região e, se houver, a competição dele no time.
class PlayerClaimArgs extends Equatable {
  final String playerId;
  final String team;
  final String teamId;
  final String region;
  final int? championshipId;

  const PlayerClaimArgs({
    required this.playerId,
    required this.team,
    this.teamId = '',
    required this.region,
    this.championshipId,
  });

  @override
  List<Object?> get props => [playerId, team, teamId, region, championshipId];
}
