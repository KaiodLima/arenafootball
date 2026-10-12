import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Rejeita o pedido, com motivo opcional (o usuário vê o motivo).
class RejectPlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;

  RejectPlayerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId, String reason = ''}) =>
      _repository.reject(userId: userId, reason: reason.trim());
}
