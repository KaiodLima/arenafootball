import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/voting_outcome.dart';
import 'package:arena_soccer/features/voting/presentation/widgets/vote_player_tile.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

List<VoteTally> _ranking(List<int> votes) => [
      for (var i = 0; i < votes.length; i++) VoteTally(playerName: 'P$i', team: 'T', votes: votes[i]),
    ];

void main() {
  const rules = VotingRulesDTO();

  test('padrões: 20 votos e 35%; doc ausente ou valores ruins caem no padrão', () {
    expect(VotingRulesDTO.fromMap(null), const VotingRulesDTO(minVotes: 20, minPercent: 35));
    expect(VotingRulesDTO.fromMap({'minVotos': 10, 'percentualMinimo': '50'}).minPercent, 50);
    expect(VotingRulesDTO.fromMap({'minVotos': -3, 'percentualMinimo': 140}),
        const VotingRulesDTO(minVotes: 20, minPercent: 100));
  });

  test('1 voto não elege ninguém (mínimo de votos)', () {
    final outcome = VotingOutcome.evaluate(_ranking([1]), rules);
    expect(outcome.reason, VotingOutcomeReason.notEnoughVotes);
    expect(outcome.totalVotes, 1);
    expect(VotingOutcome.evaluate(const [], rules).isValid, isFalse);
  });

  test('mais votado abaixo da porcentagem: sem eleito', () {
    // 7 de 20 = 35% passa; 6 de 20 = 30% não.
    expect(VotingOutcome.evaluate(_ranking([7, 5, 4, 4]), rules).isValid, isTrue);
    final low = VotingOutcome.evaluate(_ranking([6, 5, 5, 4]), rules);
    expect(low.reason, VotingOutcomeReason.noMajority);
    expect(low.leaderPercent, 30);
  });

  test('empate no primeiro lugar: sem eleito', () {
    expect(VotingOutcome.evaluate(_ranking([10, 10]), rules).reason, VotingOutcomeReason.tie);
  });

  test('voto no próprio atleta não conta (conta = id do voto)', () {
    const players = [PlayerDTO(id: 'a', name: 'Dudu', team: 'T', userId: 'u1')];
    final votes = [
      const VoteDTO(voterId: 'u1', playerName: 'Dudu', team: 'T'),
      const VoteDTO(voterId: 'u2', playerName: 'Dudu', team: 'T'),
      const VoteDTO(voterId: 'u3', playerName: 'Ana', team: 'T'),
    ];
    final filtered = VotingOutcome.withoutSelfVotes(votes, players);
    expect(filtered.map((v) => v.voterId), ['u2', 'u3']);
    expect(CalculateBestPlayerUseCase.tallyVotes(filtered).first.votes, 1);
  });

  testWidgets('tela de votar: o próprio atleta aparece com o aviso e sem seleção', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: const Scaffold(
        body: VotePlayerTile(
          player: PlayerDTO(id: 'a', name: 'Dudu', team: 'T', userId: 'u1'),
          selected: false,
          isMyVote: false,
          isSelf: true,
        ),
      ),
    ));
    expect(find.text('Você não pode votar em si'), findsOneWidget);
  });
}
