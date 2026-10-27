import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Envia (ou reenvia) o pedido "Sou parceiro", sempre como pendente.
class SubmitPartnerRequestUseCase {
  final IPartnerRequestsRepository _repository;

  SubmitPartnerRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(PartnerRequestDTO request) => _repository.submit(request.copyWith(
        name: request.name.trim(),
        contact: request.contact.trim(),
        message: request.message.trim(),
      ));
}
