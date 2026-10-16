import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class SaveRegionChampionshipsCacheUseCase {
  final IChampionshipsRepository _repository;

  SaveRegionChampionshipsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<ChampionshipDTO> championships, {required String region, required String season}) =>
      _repository.saveRegionChampionshipsCache(championships, region: region, season: season);
}
