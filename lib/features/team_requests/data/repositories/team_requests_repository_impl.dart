import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/datasources/team_requests_datasource.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class TeamRequestsRepositoryImpl implements ITeamRequestsRepository {
  final TeamRequestsDataSource _dataSource;
  final CacheStore _cache;

  TeamRequestsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, TeamRequestDTO?>> watchMyRequest(String userId) => _dataSource.watchMyRequest(userId);

  @override
  Future<Either<Failure, void>> submit(TeamRequestDTO request) => _dataSource.submit(request);

  @override
  Future<Either<Failure, void>> cancel(String userId) => _dataSource.cancel(userId);

  @override
  Stream<Either<Failure, List<TeamRequestDTO>>> watchRequests() => _dataSource.watchRequests();

  @override
  Stream<Either<Failure, int>> watchPendingCount() => _dataSource.watchPendingCount();

  @override
  Future<Either<Failure, void>> update(TeamRequestDTO request) => _dataSource.update(request);

  @override
  Future<Either<Failure, void>> approve({required TeamRequestDTO request, required TeamDTO team}) async {
    final response = await _dataSource.approve(request: request, team: team);
    // Aprovar cria o time: o cache de times fica velho.
    if (response.isRight) await _cache.deleteWhere(CacheKeys.isTeamKey);
    return response;
  }

  @override
  Future<Either<Failure, void>> reject({required String userId, required String reason}) =>
      _dataSource.reject(userId: userId, reason: reason);
}
