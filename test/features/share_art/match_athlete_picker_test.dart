import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/match_athlete_picker_cubit.dart';

/// Um controlador por time: o teste manda a resposta do cache e depois a do servidor.
class _Squads implements WatchTeamPlayersUseCase {
  final controllers = <String, StreamController<Either<Failure, List<PlayerDTO>>>>{};

  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      (controllers[teamName] = StreamController()).stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  homeTeamId: 't1',
  awayTeamId: 't2',
  championshipId: 11,
);

void main() {
  test('admin vê o elenco geral dos dois times, sem filtrar pela competição, e ao vivo', () async {
    final squads = _Squads();
    final cubit = MatchAthletePickerCubit(squads)..load(_match, '2026');
    // Inscrito só em outra competição: aparece mesmo assim (elenco geral).
    const zeca = PlayerDTO(
      id: 'z',
      name: 'Zeca',
      team: 'Volta',
      teamId: 't2',
      enrollments: [PlayerEnrollment(championshipId: 99, teamId: 't2', team: 'Volta')],
      hasEnrollmentField: true,
    );
    squads.controllers['Lava Jato']!.add(const Right(
        [PlayerDTO(id: 'b', name: 'Bruno', team: 'Lava Jato'), PlayerDTO(id: 'a', name: 'Ana', team: 'Lava Jato')]));
    // O visitante chega vazio do cache e completo do servidor.
    squads.controllers['Volta']!.add(const Right([]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.home.map((p) => p.name), ['Ana', 'Bruno']);
    expect(cubit.state.away, isEmpty);
    expect(cubit.state.awayLoading, isFalse);
    squads.controllers['Volta']!.add(const Right([zeca]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.away.map((p) => p.name), ['Zeca']);
    await cubit.close();
  });
}
