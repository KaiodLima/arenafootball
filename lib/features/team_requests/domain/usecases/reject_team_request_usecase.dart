import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Rejeita o pedido de time, com motivo opcional (o usuário vê o motivo).
class RejectTeamRequestUseCase {
  final ITeamRequestsRepository _repository;

  RejectTeamRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId, String reason = ''}) =>
      _repository.reject(userId: userId, reason: reason.trim());
}
