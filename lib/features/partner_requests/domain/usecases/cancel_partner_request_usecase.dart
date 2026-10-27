import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Desiste do pedido pendente (apaga o doc).
class CancelPartnerRequestUseCase {
  final IPartnerRequestsRepository _repository;

  CancelPartnerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) => _repository.cancel(userId);
}
