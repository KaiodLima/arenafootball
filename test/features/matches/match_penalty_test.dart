import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/live_match_card.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/domain/match_report_sheet.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_report_page.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _Squads implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right([PlayerDTO(id: 'p-$teamName', name: 'Atleta $teamName', team: teamName, teamId: teamId)]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Save implements SaveMatchReportUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Delay implements DelayMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Phase implements SetMatchPhaseUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Voting implements ToggleMatchVotingUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Create implements CreatePlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _match =
    MatchDTO(id: 'm1', homeTeam: 'Alfa', awayTeam: 'Beta', homeTeamId: 'tA', awayTeamId: 'tB', venue: 'Campo');
const _taker = PlayerDTO(id: 'a1', name: 'Ana', team: 'Alfa', teamId: 'tA');
const _keeper = PlayerDTO(id: 'b1', name: 'Bia', team: 'Beta', teamId: 'tB');

MatchReportCubit _cubit() => MatchReportCubit(_Squads(), _Save(), _Phase(), _Voting(), _Create(), _Delay());

void main() {
  test('gol de pênalti e pênalti perdido gravam e leem no mesmo formato', () {
    const goal = MatchGoal(id: 'g', side: MatchSide.home, scorerId: 'a1', scorerName: 'Ana', minute: 12, penalty: true);
    expect(goal.toMap()['penalti'], isTrue);
    expect(MatchGoal.fromMap(goal.toMap()), goal);
    expect(const MatchGoal(id: 'x', side: MatchSide.home).toMap().containsKey('penalti'), isFalse);
    // Pênalti não tem garçom.
    expect(const MatchGoal(id: 'g', side: MatchSide.home, scorerId: 'a', assistantId: 'b', penalty: true).hasAssistant,
        isFalse);

    const missed = MatchMissedPenalty(
      id: 'p',
      side: MatchSide.away,
      playerId: 'b1',
      playerName: 'Bia',
      minute: 70,
      keeperId: 'a9',
      keeperName: 'Goleiro',
    );
    expect(MatchMissedPenalty.fromMap(missed.toMap()), missed);
    expect(missed.toMap()['motivo'], 'defendido');
    // Para fora não guarda goleiro.
    const wide = MatchMissedPenalty(id: 'w', side: MatchSide.home, miss: PenaltyMiss.wide, keeperName: 'X');
    expect(wide.toMap().containsKey('goleiro'), isFalse);
    expect(wide.hasKeeper, isFalse);

    final dto = _match.copyWith(missedPenalties: [missed]);
    expect(MatchDTO.fromCache(dto.toCache()).missedPenalties, [missed]);
  });

  test('linha do tempo, participantes, PDF e card ao vivo', () {
    final match = _match.copyWith(
      goals: const [
        MatchGoal(id: 'g', side: MatchSide.home, scorerId: 'a1', scorerName: 'Ana', minute: 30, penalty: true)
      ],
      missedPenalties: const [
        MatchMissedPenalty(
            id: 'p', side: MatchSide.away, playerId: 'b1', playerName: 'Bia', minute: 10, keeperId: 'a9'),
      ],
      lineup: const MatchLineup(home: [
        LineupEntry(playerId: 'a1', playerName: 'Ana')
      ], away: [
        LineupEntry(playerId: 'b2', playerName: 'Caio'),
      ]),
    );
    final events = MatchReport.timeline(match.goals, match.bookings, match.substitutions, match.missedPenalties);
    expect(events.map((e) => e.id), ['p', 'g']);
    expect(events.first.isMissedPenalty, isTrue);
    expect(MatchReport.participants(match, MatchSide.away), {'b2', 'b1'});
    expect(MatchReport.participants(match, MatchSide.home), {'a1', 'a9'});

    final sheet = MatchReportSheet.of(match);
    expect(sheet.goals.single.penalty, isTrue);
    expect(sheet.missedPenalties.single.penalty.playerName, 'Bia');
    expect((sheet.homeGoals, sheet.awayGoals), (1, 0));

    // Card ao vivo: só o gol (com a marca), o perdido não entra.
    final live = LiveMatchCard.eventsOf(match);
    expect(live.map((e) => e.id), ['g']);
    expect(live.single.penalty, isTrue);
    expect(live.single.toMap()['penalti'], isTrue);
  });

  test('cubit: convertido soma no placar sem garçom; perdido não; desfazer', () async {
    final cubit = _cubit();
    addTearDown(cubit.close);
    await cubit.load(match: _match);
    cubit.addGoal(MatchSide.home, scorer: _taker, assistant: _keeper, minute: 5, penalty: true);
    final goal = cubit.state.match!.goals.single;
    expect((goal.penalty, goal.assistantId), (true, ''));

    cubit.addMissedPenalty(MatchSide.home, taker: _taker, miss: PenaltyMiss.saved, keeper: _keeper, minute: 40);
    expect(cubit.state.match!.goals, hasLength(1));
    expect(cubit.state.match!.missedPenalties.single.keeperName, 'Bia');
    expect(cubit.state.lastEvent?.isMissedPenalty, isTrue);
    expect(cubit.state.dirty, isTrue);
    expect(cubit.state.changeCount, 2);

    cubit.undoLast();
    expect(cubit.state.match!.missedPenalties, isEmpty);

    // Editar o gol de pênalti mantém a marca e segue sem garçom.
    cubit.updateGoal(goal.id, scorer: _taker, assistant: _keeper, minute: 6);
    final edited = cubit.state.match!.goals.single;
    expect((edited.penalty, edited.assistantId, edited.minute), (true, '', 6));
  });

  testWidgets('tela: Pênalti → defendido → cobrador → goleiro', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final cubit = _cubit();
    await cubit.load(match: _match);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider.value(value: cubit, child: const MatchReportPage()),
    ));
    await tester.pump();

    await tester.tap(find.text('Pênalti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perdido · defendido'));
    await tester.pumpAndSettle();
    expect(find.text('Quem cobrou · Alfa'), findsOneWidget);
    await tester.tap(find.text('Atleta Alfa'));
    await tester.pumpAndSettle();
    expect(find.text('Quem defendeu? (opcional)'), findsOneWidget);
    await tester.tap(find.text('Atleta Beta'));
    await tester.pumpAndSettle();

    expect(find.text('0 – 0'), findsOneWidget);
    expect(find.text('Pênalti perdido · defendido por Atleta Beta'), findsOneWidget);
    final missed = cubit.state.match!.missedPenalties.single;
    expect((missed.playerName, missed.keeperName), ('Atleta Alfa', 'Atleta Beta'));

    // Convertido: vira gol, sem passo do garçom.
    await tester.tap(find.text('Pênalti').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convertido (gol)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atleta Beta'));
    await tester.pumpAndSettle();
    expect(find.text('0 – 1'), findsOneWidget);
    expect(find.text('De pênalti'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });
}
