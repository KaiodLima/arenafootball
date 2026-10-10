import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Número sequencial do próximo time: total de times da temporada corrente
/// (todas as regiões) + 1. Compõe o id do time (`{número}_{Nome_Do_Time}`).
class GetNextTeamNumberUseCase {
  final ITeamsRepository _repository;

  GetNextTeamNumberUseCase(this._repository);

  Future<Either<Failure, int>> call() async {
    final response = await _repository.countTeams();
    return response.map((count) => count + 1);
  }
}
