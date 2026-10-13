import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Admin exclui o time da temporada [season] (nulo = atual). Jogadores com
/// conta ficam sem time; os demais saem junto; partidas ficam no histórico.
class DeleteTeamUseCase {
  final ITeamsRepository _repository;

  DeleteTeamUseCase(this._repository);

  Future<Either<Failure, void>> call(TeamDTO team, {String? season}) => _repository.deleteTeam(team, season: season);
}
