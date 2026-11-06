import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/organizer_requests/data/datasources/organizer_requests_datasource.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/repositories/organizer_requests_repository_interface.dart';

class OrganizerRequestsRepositoryImpl implements IOrganizerRequestsRepository {
  final OrganizerRequestsDataSource _dataSource;
  final IChampionshipsRepository _championships;

  OrganizerRequestsRepositoryImpl(this._dataSource, this._championships);

  @override
  Stream<Either<Failure, OrganizerRequestDTO?>> watchMyRequest(String userId) => _dataSource.watchMyRequest(userId);

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchMyChampionships(String userId) =>
      _dataSource.watchMyChampionships(userId);

  @override
  Future<Either<Failure, void>> submit(OrganizerRequestDTO request) => _dataSource.submit(request);

  @override
  Future<Either<Failure, void>> cancel(String userId) => _dataSource.cancel(userId);

  @override
  Stream<Either<Failure, List<OrganizerRequestDTO>>> watchRequests() => _dataSource.watchRequests();

  @override
  Future<Either<Failure, void>> update(OrganizerRequestDTO request) => _dataSource.update(request);

  /// Campeonato novo: o cache das competições fica velho.
  @override
  Future<Either<Failure, ChampionshipDTO>> approve({
    required OrganizerRequestDTO request,
    required ChampionshipDTO championship,
  }) async {
    final response = await _dataSource.approve(request: request, championship: championship);
    if (response.isRight) await _championships.deleteChampionshipsCache();
    return response;
  }

  @override
  Future<Either<Failure, void>> reject({required String userId, required String reason}) =>
      _dataSource.reject(userId: userId, reason: reason);
}
