import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class GetTeamByNameUseCase {
  final ITeamsRepository _repository;

  GetTeamByNameUseCase(this._repository);

  /// Time da temporada atual pelo [id] (o vínculo); sem id (conta ou doc
  /// antigo) ou id que não existe mais, pelo nome.
  Future<Either<Failure, TeamDTO?>> call(String name, {String id = ''}) async {
    if (id.isNotEmpty) {
      final byId = await _repository.getTeam(id: id);
      if (byId.isRight && byId.right != null) return byId;
    }
    return _repository.getTeamByName(name);
  }
}
