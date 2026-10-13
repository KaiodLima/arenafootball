import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

abstract class ITeamRequestsRepository {
  Stream<Either<Failure, TeamRequestDTO?>> watchMyRequest(String userId);

  Future<Either<Failure, void>> submit(TeamRequestDTO request);

  Future<Either<Failure, void>> cancel(String userId);

  Stream<Either<Failure, List<TeamRequestDTO>>> watchRequests();

  Stream<Either<Failure, int>> watchPendingCount();

  Future<Either<Failure, void>> update(TeamRequestDTO request);

  Future<Either<Failure, void>> approve({required TeamRequestDTO request, required TeamDTO team});

  Future<Either<Failure, void>> reject({required String userId, required String reason});
}
