import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

class SaveRegionMatchesCacheUseCase {
  final IMatchesRepository _repository;

  SaveRegionMatchesCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<MatchDTO> matches, {required String region, String? season}) =>
      _repository.saveRegionMatchesCache(matches, region: region, season: season);
}
