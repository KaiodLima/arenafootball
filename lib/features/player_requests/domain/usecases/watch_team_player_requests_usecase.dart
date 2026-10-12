import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Pedidos "Sou jogador" para um time (o dono aprova/rejeita).
class WatchTeamPlayerRequestsUseCase {
  final IPlayerRequestsRepository _repository;

  WatchTeamPlayerRequestsUseCase(this._repository);

  Stream<Either<Failure, List<PlayerRequestDTO>>> call(String team) => _repository.watchTeamRequests(team);
}
