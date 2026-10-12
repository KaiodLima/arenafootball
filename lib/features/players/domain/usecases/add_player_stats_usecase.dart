import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Registra um gol nos números dos jogadores: +1 gol no [scorer] e +1
/// assistência no [assistant] (ambos opcionais). Se forem o mesmo jogador, só
/// o gol conta. Sem nenhum, não grava nada.
class AddPlayerStatsUseCase {
  final IPlayersRepository _repository;

  AddPlayerStatsUseCase(this._repository);

  Future<Either<Failure, void>> call({PlayerDTO? scorer, PlayerDTO? assistant, String? season}) async {
    if (scorer != null) {
      final response = await _repository.incrementStats(playerId: scorer.id, goals: 1, season: season);
      if (response.isLeft) return response;
    }
    if (assistant != null && assistant.id != scorer?.id) {
      return _repository.incrementStats(playerId: assistant.id, assists: 1, season: season);
    }
    return const Right(null);
  }
}
