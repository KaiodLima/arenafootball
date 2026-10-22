import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Admin: inicia ([live] = true) ou encerra a partida na mão.
class SetMatchStatusUseCase {
  final IMatchesRepository _repository;

  SetMatchStatusUseCase(this._repository);

  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, required bool live, String? season}) async {
    final status = live ? MatchManualStatus.live : MatchManualStatus.finished;
    final response = await _repository.setManualStatus(matchId: match.id, status: status, season: season);
    return response.map((_) => match.copyWith(manualStatus: status));
  }
}
