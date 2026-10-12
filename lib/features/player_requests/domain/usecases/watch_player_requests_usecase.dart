import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Todos os pedidos, mais recentes primeiro (painel do admin).
class WatchPlayerRequestsUseCase {
  final IPlayerRequestsRepository _repository;

  WatchPlayerRequestsUseCase(this._repository);

  Stream<Either<Failure, List<PlayerRequestDTO>>> call() => _repository.watchRequests();
}
