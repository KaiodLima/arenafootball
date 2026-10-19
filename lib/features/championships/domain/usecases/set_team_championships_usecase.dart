import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Inscreve o time nas competições [selected] (`id_campeonato`) entre as
/// [championships] oferecidas e tira das desmarcadas; grava só o que mudou.
/// Só o time entra: os atletas são inscritos um a um.
class SetTeamChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  SetTeamChampionshipsUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required TeamDTO team,
    required List<ChampionshipDTO> championships,
    required Set<int> selected,
  }) async {
    for (final championship in championships) {
      final enrolled = selected.contains(championship.championshipId);
      if (enrolled == championship.hasTeam(id: team.id, name: team.name)) continue;
      final response =
          await _repository.setTeamEnrollment(championshipDocId: championship.id, team: team, enrolled: enrolled);
      if (response.isLeft) return Left(response.left);
    }
    return const Right(null);
  }
}
