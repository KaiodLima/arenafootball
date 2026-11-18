import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Atleta elegível no Fantasy de uma competição: o cadastro oficial
/// (`jogadores{ano}`) com a inscrição daquela competição (time e números).
class FantasyAthleteDTO extends Equatable {
  final String id;
  final String name;
  final String photoUrl;

  /// Posição do cadastro (`goleiro`, `lateral`...).
  final String position;
  final String teamId;
  final String team;
  final int goals;
  final int assists;

  const FantasyAthleteDTO({
    required this.id,
    required this.name,
    this.photoUrl = '',
    required this.position,
    required this.teamId,
    this.team = '',
    this.goals = 0,
    this.assists = 0,
  });

  /// Vaga fixa do atleta (GOL/ZAG/MEI/ATA).
  FantasySlot? get slot => fantasySlotOf(position);

  /// Do [player] inscrito na competição [championshipId] com time e posição;
  /// sem isso, nulo (fora do Fantasy).
  static FantasyAthleteDTO? of(PlayerDTO player, int championshipId) {
    final enrollment = player.enrollmentIn(championshipId);
    if (enrollment == null || enrollment.teamId.isEmpty || fantasySlotOf(player.position) == null) return null;
    return FantasyAthleteDTO(
      id: player.id,
      name: player.name,
      photoUrl: player.imageUrl,
      position: player.position.trim().toLowerCase(),
      teamId: enrollment.teamId,
      team: enrollment.team,
      goals: enrollment.goals,
      assists: enrollment.assists,
    );
  }

  Map<String, dynamic> toCache() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'position': position,
        'teamId': teamId,
        'team': team,
        'goals': goals,
        'assists': assists,
      };

  factory FantasyAthleteDTO.fromCache(Map<String, dynamic> json) => FantasyAthleteDTO(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        photoUrl: json['photoUrl']?.toString() ?? '',
        position: json['position']?.toString() ?? '',
        teamId: json['teamId']?.toString() ?? '',
        team: json['team']?.toString() ?? '',
        goals: (json['goals'] as num?)?.toInt() ?? 0,
        assists: (json['assists'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [id, name, photoUrl, position, teamId, team, goals, assists];
}
