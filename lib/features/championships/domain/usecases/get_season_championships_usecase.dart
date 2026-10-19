import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Competições da temporada (todas as regiões).
class GetSeasonChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  GetSeasonChampionshipsUseCase(this._repository);

  Future<Either<Failure, List<ChampionshipDTO>>> call(String season) => _repository.getSeasonChampionships(season);

  /// Em quais o [team] pode jogar: as municipais da região dele e todas as
  /// intermunicipais.
  static List<ChampionshipDTO> eligibleFor(List<ChampionshipDTO> championships, TeamDTO team) => championships
      .where((c) => c.isIntermunicipal || c.region.trim().toLowerCase() == team.region.trim().toLowerCase())
      .toList();
}
