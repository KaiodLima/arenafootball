import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// O usuário desiste do pedido de time ainda pendente.
class CancelTeamRequestUseCase {
  final ITeamRequestsRepository _repository;

  CancelTeamRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) => _repository.cancel(userId);
}
