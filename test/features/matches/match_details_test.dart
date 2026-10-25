import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_match_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_details_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_details_sections.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', teamId: '1', position: 'atacante');
const _ana = PlayerDTO(id: 'ana', name: 'Ana', team: 'Lava Jato', teamId: '1', position: 'meia');
const _gil = PlayerDTO(id: 'gil', name: 'Gil', team: 'Lava Jato', teamId: '1', position: 'goleiro');
const _bia = PlayerDTO(id: 'bia', name: 'Bia', team: 'Lava Jato', teamId: '1');
// Joga a competição 7 pelo outro time: fora do elenco do Lava Jato nela.
const _leo = PlayerDTO(id: 'leo', name: 'Leo', team: 'Lava Jato', teamId: '1', enrollments: [
  PlayerEnrollment(championshipId: 9, teamId: '1', team: 'Lava Jato'),
  PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta'),
]);

const _goals = [
  MatchGoal(
      id: 'a', side: MatchSide.home, scorerId: 'dudu', scorerName: 'Dudu', assistantId: 'ana', assistantName: 'Ana'),
  MatchGoal(id: 'b', side: MatchSide.away, scorerId: 'rafa', scorerName: 'Rafa'),
  MatchGoal(id: 'c', side: MatchSide.home, scorerId: 'dudu', scorerName: 'Dudu'),
];

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  homeTeamId: '1',
  awayTeamId: '2',
  championshipId: 7,
  homeGoals: 2,
  awayGoals: 1,
  goals: _goals,
);

class _WatchMatch implements WatchMatchUseCase {
  final controller = StreamController<Either<Failure, MatchDTO?>>.broadcast();

  @override
  Stream<Either<Failure, MatchDTO?>> call({required String matchId, String? season}) => controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Squads implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(teamName == 'Lava Jato' ? const [_dudu, _ana, _leo] : const []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SetStatus implements SetMatchPhaseUseCase {
  final calls = <MatchPhase>[];

  @override
  Future<Either<Failure, MatchDTO>> call({required MatchDTO match, required MatchPhase phase, String? season}) async {
    calls.add(phase);
    return Right(match.copyWith(manualStatus: MatchManualStatus.live));
  }
}

class _Toggle implements ToggleMatchVotingUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('números da partida por atleta e ordem: quem participou, depois posição e nome', () {
    final lines = MatchPlayerLine.of(_goals, const [_bia, _gil, _ana, _dudu]);
    expect(lines.map((l) => l.player.id), ['dudu', 'ana', 'gil', 'bia']);
    expect(lines.first.goals, 2);
    expect(lines[1].assists, 1);
    expect(lines[2].involved, isFalse);
  });

  test('elenco da partida: só quem joga pelo time na competição', () {
    final squad = matchSquad(const [_leo, _dudu, _ana], _match, MatchSide.home);
    expect(squad.map((p) => p.id), ['ana', 'dudu']);
    final friendly =
        matchSquad(const [_leo, _dudu], const MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta'), MatchSide.home);
    expect(friendly.map((p) => p.id), ['dudu', 'leo']);
  });

  test('cubit: começa com a partida recebida, carrega elencos e o stream atualiza', () async {
    final watch = _WatchMatch();
    final setStatus = _SetStatus();
    final cubit = MatchDetailsCubit(watch, _Squads(), _Toggle(), setStatus, match: _match);
    expect(cubit.state.match, _match);
    await cubit.start(season: '2026');
    expect(cubit.state.squadsLoading, isFalse);
    expect(cubit.state.homeSquad.map((p) => p.id), ['ana', 'dudu']);
    expect(cubit.state.selectedLines.first.player.id, 'dudu');

    watch.controller.add(Right(_match.copyWith(bestPlayer: 'Dudu')));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.bestPlayer?.id, 'dudu');

    await cubit.setPhase(MatchPhase.start);
    expect(setStatus.calls, [MatchPhase.start]);
    expect(cubit.state.match.manualStatus, MatchManualStatus.live);

    watch.controller.add(const Right(null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.deleted, isTrue);
    await cubit.close();
  });

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ));

  testWidgets('linha do tempo: autores, passe e placar parcial', (tester) async {
    await pump(tester, const MatchGoalsTimeline(match: _match));
    expect(find.text('Dudu'), findsNWidgets(2));
    expect(find.text('assist. Ana'), findsOneWidget);
    expect(find.text('Rafa'), findsOneWidget);
    expect(find.text('2-1'), findsOneWidget);
  });

  testWidgets('partida antiga sem a lista: gols sem autor e o aviso', (tester) async {
    await pump(tester, const MatchGoalsTimeline(match: MatchDTO(homeTeam: 'A', awayTeam: 'B', homeGoals: 1)));
    expect(find.text('Gol'), findsOneWidget);
    expect(find.text('Autores dos gols não informados'), findsOneWidget);
  });
}
