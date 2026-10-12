import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Pedido "Sou dono de time" do usuário em tempo real (`null` se não pediu).
class WatchMyTeamRequestUseCase {
  final ITeamRequestsRepository _repository;

  WatchMyTeamRequestUseCase(this._repository);

  Stream<Either<Failure, TeamRequestDTO?>> call(String userId) => _repository.watchMyRequest(userId);
}
