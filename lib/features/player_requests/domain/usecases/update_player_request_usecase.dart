import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Admin corrige nome, time ou posição antes de responder.
class UpdatePlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;

  UpdatePlayerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerRequestDTO request) =>
      _repository.update(request.copyWith(name: request.name.trim()));
}
