import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';
import 'package:arena_soccer/features/teams/domain/usecases/update_team_details_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_state.dart';

/// Guarda o que chegou em `updateTeamDetails`.
class _FakeRepository implements ITeamsRepository {
  Map<String, Object?>? saved;

  @override
  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? region,
    String? season,
  }) async {
    saved = {'id': id, 'description': description, 'primary': primaryColor, 'region': region, 'season': season};
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorage implements StorageUploadService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const team = TeamDTO(id: 't1', name: 'Lava Jato', region: 'Floresta', description: 'antiga');

  test('use case: região só vai quando changeRegion (o dono não muda a região)', () async {
    final repository = _FakeRepository();
    final useCase = UpdateTeamDetailsUseCase(repository, _FakeStorage());

    await useCase(team.copyWith(region: 'Centro'));
    expect(repository.saved?['region'], isNull);

    await useCase(team.copyWith(region: 'Centro'), changeRegion: true, season: '2024');
    expect(repository.saved?['region'], 'Centro');
    expect(repository.saved?['season'], '2024');
  });

  test('cubit: salva descrição, cores e a região nova e devolve o time atualizado', () async {
    final repository = _FakeRepository();
    final cubit = EditTeamCubit(UpdateTeamDetailsUseCase(repository, _FakeStorage()), team: team, season: '2024');

    await cubit.save(description: '  nova  ', primaryColor: '#FF0000', secondaryColor: '', region: 'Centro');

    expect(cubit.state, isA<SavedEditTeamState>());
    expect(cubit.state.team.description, 'nova');
    expect(cubit.state.team.region, 'Centro');
    expect(repository.saved?['region'], 'Centro');
    expect(repository.saved?['primary'], '#FF0000');
    await cubit.close();
  });

  test('cubit: mesma região não regrava fk_competicao', () async {
    final repository = _FakeRepository();
    final cubit = EditTeamCubit(UpdateTeamDetailsUseCase(repository, _FakeStorage()), team: team);

    await cubit.save(description: 'x', primaryColor: '', secondaryColor: '', region: 'Floresta');

    expect(repository.saved?['region'], isNull);
    await cubit.close();
  });
}
