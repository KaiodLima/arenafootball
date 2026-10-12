import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';

/// Pedido de time do usuário logado. Aprovado, diz de qual time ele é dono.
class OwnedTeamState extends Equatable {
  final TeamRequestDTO? request;

  const OwnedTeamState({this.request});

  /// Nome do time do qual o usuário é dono (nulo se não é dono).
  String? get teamName => request != null && request!.isApproved ? request!.name : null;

  bool owns(String team) => teamName != null && team.isNotEmpty && teamName == team;

  @override
  List<Object?> get props => [request];
}
