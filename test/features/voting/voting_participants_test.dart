import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Leões',
  awayTeam: 'Tigres',
  homeTeamId: 't1',
  awayTeamId: 't2',
  lineup: MatchLineup(home: [
    LineupEntry(playerId: 'p1', playerName: 'Kaio'),
    LineupEntry(playerId: 'p2', playerName: 'Banco', starter: false),
    LineupEntry(playerId: 'p3', playerName: 'Rui', starter: false),
  ]),
  substitutions: [
    MatchSubstitution(id: 's', side: MatchSide.home, outId: 'p1', outName: 'Kaio', inId: 'p3', inName: 'Rui'),
  ],
  goals: [
    MatchGoal(
        id: 'g', side: MatchSide.home, scorerId: 'p1', scorerName: 'Kaio', assistantId: 'p4', assistantName: 'Garçom'),
  ],
);

void main() {
  test('participaram: titulares, quem entrou, gol/assistência; reserva que não entrou não', () {
    expect(MatchReport.participants(_match, MatchSide.home), {'p1', 'p3', 'p4'});
    // Visitante sem escalação: nulo (todos do elenco valem).
    expect(MatchReport.participants(_match, MatchSide.away), isNull);
    expect(MatchReport.participantNames(_match, MatchSide.home), {'kaio', 'rui', 'garçom'});
  });

  test('apuração: voto em quem não jogou não vale; time sem escalação não filtra', () {
    final ref = MatchVoteRef.of(_match, '2026');
    expect(ref.isEligible(playerName: 'Rui', teamId: 't1'), isTrue);
    expect(ref.isEligible(playerName: 'Banco', teamId: 't1'), isFalse);
    // Voto antigo sem id do time: pelo nome do time.
    expect(ref.isEligible(playerName: 'Banco', team: 'Leões'), isFalse);
    expect(ref.isEligible(playerName: 'Qualquer', teamId: 't2'), isTrue);
  });

  test('lista da votação agrupada por posição e nome', () {
    const players = [
      PlayerDTO(id: 'a', name: 'Zeca', team: 'Leões', position: 'atacante'),
      PlayerDTO(id: 'b', name: 'Beto', team: 'Leões', position: 'goleiro'),
      PlayerDTO(id: 'c', name: 'Caio', team: 'Leões'),
      PlayerDTO(id: 'd', name: 'Ana', team: 'Leões', position: 'atacante'),
    ];
    final sections = votingSections(players);
    expect(sections.map((s) => s.position), [PlayerPosition.goalkeeper, PlayerPosition.forward, null]);
    expect(sections[1].players.map((p) => p.name), ['Ana', 'Zeca']);
  });
}
