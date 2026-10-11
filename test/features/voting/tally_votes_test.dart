import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';

VoteDTO _vote(String voter, String player, [String team = 'Time']) =>
    VoteDTO(voterId: voter, playerName: player, team: team);

void main() {
  group('tallyVotes', () {
    test('sem votos', () {
      expect(CalculateBestPlayerUseCase.tallyVotes(const []), isEmpty);
      expect(CalculateBestPlayerUseCase.countVotes(const []), isNull);
    });

    test('ordena do mais votado ao menos votado', () {
      final ranking = CalculateBestPlayerUseCase.tallyVotes([
        _vote('1', 'Cassin', 'X-9'),
        _vote('2', 'Lucas', 'Risadinha'),
        _vote('3', 'Lucas', 'Risadinha'),
        _vote('4', 'Kaique', 'Volta'),
        _vote('5', 'Lucas', 'Risadinha'),
        _vote('6', 'Cassin', 'X-9'),
      ]);
      expect(ranking, const [
        VoteTally(playerName: 'Lucas', team: 'Risadinha', votes: 3),
        VoteTally(playerName: 'Cassin', team: 'X-9', votes: 2),
        VoteTally(playerName: 'Kaique', team: 'Volta', votes: 1),
      ]);
    });

    test('empate: fica na frente quem recebeu o primeiro voto antes', () {
      final votes = [_vote('1', 'B'), _vote('2', 'A'), _vote('3', 'A'), _vote('4', 'B')];
      expect(CalculateBestPlayerUseCase.tallyVotes(votes).map((t) => t.playerName), ['B', 'A']);
      expect(CalculateBestPlayerUseCase.countVotes(votes)?.playerName, 'B');
    });
  });

  test('VotingResult.shareOf', () {
    const result = VotingResult(ranking: [
      VoteTally(playerName: 'A', team: '', votes: 3),
      VoteTally(playerName: 'B', team: '', votes: 1),
    ]);
    expect(result.totalVotes, 4);
    expect(result.shareOf(3), 0.75);
    expect(const VotingResult().shareOf(0), 0);
  });
}
