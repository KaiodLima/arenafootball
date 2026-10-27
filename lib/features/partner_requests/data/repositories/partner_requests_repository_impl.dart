import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/partner_requests/data/datasources/partner_requests_datasource.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

class PartnerRequestsRepositoryImpl implements IPartnerRequestsRepository {
  final PartnerRequestsDataSource _dataSource;
  final CacheStore _cache;

  PartnerRequestsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, PartnerRequestDTO?>> watchMyRequest(String userId) => _dataSource.watchMyRequest(userId);

  @override
  Future<Either<Failure, void>> submit(PartnerRequestDTO request) => _dataSource.submit(request);

  @override
  Future<Either<Failure, void>> cancel(String userId) => _dataSource.cancel(userId);

  @override
  Stream<Either<Failure, List<PartnerRequestDTO>>> watchRequests() => _dataSource.watchRequests();

  @override
  Stream<Either<Failure, int>> watchPendingCount() => _dataSource.watchPendingCount();

  @override
  Future<Either<Failure, void>> answer({
    required String userId,
    required PlayerRequestStatus status,
    String reason = '',
    PartnerPermissions? permissions,
  }) =>
      _dataSource.answer(userId: userId, status: status, reason: reason, permissions: permissions);

  @override
  Future<Either<Failure, void>> updatePermissions({required String userId, required PartnerPermissions permissions}) =>
      _dataSource.updatePermissions(userId: userId, permissions: permissions);

  @override
  Future<Either<Failure, void>> setHighlightClaims({required String userId, required List<String> ids}) =>
      _dataSource.setHighlightClaims(userId: userId, ids: ids);

  @override
  Future<Either<Failure, int>> linkHighlights(PartnerRequestDTO request) async {
    final response = await _dataSource.linkHighlights(request);
    // Os destaques mudaram de id: o cache deles fica velho.
    if (response.isRight) await _cache.delete(CacheKeys.highlights);
    return response;
  }

  @override
  Future<Either<Failure, Set<String>>> existingIds({required String collection, required List<String> ids}) =>
      _dataSource.existingIds(collection: collection, ids: ids);
}
