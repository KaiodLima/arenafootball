import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Uma partida ao vivo (detalhes): placar, gols e votação atualizam sozinhos.
/// null = a partida foi apagada.
class WatchMatchUseCase {
  final IMatchesRepository _repository;

  WatchMatchUseCase(this._repository);

  Stream<Either<Failure, MatchDTO?>> call({required String matchId, String? season}) =>
      _repository.watchMatch(matchId: matchId, season: season);
}
