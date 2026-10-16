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

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async => Right(
        region == 'Floresta'
            ? const [TeamDTO(id: '1', name: 'Volta'), TeamDTO(id: '2', name: 'Lava Jato')]
            : const [TeamDTO(id: '3', name: 'Parceiros')],
      );
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
    expect(cubit.state.form.teams.map((t) => t.name), ['Lava Jato', 'Volta']);
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
    expect(cubit.state.form.teams.single.name, 'Parceiros');
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
}
