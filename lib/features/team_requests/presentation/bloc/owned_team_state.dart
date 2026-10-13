import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';

/// Pedido de time do usuário logado. Aprovado, diz de qual time ele é dono.
class OwnedTeamState extends Equatable {
  final TeamRequestDTO? request;

  const OwnedTeamState({this.request});

  /// Nome do time do qual o usuário é dono (nulo se não é dono).
  String? get teamName => request != null && request!.isApproved ? request!.name : null;

  /// Id do time do qual o usuário é dono ('' se não é dono ou o pedido
  /// ainda não tem o id).
  String get teamId => teamName != null ? request!.teamId : '';

  /// É dono do time de id [id] (ou, sem id no doc antigo, de nome [name])?
  bool owns({String id = '', String name = ''}) =>
      teamName != null && sameTeam(idA: teamId, nameA: teamName!, idB: id, nameB: name);

  @override
  List<Object?> get props => [request];
}
