import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// O usuário desiste do pedido ainda pendente.
class CancelPlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;

  CancelPlayerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) => _repository.cancel(userId);
}
