import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class SaveRegionChampionshipCacheUseCase {
  final IChampionshipsRepository _repository;

  SaveRegionChampionshipCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(ChampionshipDTO? championship, {required String region, required String season}) =>
      _repository.saveRegionChampionshipCache(championship, region: region, season: season);
}
