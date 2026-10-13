import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

const _squads = {
  'Lava Jato': [PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato'), PlayerDTO(id: 'p2', name: 'João Pedro', team: 'Lava Jato')],
  'Volta': [PlayerDTO(id: 'p3', name: 'Cassin', team: 'Volta')],
};

class _FakeRepository implements IPlayersRepository {
  final created = <PlayerDTO>[];

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async {
    created.add(player);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(_squads[teamName] ?? const []));

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) =>
      const Stream.empty();

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) async => const Right([]);

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  }) async =>
      const Right(null);
}

class _FakeStorage implements StorageUploadService {
  int uploads = 0;

  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async {
    uploads++;
    return Right('https://storage/$folder/${file.path}');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async => Right(region == 'Floresta'
      ? const [TeamDTO(id: '1', name: 'Lava Jato', imageUrl: 'https://img/lj.png'), TeamDTO(id: '2', name: 'Volta')]
      : const []);
}

void main() {
  group('CreatePlayerUseCase', () {
    test('com foto envia e grava a URL', () async {
      final repository = _FakeRepository();
      final storage = _FakeStorage();
      final result = await CreatePlayerUseCase(repository, storage)(
        const PlayerDTO(name: ' Dudu ', team: 'Volta'),
        photo: File('dudu.jpg'),
      );
      expect(storage.uploads, 1);
      expect(result.right.imageUrl, 'https://storage/jogadores/dudu.jpg');
      expect(repository.created.single.name, 'Dudu');
    });

    test('sem foto não envia nada', () async {
      final storage = _FakeStorage();
      final repository = _FakeRepository();
      await CreatePlayerUseCase(repository, storage)(const PlayerDTO(name: 'Dudu', team: 'Volta'));
      expect(storage.uploads, 0);
      expect(repository.created.single.imageUrl, isEmpty);
    });
  });

  group('PlayerFormData', () {
    test('duplicado no elenco ignora acento e caixa', () {
      final form = PlayerFormData(squad: _squads['Lava Jato']!);
      expect(form.copyWith(name: 'joao  pedro').duplicate?.id, 'p2');
      expect(form.copyWith(name: 'Rafael').duplicate, isNull);
    });

    test('erros, isDirty e cleared', () {
      expect(const PlayerFormData(name: 'Du').error, PlayerFormError.name);
      expect(const PlayerFormData(name: 'Dudu').error, PlayerFormError.team);
      expect(const PlayerFormData(name: 'Dudu', selectedTeam: 'Volta').error, isNull);
      expect(const PlayerFormData().isDirty, isFalse);
      expect(const PlayerFormData(goals: 1).isDirty, isTrue);
      final cleared = PlayerFormData(name: 'Dudu', goals: 2, selectedTeam: 'Volta', photo: File('x')).cleared();
      expect([cleared.name, cleared.goals, cleared.photo, cleared.selectedTeam], ['', 0, null, 'Volta']);
    });
  });

  group('PlayerFormCubit', () {
    late _FakeRepository repository;
    late PlayerFormCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = PlayerFormCubit(
        CreatePlayerUseCase(repository, _FakeStorage()),
        _FakeRegions(),
        _FakeTeams(),
        WatchTeamPlayersUseCase(repository),
      );
      await cubit.load(initialRegion: 'Floresta');
    });

    test('carrega o primeiro time com escudo e o elenco dele', () {
      final form = cubit.state.form;
      expect(form.selectedTeam, 'Lava Jato');
      expect(form.crestOf('Lava Jato'), 'https://img/lj.png');
      expect(form.squad.map((p) => p.id), ['p1', 'p2']);
    });

    test('trocar de time recarrega o elenco', () async {
      await cubit.selectTeam('Volta');
      expect(cubit.state.form.squad.map((p) => p.id), ['p3']);
    });

    test('contagens não ficam negativas', () {
      cubit.decrementGoals();
      cubit.incrementAssists();
      expect([cubit.state.form.goals, cubit.state.form.assists], [0, 1]);
    });

    test('cadastra, limpa e o jogador entra no elenco', () async {
      cubit.changeName('Rafael');
      cubit.incrementGoals();
      await cubit.submit();
      expect(repository.created.single.goals, 1);
      final form = cubit.state.form;
      expect(cubit.state, isA<SuccessPlayerFormState>());
      expect([form.name, form.goals, form.selectedTeam], ['', 0, 'Lava Jato']);
      expect(form.squad.map((p) => p.name), ['Dudu', 'João Pedro', 'Rafael']);
    });
  });
}
