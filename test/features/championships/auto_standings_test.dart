import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/championships/domain/standings_criterion.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_group_table_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_standings_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_criteria_editor.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

class _Repo implements IChampionshipsRepository {
  final table = StreamController<Either<Failure, GroupTableDTO?>>();
  var legacyWatched = 0;

  @override
  Stream<Either<Failure, GroupTableDTO?>> watchGroupTable({required String groupId, String? season}) => table.stream;

  @override
  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  }) {
    legacyWatched++;
    return Stream.value(const Right([StandingDTO(id: 'old', teamName: 'Antigo', points: 9)]));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const wins = StandingsCriterion.wins;
  const diff = StandingsCriterion.goalDifference;
  const goals = StandingsCriterion.goalsFor;
  const h2h = StandingsCriterion.headToHead;
  const against = StandingsCriterion.fewestGoalsAgainst;

  test('critérios: chaves das functions, sem repetidos; vazio = padrão', () {
    expect(StandingsCriterion.fromKeys(['saldo', 'xx', 'confronto', 'saldo']), [diff, h2h]);
    expect(StandingsCriterion.fromKeys(null), isEmpty);
    expect(StandingsCriterion.effective(const []), [wins, diff, goals]);
  });

  test('campeonato grava e lê o desempate', () {
    const championship = ChampionshipDTO(id: 'c1', tiebreakers: [h2h, diff]);
    expect(championship.toMap()['desempate'], ['confronto', 'saldo']);
    expect(ChampionshipDTO.fromCache(championship.toCache()).tiebreakers, [h2h, diff]);
  });

  group('editor do desempate', () {
    test('ordem exibida: os que valem e depois os outros', () {
      expect(StandingsCriteriaEditor.displayOrder(const []), [wins, diff, goals, h2h, against]);
      expect(StandingsCriteriaEditor.displayOrder(const [h2h]), [h2h, wins, diff, goals, against]);
    });

    test('arrastar reordena só os ligados', () {
      // Padrão; arrasta "gols pró" (2) para o topo.
      expect(StandingsCriteriaEditor.reorder(const [], 2, 0), [goals, wins, diff]);
      // Arrastar "vitórias" para o meio dos desligados não o desliga: vira o último critério.
      expect(StandingsCriteriaEditor.reorder(const [], 0, 5), [diff, goals, wins]);
    });

    test('ligar acrescenta na posição, desligar tira', () {
      expect(StandingsCriteriaEditor.toggle(const [], h2h), [wins, diff, goals, h2h]);
      expect(StandingsCriteriaEditor.toggle(const [], wins), [diff, goals]);
    });
  });

  group('StandingsCubit', () {
    StandingsCubit cubitOf(_Repo repo) =>
        StandingsCubit(WatchStandingsUseCase(repo), _Teams(), WatchGroupTableUseCase(repo));

    test('com a tabela calculada: automática, com os critérios', () async {
      final repo = _Repo();
      final cubit = cubitOf(repo)..watch(region: 'R', group: 'A', season: '2026', groupId: 'g1');
      repo.table.add(const Right(GroupTableDTO(
        groupId: 'g1',
        criteria: [h2h],
        rows: [StandingDTO(id: 'a', teamName: 'Lava Jato', points: 6)],
      )));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<SuccessStandingsState>());
      expect(cubit.state.automatic, isTrue);
      expect(cubit.state.criteria, [h2h]);
      expect(cubit.state.standings.single.teamName, 'Lava Jato');
      expect(repo.legacyWatched, 0);
      await cubit.close();
    });

    test('sem a tabela calculada: cai na classificação antiga', () async {
      final repo = _Repo();
      final cubit = cubitOf(repo)..watch(region: 'R', group: 'A', season: '2026', groupId: 'g1');
      repo.table.add(const Right(null));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(repo.legacyWatched, 1);
      expect(cubit.state.automatic, isFalse);
      expect(cubit.state.standings.single.teamName, 'Antigo');
      await cubit.close();
    });

    test('grupo sem id (rota antiga): só a classificação antiga', () async {
      final repo = _Repo();
      final cubit = cubitOf(repo)..watch(region: 'R', group: 'A', season: '2026');
      await Future<void>.delayed(Duration.zero);
      expect(repo.legacyWatched, 1);
      await cubit.close();
    });
  });
}
