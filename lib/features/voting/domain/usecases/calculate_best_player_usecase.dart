import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Apura a votação de uma partida: conta os votos por nome de jogador e
/// devolve o mais votado (`null` sem votos). Empate: fica o primeiro que
/// atingiu o máximo, na ordem dos documentos, como no app antigo.
/// Só lê; não grava o resultado na partida (o app antigo também não gravava).
class CalculateBestPlayerUseCase {
  final IVotingRepository _repository;

  CalculateBestPlayerUseCase(this._repository);

  static ElectedPlayer? countVotes(List<VoteDTO> votes) {
    final counts = <String, int>{};
    final teams = <String, String>{};
    for (final vote in votes) {
      counts[vote.playerName] = (counts[vote.playerName] ?? 0) + 1;
      teams.putIfAbsent(vote.playerName, () => vote.team);
    }

    String? winner;
    var max = 0;
    counts.forEach((name, count) {
      if (count > max) {
        max = count;
        winner = name;
      }
    });
    if (winner == null) return null;
    return ElectedPlayer(playerName: winner!, team: teams[winner] ?? '', votes: max);
  }

  Future<Either<Failure, ElectedPlayer?>> call({required String homeTeam, required String awayTeam}) async {
    final response = await _repository.getVotes(homeTeam: homeTeam, awayTeam: awayTeam);
    return response.map(countVotes);
  }
}
