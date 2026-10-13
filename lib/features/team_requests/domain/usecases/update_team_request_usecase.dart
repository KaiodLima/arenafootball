import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';

/// Admin corrige nome, região ou descrição antes de responder.
class UpdateTeamRequestUseCase {
  final ITeamRequestsRepository _repository;

  UpdateTeamRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(TeamRequestDTO request) => _repository.update(
        request.copyWith(name: request.name.trim(), description: request.description.trim()),
      );
}
