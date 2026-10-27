import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';

/// Admin ajusta o que o parceiro pode publicar e os limites.
class UpdatePartnerPermissionsUseCase {
  final IPartnerRequestsRepository _repository;

  UpdatePartnerPermissionsUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId, required PartnerPermissions permissions}) =>
      _repository.updatePermissions(userId: userId, permissions: permissions);
}
