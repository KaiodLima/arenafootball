import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/widgets/organizer_squad_actions.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

PlayerDTO _player(String id, List<PlayerEnrollment> enrollments, {bool legacy = false}) => PlayerDTO(
      id: id,
      name: 'Atleta $id',
      team: 'Leões',
      teamId: 't1',
      enrollments: enrollments,
      hasEnrollmentField: !legacy,
    );

void main() {
  const lions = 't1';

  test('candidatos: fora da competição, sem outro time nela e não antigos', () {
    final players = [
      _player('a', const []),
      _player('b', const [PlayerEnrollment(championshipId: 11, teamId: lions, team: 'Leões')]),
      _player('c', const [PlayerEnrollment(championshipId: 11, teamId: 't9', team: 'Tigres')]),
      _player('d', const [PlayerEnrollment(championshipId: 3, teamId: lions, team: 'Leões')]),
      _player('e', const [], legacy: true),
    ];
    final ids = squadCandidates(players, 11, teamId: lions, teamName: 'Leões').map((p) => p.id);
    expect(ids, ['a', 'd']);
  });

  test('pôr na competição mexe só nessa inscrição', () {
    final player = _player('d', const [PlayerEnrollment(championshipId: 3, teamId: lions, team: 'Leões')]);
    final changes = PlayersDataSource.enrollmentChanges(
      player,
      teamId: lions,
      team: 'Leões',
      selected: {11},
      teamChampionships: [11],
    );
    final keys = changes.keys.map((k) => k.toString()).toList();
    expect(keys.any((k) => k.contains('c11')), isTrue);
    expect(keys.any((k) => k.contains('c3')), isFalse);
    expect(changes.containsKey('time'), isFalse);
    expect(changes[PlayerDTO.teamIdsField], [lions]);
  });

  test('tirar da competição apaga só essa chave', () {
    final player = _player('d', const [
      PlayerEnrollment(championshipId: 3, teamId: lions, team: 'Leões'),
      PlayerEnrollment(championshipId: 11, teamId: lions, team: 'Leões'),
    ]);
    final changes = PlayersDataSource.enrollmentChanges(
      player,
      teamId: lions,
      team: 'Leões',
      selected: const {},
      teamChampionships: [11],
    );
    final keys = changes.keys.map((k) => k.toString()).toList();
    expect(keys.where((k) => k.contains('inscricoes')), hasLength(1));
    expect(keys.any((k) => k.contains('c11')), isTrue);
    expect(keys.any((k) => k.contains('c3')), isFalse);
    expect(changes.containsKey('time'), isFalse);
  });
}
