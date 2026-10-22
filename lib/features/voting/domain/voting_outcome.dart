import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';

/// Por que a votação elegeu (ou não) alguém.
enum VotingOutcomeReason {
  elected,

  /// Menos votos que o mínimo.
  notEnoughVotes,

  /// O mais votado não chegou à porcentagem mínima.
  noMajority,

  /// Empate no primeiro lugar.
  tie,
}

/// Resultado das regras sobre a apuração: só há eleito com o mínimo de votos,
/// a porcentagem mínima e vantagem sobre o segundo.
class VotingOutcome extends Equatable {
  final VotingOutcomeReason reason;
  final int totalVotes;

  /// Porcentagem (0–100, arredondada) do mais votado.
  final int leaderPercent;
  final VotingRulesDTO rules;

  const VotingOutcome({
    required this.reason,
    required this.totalVotes,
    required this.leaderPercent,
    required this.rules,
  });

  bool get isValid => reason == VotingOutcomeReason.elected;

  static VotingOutcome evaluate(List<VoteTally> ranking, VotingRulesDTO rules) {
    final total = ranking.fold(0, (sum, tally) => sum + tally.votes);
    final leader = ranking.isEmpty ? 0 : ranking.first.votes;
    final percent = total == 0 ? 0 : (leader * 100 / total).round();
    VotingOutcome result(VotingOutcomeReason reason) =>
        VotingOutcome(reason: reason, totalVotes: total, leaderPercent: percent, rules: rules);

    if (total == 0 || total < rules.minVotes) return result(VotingOutcomeReason.notEnoughVotes);
    if (ranking.length > 1 && ranking[1].votes == leader) return result(VotingOutcomeReason.tie);
    // Compara sem arredondar: 34,6% não passa nos 35%.
    if (leader * 100 < rules.minPercent * total) return result(VotingOutcomeReason.noMajority);
    return result(VotingOutcomeReason.elected);
  }

  /// Tira os votos em si mesmo: o voto é o doc `votos/{uid}` (o [VoteDTO.voterId]
  /// é a conta que votou) e o atleta votado tem a conta em [PlayerDTO.userId].
  static List<VoteDTO> withoutSelfVotes(List<VoteDTO> votes, List<PlayerDTO> players) {
    final accountsByName = <String, Set<String>>{};
    for (final player in players) {
      if (player.userId.isEmpty) continue;
      accountsByName.putIfAbsent(player.name.trim().toLowerCase(), () => {}).add(player.userId);
    }
    if (accountsByName.isEmpty) return votes;
    return votes
        .where((vote) => !(accountsByName[vote.playerName.trim().toLowerCase()]?.contains(vote.voterId) ?? false))
        .toList();
  }

  @override
  List<Object?> get props => [reason, totalVotes, leaderPercent, rules];
}
