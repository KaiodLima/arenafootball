import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Partidas em que o atleta foi eleito o craque (troféus), na temporada.
class GetPlayerAwardsUseCase {
  final IMatchesRepository _matches;

  GetPlayerAwardsUseCase(this._matches);

  Future<Either<Failure, List<MatchDTO>>> call({required String playerId, String? season}) =>
      _matches.getElectedMatches(playerId: playerId, season: season);
}
