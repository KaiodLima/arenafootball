import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_state.dart';

const _floresta = [
  TeamDTO(id: '1_Lava_Jato', name: 'Lava Jato', region: 'Floresta'),
  TeamDTO(id: '2_Olho_Dagua', name: "Olho D'água", region: 'Floresta'),
];

class _FakeCreateTeam implements CreateTeamUseCase {
  TeamDTO? created;

  @override
  Future<Either<Failure, TeamDTO>> call({required TeamDTO team, File? crest}) async {
    created = team.copyWith(id: '14_${team.name}');
    return Right(created!);
  }
}

class _FakeNextNumber implements GetNextTeamNumberUseCase {
  @override
  Future<Either<Failure, int>> call() async => const Right(14);
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async =>
      Right(region == 'Floresta' ? _floresta : const []);
}

void main() {
  group('TeamFormData', () {
    test('duplicado ignora acento, caixa e espaços extras', () {
      const form = TeamFormData(existing: _floresta);
      expect(form.copyWith(name: '  lava   JATO ').duplicate?.id, '1_Lava_Jato');
      expect(form.copyWith(name: "olho d'agua").duplicate?.id, '2_Olho_Dagua');
      expect(form.copyWith(name: 'Volta').duplicate, isNull);
      expect(form.duplicate, isNull);
    });

    test('isDirty e cleared mantendo região e times', () {
      const form = TeamFormData(selectedRegion: 'Floresta', existing: _floresta);
      expect(form.isDirty, isFalse);
      final filled = form.copyWith(name: 'Volta', crest: File('x.png'));
      expect(filled.isDirty, isTrue);
      final cleared = filled.cleared();
      expect([cleared.name, cleared.crest, cleared.selectedRegion], ['', null, 'Floresta']);
      expect(cleared.existing, _floresta);
      expect(filled.copyWith(clearCrest: true).crest, isNull);
    });
  });

  group('TeamFormCubit', () {
    late _FakeCreateTeam create;
    late TeamFormCubit cubit;

    setUp(() async {
      create = _FakeCreateTeam();
      cubit = TeamFormCubit(create, _FakeNextNumber(), _FakeRegions(), _FakeTeams());
      await cubit.load(initialRegion: 'Floresta');
    });

    test('carrega regiões e times da região', () {
      expect(cubit.state.form.regions, ['Floresta', 'Santo inacio']);
      expect(cubit.state.form.existing, _floresta);
    });

    test('trocar de região recarrega os times', () async {
      await cubit.selectRegion('Santo inacio');
      expect(cubit.state.form.existing, isEmpty);
    });

    test('cadastra, limpa o formulário e o time entra na lista', () async {
      cubit.changeName('Volta');
      cubit.setCrest(File('volta.png'));
      await cubit.submit();
      expect(create.created!.name, 'Volta');
      final form = cubit.state.form;
      expect([form.name, form.crest], ['', null]);
      expect(form.existing.map((t) => t.name), ['Lava Jato', "Olho D'água", 'Volta']);
    });

    test('nome curto não cadastra', () async {
      cubit.changeName('AB');
      await cubit.submit();
      expect(create.created, isNull);
    });
  });
}
