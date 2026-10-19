import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_rules_file.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_championship_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  /// Sem região (a grade agora lê a temporada inteira): todos.
  static const _all = [
    TeamDTO(id: '1', name: 'Volta', region: 'Floresta'),
    TeamDTO(id: '2', name: 'Lava Jato', region: 'Floresta'),
    TeamDTO(id: '3', name: 'Parceiros', region: 'Santo inacio'),
  ];

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async =>
      Right(region == null ? _all : _all.where((t) => t.region == region).toList());
}

class _FakeSave implements SaveChampionshipUseCase {
  ChampionshipDTO? saved;
  ChampionshipRulesFile? rules;

  @override
  Future<Either<Failure, ChampionshipDTO>> call(
    ChampionshipDTO championship, {
    File? banner,
    ChampionshipRulesFile? rules,
  }) async {
    saved = championship;
    this.rules = rules;
    return Right(championship.copyWith(id: championship.id.isEmpty ? 'novo' : championship.id));
  }
}

void main() {
  late _FakeSave save;
  late ChampionshipFormCubit cubit;

  setUp(() async {
    save = _FakeSave();
    cubit = ChampionshipFormCubit(_FakeRegions(), _FakeTeams(), save);
    await cubit.load(initialRegion: 'Floresta');
  });

  tearDown(() => cubit.close());

  test('carrega os times da região em ordem alfabética', () {
    expect(cubit.state.form.visibleTeams.map((t) => t.name), ['Lava Jato', 'Volta']);
    expect(cubit.state.form.base.region, 'Floresta');
  });

  test('validação: nome e ao menos um time; Todos/Limpar', () {
    expect(cubit.state.form.error, ChampionshipFormError.title);
    cubit.changeTitle('Copa Floresta');
    expect(cubit.state.form.error, ChampionshipFormError.teams);
    cubit.selectAllTeams();
    expect(cubit.state.form.selectedTeams, ['Lava Jato', 'Volta']);
    expect(cubit.state.form.error, isNull);
    cubit.clearTeams();
    expect(cubit.state.form.selectedTeams, isEmpty);
    cubit.toggleTeam('Volta');
    expect(cubit.state.form.selectedTeams, ['Volta']);
    expect(cubit.state.form.dirty, isTrue);
  });

  test('trocar de região limpa a seleção e carrega os times dela', () async {
    cubit.toggleTeam('Volta');
    await cubit.selectRegion('Santo inacio');
    expect(cubit.state.form.selectedTeams, isEmpty);
    expect(cubit.state.form.visibleTeams.single.name, 'Parceiros');
  });

  test('salvar envia os times marcados e o PDF escolhido', () async {
    cubit
      ..changeTitle('Copa Floresta')
      ..toggleTeam('Volta')
      ..setRulesFile(ChampionshipRulesFile(bytes: Uint8List(4), name: 'regulamento.pdf'));
    await cubit.submit();
    expect(save.saved?.teams, ['Volta']);
    expect(save.rules?.name, 'regulamento.pdf');
    expect(cubit.state, isA<SavedChampionshipFormState>().having((s) => s.created, 'created', isTrue));
  });

  test('editar mantém a seleção e o PDF já gravados', () async {
    final edit = ChampionshipFormCubit(_FakeRegions(), _FakeTeams(), save);
    await edit.load(
      initial: const ChampionshipDTO(
        id: 'c1',
        title: 'Copa',
        region: 'Floresta',
        season: '2023',
        teams: ['Volta'],
        rulesUrl: 'https://pdf',
        rulesFileName: 'regras.pdf',
      ),
      initialRegion: 'Santo inacio',
    );
    expect(edit.state.form.selectedTeams, ['Volta']);
    expect(edit.state.form.rulesName, 'regras.pdf');
    edit.removeRules();
    expect(edit.state.form.hasRules, isFalse);
    await edit.submit();
    expect(save.saved?.rulesUrl, isEmpty);
    expect(edit.state, isA<SavedChampionshipFormState>().having((s) => s.created, 'created', isFalse));
    await edit.close();
  });

  group('abrangência', () {
    test('municipal (padrão) só com times da sede; intermunicipal com todos, sede primeiro', () {
      expect(cubit.state.form.base.scope, ChampionshipScope.municipal);
      expect(cubit.state.form.visibleTeams.map((t) => t.name), ['Lava Jato', 'Volta']);
      cubit.selectScope(ChampionshipScope.intermunicipal);
      expect(cubit.state.form.visibleTeams.map((t) => t.name), ['Lava Jato', 'Volta', 'Parceiros']);
      expect(cubit.state.form.teamsByRegion.keys, ['Floresta', 'Santo inacio']);
    });

    test('voltar para municipal tira os de fora; salvar grava abrangência e regiões', () async {
      cubit.changeTitle('Copa Regional');
      cubit.selectScope(ChampionshipScope.intermunicipal);
      cubit
        ..toggleTeam('Volta')
        ..toggleTeam('Parceiros');
      expect(cubit.selectScope(ChampionshipScope.municipal), 1);
      expect(cubit.state.form.selectedTeams, ['Volta']);

      cubit.selectScope(ChampionshipScope.intermunicipal);
      cubit.toggleTeam('Parceiros');
      await cubit.submit();
      expect(save.saved?.scope, ChampionshipScope.intermunicipal);
      expect(save.saved?.teamIds, ['1', '3']);
      expect(save.saved?.toMap()['abrangencia'], 'intermunicipal');
    });

    test('doc antigo sem o campo é municipal; DTO vai e volta pelo cache', () {
      const old = ChampionshipDTO(id: 'a', region: 'Floresta');
      expect(old.isIntermunicipal, isFalse);
      const inter = ChampionshipDTO(
        id: 'b',
        region: 'Floresta',
        scope: ChampionshipScope.intermunicipal,
        regionIds: ['fl', 'si'],
      );
      final back = ChampionshipDTO.fromCache(inter.toCache());
      expect(back.scope, ChampionshipScope.intermunicipal);
      expect(back.regionIds, ['fl', 'si']);
    });
  });
}
