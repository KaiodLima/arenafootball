import 'package:flutter/widgets.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/navigation/route_stack.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Abre o elenco do time (`arguments['team']`) ou volta até ele, se já
/// estiver aberto (ex.: Time → Atleta → chip do time).
Future<void> openTeamRoster(BuildContext context, Map<String, dynamic> arguments) {
  final team = arguments['team'] as TeamDTO;
  return openOrReturn(
    context,
    AppRoutes.teamPlayersPage,
    arguments: arguments,
    same: (other) {
      final open = other is Map ? other['team'] : null;
      return open is TeamDTO && sameTeam(idA: open.id, nameA: open.name, idB: team.id, nameB: team.name);
    },
  );
}

/// Abre a tela do atleta (`arguments['playerId']`) ou volta até ela, se já
/// estiver aberta (ex.: Atleta → Time → o mesmo atleta).
Future<void> openAthlete(BuildContext context, Map<String, dynamic> arguments) {
  final playerId = arguments['playerId'];
  return openOrReturn(
    context,
    AppRoutes.playerProfilePage,
    arguments: arguments,
    same: (other) => other is Map && other['playerId'] == playerId,
  );
}
