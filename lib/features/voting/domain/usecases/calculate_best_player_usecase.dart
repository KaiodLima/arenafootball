import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_votes_cache_first_usecase.dart';

/// Apura a votação de uma partida: conta os votos por nome de jogador e
/// devolve o ranking, do mais votado ao menos votado (vazio sem votos).
/// Empate: fica na frente quem recebeu o primeiro voto antes, na ordem dos
/// documentos, como no app antigo (o eleito é o primeiro do ranking).
/// Só lê; não grava o resultado na partida (o app antigo também não gravava).
class CalculateBestPlayerUseCase {
  final GetVotesCacheFirstUseCase _getVotes;

  CalculateBestPlayerUseCase(this._getVotes);

  static List<VoteTally> tallyVotes(List<VoteDTO> votes) {
    // O Map preserva a ordem de inserção: é o critério de desempate.
    final counts = <String, int>{};
    final teams = <String, String>{};
    final teamIds = <String, String>{};
    for (final vote in votes) {
      counts[vote.playerName] = (counts[vote.playerName] ?? 0) + 1;
      teams.putIfAbsent(vote.playerName, () => vote.team);
      // Votos antigos não têm o id: fica o primeiro que tiver.
      if (vote.teamId.isNotEmpty) teamIds.putIfAbsent(vote.playerName, () => vote.teamId);
    }

    final indexed = counts.entries.toList().asMap().entries.toList()
      ..sort((a, b) {
        final byVotes = b.value.value.compareTo(a.value.value);
        return byVotes != 0 ? byVotes : a.key.compareTo(b.key);
      });
    return [
      for (final entry in indexed)
        VoteTally(
          playerName: entry.value.key,
          team: teams[entry.value.key] ?? '',
          teamId: teamIds[entry.value.key] ?? '',
          votes: entry.value.value,
        ),
    ];
  }

  /// O mais votado (`null` sem votos).
  static ElectedPlayer? countVotes(List<VoteDTO> votes) {
    final ranking = tallyVotes(votes);
    if (ranking.isEmpty) return null;
    final winner = ranking.first;
    return ElectedPlayer(playerName: winner.playerName, team: winner.team, teamId: winner.teamId, votes: winner.votes);
  }

  Future<Either<Failure, List<VoteTally>>> call(MatchVoteRef ref) async {
    // Só apura votação encerrada: cache local curto, fica com a última
    // emissão (o remoto quando revalidou).
    final response = await _getVotes(ref).last;
    return response.map(tallyVotes);
  }
}
