import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Pedido "Sou jogador" da conta logada. Aprovado, diz em qual time ela joga.
class MyPlayerState extends Equatable {
  final PlayerRequestDTO? request;

  const MyPlayerState({this.request});

  bool get _approved => request != null && request!.status == PlayerRequestStatus.approved;

  /// Time em que a conta joga (nulo se não é jogador aprovado de nenhum).
  String? get teamName => _approved && request!.team.isNotEmpty ? request!.team : null;

  /// Atleta criado na aprovação (para abrir o perfil).
  String? get playerId => _approved && request!.playerId.isNotEmpty ? request!.playerId : null;

  /// Temporada do atleta (o perfil abre na coleção dela).
  String? get season => _approved && request!.season.isNotEmpty ? request!.season : null;

  @override
  List<Object?> get props => [request];
}
