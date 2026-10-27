import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Pedidos "Sou parceiro" pendentes (contador do menu do admin).
class WatchPendingPartnerRequestsCountUseCase {
  final IPartnerRequestsRepository _repository;

  WatchPendingPartnerRequestsCountUseCase(this._repository);

  Stream<Either<Failure, int>> call() => _repository.watchPendingCount();
}
