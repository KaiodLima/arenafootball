import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Todos os pedidos "Sou parceiro" (painel do admin), mais novos primeiro.
class WatchPartnerRequestsUseCase {
  final IPartnerRequestsRepository _repository;

  WatchPartnerRequestsUseCase(this._repository);

  Stream<Either<Failure, List<PartnerRequestDTO>>> call() => _repository.watchRequests();
}
