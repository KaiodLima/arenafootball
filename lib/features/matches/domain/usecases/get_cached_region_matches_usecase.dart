import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Partidas da região do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedRegionMatchesUseCase {
  final IMatchesRepository _repository;

  GetCachedRegionMatchesUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<MatchDTO>>?>> call({required String region, String? season}) =>
      _repository.getCachedRegionMatches(region: region, season: season);
}
