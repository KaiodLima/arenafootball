import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/datasources/player_requests_datasource.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

class PlayerRequestsRepositoryImpl implements IPlayerRequestsRepository {
  final PlayerRequestsDataSource _dataSource;

  PlayerRequestsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, PlayerRequestDTO?>> watchMyRequest(String userId) => _dataSource.watchMyRequest(userId);

  @override
  Future<Either<Failure, void>> submit(PlayerRequestDTO request) => _dataSource.submit(request);

  @override
  Future<Either<Failure, void>> cancel(String userId) => _dataSource.cancel(userId);

  @override
  Stream<Either<Failure, List<PlayerRequestDTO>>> watchRequests() => _dataSource.watchRequests();

  @override
  Stream<Either<Failure, int>> watchPendingCount() => _dataSource.watchPendingCount();

  @override
  Stream<Either<Failure, List<PlayerRequestDTO>>> watchTeamRequests(String team) =>
      _dataSource.watchTeamRequests(team);

  @override
  Future<Either<Failure, void>> update(PlayerRequestDTO request) => _dataSource.update(request);

  @override
  Future<Either<Failure, String>> approve(PlayerRequestDTO request) => _dataSource.approve(request);

  @override
  Future<Either<Failure, void>> reject({required String userId, required String reason}) =>
      _dataSource.reject(userId: userId, reason: reason);
}
