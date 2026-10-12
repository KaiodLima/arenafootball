import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

abstract class IPlayerRequestsRepository {
  Stream<Either<Failure, PlayerRequestDTO?>> watchMyRequest(String userId);

  Future<Either<Failure, void>> submit(PlayerRequestDTO request);

  Future<Either<Failure, void>> cancel(String userId);

  Stream<Either<Failure, List<PlayerRequestDTO>>> watchRequests();

  Stream<Either<Failure, int>> watchPendingCount();

  Stream<Either<Failure, List<PlayerRequestDTO>>> watchTeamRequests(String team);

  Future<Either<Failure, void>> update(PlayerRequestDTO request);

  /// Devolve o id do jogador criado.
  Future<Either<Failure, String>> approve(PlayerRequestDTO request);

  Future<Either<Failure, void>> reject({required String userId, required String reason});
}
