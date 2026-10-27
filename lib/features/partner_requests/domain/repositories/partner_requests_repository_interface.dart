import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

abstract class IPartnerRequestsRepository {
  Stream<Either<Failure, PartnerRequestDTO?>> watchMyRequest(String userId);

  Future<Either<Failure, void>> submit(PartnerRequestDTO request);

  Future<Either<Failure, void>> cancel(String userId);

  Stream<Either<Failure, List<PartnerRequestDTO>>> watchRequests();

  Stream<Either<Failure, int>> watchPendingCount();

  Future<Either<Failure, void>> answer({
    required String userId,
    required PlayerRequestStatus status,
    String reason = '',
    PartnerPermissions? permissions,
  });

  Future<Either<Failure, void>> updatePermissions({required String userId, required PartnerPermissions permissions});

  Future<Either<Failure, void>> setHighlightClaims({required String userId, required List<String> ids});

  Future<Either<Failure, int>> linkHighlights(PartnerRequestDTO request);

  Future<Either<Failure, Set<String>>> existingIds({required String collection, required List<String> ids});
}
