import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Todos os pedidos de time, mais recentes primeiro (painel do admin).
class WatchTeamRequestsUseCase {
  final ITeamRequestsRepository _repository;

  WatchTeamRequestsUseCase(this._repository);

  Stream<Either<Failure, List<TeamRequestDTO>>> call() => _repository.watchRequests();
}
