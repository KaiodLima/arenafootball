import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Pedidos "Sou jogador" para um time (o dono aprova/rejeita).
class WatchTeamPlayerRequestsUseCase {
  final IPlayerRequestsRepository _repository;

  WatchTeamPlayerRequestsUseCase(this._repository);

  /// Pelo id do time (com fallback no nome para pedidos antigos).
  Stream<Either<Failure, List<PlayerRequestDTO>>> call({String teamId = '', required String teamName}) =>
      _repository.watchTeamRequests(teamId: teamId, teamName: teamName);
}
