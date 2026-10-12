import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Pedido "Sou jogador" do usuário em tempo real (`null` se não pediu).
class WatchMyPlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;

  WatchMyPlayerRequestUseCase(this._repository);

  Stream<Either<Failure, PlayerRequestDTO?>> call(String userId) => _repository.watchMyRequest(userId);
}
