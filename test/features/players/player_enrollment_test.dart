import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/players/domain/usecases/adjust_player_stats_usecase.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Joga pelo Lava Jato na Copa (7) e pelo Volta na Liga (9).
const _dudu = PlayerDTO(
  id: 'p1',
  name: 'Dudu',
  team: 'Lava Jato',
  teamId: '1',
  goals: 5,
  assists: 2,
  enrollments: [
    PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato', goals: 3, assists: 1),
    PlayerEnrollment(championshipId: 9, teamId: '2', team: 'Volta', goals: 2, assists: 1),
  ],
);

/// Atleta antigo: sem inscrições, só o time principal.
const _old = PlayerDTO(id: 'p2', name: 'Rafa', team: 'Lava Jato', teamId: '1', goals: 4);

void main() {
  test('inscrições: chave c<id> vai e volta (Firestore e cache)', () {
    final map = PlayerEnrollment.mapOf(_dudu.enrollments);
    expect(map.keys, ['c7', 'c9']);
    expect(PlayerEnrollment.listFrom(map), _dudu.enrollments);
    expect(PlayerDTO.fromCache(_dudu.toCache()), _dudu);
    expect(_dudu.toMap()[PlayerDTO.teamIdsField], ['1', '2']);
    expect(_old.toMap().containsKey(PlayerEnrollment.field), isFalse);
  });

  test('joga por cada time só na competição da inscrição', () {
    expect(_dudu.playsFor(teamId: '1'), isTrue);
    expect(_dudu.playsFor(teamId: '2'), isTrue);
    expect(_dudu.playsIn(7, teamId: '1'), isTrue);
    expect(_dudu.playsIn(7, teamId: '2'), isFalse);
    expect(_dudu.playsIn(9, teamId: '2'), isTrue);
    expect(_dudu.playsIn(11, teamId: '1'), isFalse);
    expect(_dudu.teamNames, ['Lava Jato', 'Volta']);
  });

  test('números por competição; total sem competição', () {
    expect(_dudu.statIn(PlayerDTO.goalsField, 7), 3);
    expect(_dudu.statIn(PlayerDTO.assistsField, 9), 1);
    expect(_dudu.statIn(PlayerDTO.goalsField, 11), 0);
    expect(_dudu.statIn(PlayerDTO.goalsField, null), 5);
  });

  test('atleta antigo conta em toda competição do time principal, com 0 nela', () {
    expect(_old.playsIn(7, teamId: '1'), isTrue);
    expect(_old.playsIn(7, teamId: '2'), isFalse);
    expect(_old.statIn(PlayerDTO.goalsField, 7), 0);
    expect(_old.teamIds, ['1']);
    expect(_old.teamNames, ['Lava Jato']);
  });

  group('sair do elenco', () {
    test('de uma competição: sai só dela e continua no time principal', () {
      final changes = PlayersDataSource.squadRemovalFields(_dudu, championshipId: 7);
      expect(changes[FieldPath(const ['inscricoes', 'c7'])], isA<FieldValue>());
      expect(changes[PlayerDTO.teamIdsField], ['1', '2']);
      expect(changes.containsKey('time'), isFalse);
    });

    test('da competição de outro time: o principal fica', () {
      final changes = PlayersDataSource.squadRemovalFields(_dudu, championshipId: 9);
      expect(changes[PlayerDTO.teamIdsField], ['1']);
      expect(changes.containsKey('time'), isFalse);
    });

    test('a última inscrição (ou atleta antigo): fica sem time', () {
      const single = PlayerDTO(
        id: 'p3',
        name: 'Ana',
        team: 'Lava Jato',
        teamId: '1',
        enrollments: [PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato')],
      );
      // Da última competição: continua no time, sem competição.
      final changes = PlayersDataSource.squadRemovalFields(single, championshipId: 7);
      expect(changes.containsKey('time'), isFalse);
      // Sem competição: sai do time.
      expect(PlayersDataSource.squadRemovalFields(single)['time'], '');
      final old = PlayersDataSource.squadRemovalFields(_old);
      expect(old, {'time': '', 'idTime': ''});
    });

    test('inscrever atleta sem time preenche o principal', () {
      const free = PlayerDTO(id: 'p4', name: 'Leo', team: '');
      final fields = PlayersDataSource.enrollFields(
          free, const PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato'));
      expect(fields['time'], 'Lava Jato');
      expect(fields[FieldPath(const ['inscricoes', 'c7', 'idTime'])], '1');
      expect(PlayersDataSource.enrollFields(_dudu, _dudu.enrollments.first).containsKey('time'), isFalse);
    });
  });

  test('ajuste do admin na competição não deixa a competição nem o total negativos', () {
    expect(AdjustPlayerStatsUseCase.clampDelta(1, inChampionship: 0, total: 0), 1);
    expect(AdjustPlayerStatsUseCase.clampDelta(-1, inChampionship: 0, total: 5), 0);
    expect(AdjustPlayerStatsUseCase.clampDelta(-3, inChampionship: 2, total: 5), -2);
    expect(AdjustPlayerStatsUseCase.clampDelta(-3, inChampionship: 4, total: 1), -1);
  });

  group('excluir time', () {
    test('atleta que joga por outro time em outra competição fica com ela', () {
      final changes = TeamsDataSource.teamRemovalFields(_dudu, const TeamDTO(id: '1', name: 'Lava Jato'))!;
      expect(changes[FieldPath(const ['inscricoes', 'c7'])], isA<FieldValue>());
      expect(changes.containsKey(FieldPath(const ['inscricoes', 'c9'])), isFalse);
      expect(changes[PlayerDTO.teamIdsField], ['2']);
      expect(changes['time'], 'Volta');
    });

    test('só deste time: sem vínculo é apagado; com conta fica sem time', () {
      expect(TeamsDataSource.teamRemovalFields(_old, const TeamDTO(id: '1', name: 'Lava Jato')), isNull);
      final linked = _old.copyWith(userId: 'u1');
      expect(TeamsDataSource.teamRemovalFields(linked, const TeamDTO(id: '1', name: 'Lava Jato')),
          {'time': '', 'idTime': ''});
    });
  });

  group('inscrições do atleta pelo time (Elenco geral)', () {
    Map<Object, Object?> changes(PlayerDTO p, Set<int> selected, {List<int> teamChampionships = const [7, 11]}) =>
        PlayersDataSource.enrollmentChanges(p,
            teamId: '1', team: 'Lava Jato', selected: selected, teamChampionships: teamChampionships);

    test('nada mudou: não grava', () {
      expect(changes(_dudu, {7}), isEmpty);
      // Antigo conta em todas as do time.
      expect(changes(_old, {7, 11}), isEmpty);
    });

    test('acrescenta a nova e mantém a de outro time', () {
      final c = changes(_dudu, {7, 11});
      expect(c[FieldPath(const ['inscricoes', 'c11', 'idTime'])], '1');
      expect(c.keys.whereType<FieldPath>().any((k) => k.components.contains('c9')), isFalse);
      expect(c[PlayerDTO.teamIdsField], ['1', '2']);
    });

    test('tira a deste time e continua nele (elenco geral)', () {
      final c = changes(_dudu, {});
      expect(c[FieldPath(const ['inscricoes', 'c7'])], isA<FieldValue>());
      expect(c.containsKey('time'), isFalse);
      expect(c[PlayerDTO.teamIdsField], ['1', '2']);
    });

    test('antigo: desmarcar uma vira inscrição real só das que ficaram', () {
      final c = changes(_old, {11});
      expect(c[FieldPath(const ['inscricoes', 'c11', 'idTime'])], '1');
      expect(c.containsKey(FieldPath(const ['inscricoes', 'c7', 'idTime'])), isFalse);
      expect(c[PlayerDTO.teamIdsField], ['1']);
    });

    test('desmarcar todas: continua no time, sem competição (mapa vazio, não antigo)', () {
      final c = changes(_old, {});
      expect(c.containsKey('time'), isFalse);
      expect(c[PlayerEnrollment.field], <String, Object?>{});
      // Mapa vazio: não conta em competição nenhuma, mas segue no elenco geral.
      final after = _old.copyWith(enrollments: const []);
      expect(after.isLegacy, isFalse);
      expect(after.playsIn(7, teamId: '1'), isFalse);
      expect(after.playsFor(teamId: '1'), isTrue);
    });
  });

  group('time no campeonato', () {
    setUp(() => RegionRegistry.configure(
        const [RegionRef(id: 'fl', name: 'Floresta'), RegionRef(id: 'si', name: 'Santo inacio')]));
    tearDown(RegionRegistry.reset);
    const copa = ChampionshipDTO(id: 'a', region: 'Floresta', teams: ['Volta', 'Lava Jato'], teamIds: ['2', '1']);
    const parceiros = TeamDTO(id: '3', name: 'Parceiros', region: 'Santo inacio');

    test('tirar mantém as listas alinhadas', () {
      final next = ChampionshipsDataSource.withTeam(copa, const TeamDTO(id: '2', name: 'Volta'), enrolled: false)!;
      expect(next.teams, ['Lava Jato']);
      expect(next.teamIds, ['1']);
    });

    test('municipal recusa time de outra região; intermunicipal aceita e ganha a região', () {
      expect(ChampionshipsDataSource.withTeam(copa, parceiros, enrolled: true), isNull);
      final inter = copa.copyWith(scope: ChampionshipScope.intermunicipal);
      final next = ChampionshipsDataSource.withTeam(inter, parceiros, enrolled: true)!;
      expect(next.teams.last, 'Parceiros');
      expect(next.teamIds.last, '3');
      expect(next.regionIds.toSet(), {'fl', 'si'});
    });
  });
}
