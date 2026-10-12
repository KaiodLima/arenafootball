import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_team_usecase.dart';

class _FakeWatch implements WatchTeamPlayersUseCase {
  int calls = 0;

  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({required String teamName, String? season}) {
    calls++;
    return Stream.value(const Right([PlayerDTO(id: 'p1', name: 'Kaio', team: 'Volta')]));
  }
}

class _FakeDelete implements DeleteTeamUseCase {
  Either<Failure, void> result = const Right(null);
  TeamDTO? deleted;
  String? season;

  @override
  Future<Either<Failure, void>> call(TeamDTO team, {String? season}) async {
    deleted = team;
    this.season = season;
    return result;
  }
}

void main() {
  const team = TeamDTO(id: '3_Volta', name: 'Volta');
  late _FakeWatch watch;
  late _FakeDelete delete;
  late TeamPlayersCubit cubit;

  setUp(() async {
    watch = _FakeWatch();
    delete = _FakeDelete();
    cubit = TeamPlayersCubit(watch, delete)..watch(teamName: 'Volta', season: '2024');
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => cubit.close());

  test('excluir usa a temporada da tela e avisa com o nome', () async {
    await cubit.deleteTeam(team);
    expect(delete.deleted, team);
    expect(delete.season, '2024');
    expect(cubit.state, isA<DeletedTeamPlayersState>().having((s) => s.teamName, 'teamName', 'Volta'));
  });

  test('falha mantém o elenco e volta a acompanhar o time', () async {
    delete.result = Left(ErrorWithMessage('sem permissão'));
    final states = <TeamPlayersState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.deleteTeam(team);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // O erro vira snackbar; em seguida o elenco volta a ser acompanhado.
    final error = states.whereType<ErrorTeamPlayersState>().single;
    expect(error.errorMessage, 'sem permissão');
    expect(error.players.single.name, 'Kaio');
    expect(states.whereType<DeletedTeamPlayersState>(), isEmpty);
    expect(watch.calls, 2);
    expect(cubit.state.players.single.name, 'Kaio');
  });
}
