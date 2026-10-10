import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

class DeleteMatchUseCase {
  final IMatchesRepository _repository;

  DeleteMatchUseCase(this._repository);

  Future<Either<Failure, void>> call({required String matchId, String? season}) =>
      _repository.deleteMatch(matchId: matchId, season: season);
}
