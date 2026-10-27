import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Pedido "Sou parceiro" do usuário em tempo real (`null` se não pediu).
class WatchMyPartnerRequestUseCase {
  final IPartnerRequestsRepository _repository;

  WatchMyPartnerRequestUseCase(this._repository);

  Stream<Either<Failure, PartnerRequestDTO?>> call(String userId) => _repository.watchMyRequest(userId);
}
