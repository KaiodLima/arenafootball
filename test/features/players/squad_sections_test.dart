import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';

PlayerDTO _p(String id, {String position = '', int goals = 0, int assists = 0}) => PlayerDTO(
      id: id,
      name: id,
      team: 'Leões',
      teamId: 't1',
      position: position,
      goals: goals,
      assists: assists,
    );

void main() {
  final players = [
    _p('Zeca', position: 'atacante', goals: 5),
    _p('Beto', position: 'goleiro'),
    _p('Caio', goals: 1, assists: 4),
    _p('Ana', position: 'atacante', goals: 2, assists: 1),
    _p('Davi', position: 'zagueiro'),
  ];
  TeamPlayersState state(PlayersSort sort) =>
      TeamPlayersState(players: players, view: TeamPlayersView(teamId: 't1', teamName: 'Leões', sort: sort));

  test('por posição (padrão): setores na ordem do campo e sem posição no fim', () {
    expect(const TeamPlayersView().sort, PlayersSort.position);
    final sections = state(PlayersSort.position).sections;
    expect(sections.map((s) => s.position), [
      PlayerPosition.goalkeeper,
      PlayerPosition.defender,
      PlayerPosition.forward,
      null,
    ]);
    expect(sections.every((s) => s.grouped && !s.ranked), isTrue);
    // Dentro do setor, por nome.
    expect(sections[2].players.map((p) => p.id), ['Ana', 'Zeca']);
  });

  test('por gols: uma lista só, ranqueada', () {
    final sections = state(PlayersSort.goals).sections;
    expect(sections, hasLength(1));
    expect(sections.single.ranked, isTrue);
    expect(sections.single.players.map((p) => p.id).take(3), ['Zeca', 'Ana', 'Caio']);
  });

  test('por nome: uma lista sem ranking', () {
    final section = state(PlayersSort.name).sections.single;
    expect(section.ranked, isFalse);
    expect(section.players.first.id, 'Ana');
  });

  test('destaques: artilheiro e garçom; sem números, nenhum', () {
    final s = state(PlayersSort.position);
    expect(s.topScorer?.id, 'Zeca');
    expect(s.topAssister?.id, 'Caio');
    final empty = TeamPlayersState(players: [_p('X'), _p('Y')]);
    expect(empty.topScorer, isNull);
    expect(empty.topAssister, isNull);
    expect(squadSections(const [], PlayersSort.position), isEmpty);
  });
}
