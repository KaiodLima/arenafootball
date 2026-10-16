import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

/// Campeonato da região do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedRegionChampionshipUseCase {
  final IChampionshipsRepository _repository;

  GetCachedRegionChampionshipUseCase(this._repository);

  Future<Either<Failure, CachedValue<ChampionshipDTO?>?>> call({required String region, required String season}) =>
      _repository.getCachedRegionChampionship(region: region, season: season);
}
