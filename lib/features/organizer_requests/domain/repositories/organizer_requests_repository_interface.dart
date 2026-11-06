import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';

abstract class IOrganizerRequestsRepository {
  Stream<Either<Failure, OrganizerRequestDTO?>> watchMyRequest(String userId);

  Stream<Either<Failure, List<ChampionshipDTO>>> watchMyChampionships(String userId);

  Future<Either<Failure, void>> submit(OrganizerRequestDTO request);

  Future<Either<Failure, void>> cancel(String userId);

  Stream<Either<Failure, List<OrganizerRequestDTO>>> watchRequests();

  Future<Either<Failure, void>> update(OrganizerRequestDTO request);

  Future<Either<Failure, ChampionshipDTO>> approve({
    required OrganizerRequestDTO request,
    required ChampionshipDTO championship,
  });

  Future<Either<Failure, void>> reject({required String userId, required String reason});
}
