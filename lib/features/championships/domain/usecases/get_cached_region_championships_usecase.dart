import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Campeonatos da região do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedRegionChampionshipsUseCase {
  final IChampionshipsRepository _repository;

  GetCachedRegionChampionshipsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<ChampionshipDTO>>?>> call({required String region, required String season}) =>
      _repository.getCachedRegionChampionships(region: region, season: season);
}
