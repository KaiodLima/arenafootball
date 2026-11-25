import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_report_page.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';

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

void main() {
  testWidgets('súmula monta as 3 abas e o lance entra na linha do tempo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final cubit = MatchReportCubit(_Squads(), _Save(), _Phase(), _Voting(), _Create(), _Delay());
    await cubit.load(
      match: const MatchDTO(
          id: 'm1', homeTeam: 'Alfa', awayTeam: 'Beta', homeTeamId: 'tA', awayTeamId: 'tB', venue: 'Campo'),
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider.value(value: cubit, child: const MatchReportPage()),
    ));
    await tester.pump();
    expect(find.text('Súmula'), findsOneWidget);
    expect(find.text('0 – 0'), findsOneWidget);
    expect(find.text('Nenhum lance ainda. Use os botões acima para lançar gols e cartões.'), findsOneWidget);

    // Painel do mandante: Gol → autor → "Sem assistência" (2 toques).
    await tester.tap(find.text('Gol').first);
    await tester.pumpAndSettle();
    expect(find.text('Gol do Alfa'), findsOneWidget);
    await tester.tap(find.text('Atleta Alfa'));
    await tester.pumpAndSettle();
    expect(find.text('Quem deu o passe?'), findsOneWidget);
    await tester.tap(find.text('Sem assistência'));
    await tester.pumpAndSettle();
    expect(find.text('1 – 0'), findsOneWidget);
    expect(find.text('1–0'), findsOneWidget); // placar parcial na linha do tempo
    expect(find.text('1 mudança'), findsOneWidget);

    // Desfazer pelo aviso.
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('0 – 0'), findsOneWidget);

    await tester.tap(find.text('Escalação'));
    await tester.pumpAndSettle();
    expect(find.text('Atleta Alfa'), findsOneWidget);
    expect(find.text('Titulares 0/11'), findsOneWidget);

    await tester.tap(find.text('Jogo'));
    await tester.pumpAndSettle();
    expect(find.text('Quando'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  group('no máximo 11 titulares', () {
    final full = MatchLineup(home: [
      for (var i = 1; i <= 11; i++) LineupEntry(playerId: 's$i', playerName: 'Titular $i'),
    ]);
    MatchDTO match() => MatchDTO(
        id: 'm1', homeTeam: 'Alfa', awayTeam: 'Beta', homeTeamId: 'tA', awayTeamId: 'tB', venue: 'Campo', lineup: full);

    test('domínio e cubit: o 12º não entra; reserva libera a vaga', () async {
      expect(MatchReport.canAddStarter(full.home, 'novo'), isFalse);
      expect(MatchReport.canAddStarter(full.home, 's1'), isTrue);
      final cubit = MatchReportCubit(_Squads(), _Save(), _Phase(), _Voting(), _Create(), _Delay());
      addTearDown(cubit.close);
      await cubit.load(match: match());
      const extra = PlayerDTO(id: 'novo', name: 'Novo', team: 'Alfa', teamId: 'tA');
      cubit.setRole(MatchSide.home, extra, LineupRole.starter);
      expect(cubit.state.notice, MatchReportNotice.startersFull);
      expect(MatchReport.lineupCount(cubit.state.match!.lineup.home).starters, 11);
      expect(cubit.state.match!.lineup.home.any((e) => e.playerId == 'novo'), isFalse);
      cubit.setRole(MatchSide.home, extra, LineupRole.sub);
      expect(cubit.state.match!.lineup.home.any((e) => e.playerId == 'novo' && !e.starter), isTrue);
      cubit.setRole(
          MatchSide.home, const PlayerDTO(id: 's1', name: 'Titular 1', team: 'Alfa', teamId: 'tA'), LineupRole.sub);
      cubit.setRole(MatchSide.home, extra, LineupRole.starter);
      expect(cubit.state.notice, isNot(MatchReportNotice.startersFull));
      expect(MatchReport.lineupCount(cubit.state.match!.lineup.home).starters, 11);
      expect(cubit.state.match!.lineup.home.any((e) => e.playerId == 'novo' && e.starter), isTrue);
    });

    testWidgets('tela: "Titular" com 11 titulares avisa e não escala', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final cubit = MatchReportCubit(_Squads(), _Save(), _Phase(), _Voting(), _Create(), _Delay());
      await cubit.load(match: match());
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider.value(value: cubit, child: const MatchReportPage()),
      ));
      await tester.pump();
      await tester.tap(find.text('Escalação'));
      await tester.pumpAndSettle();
      expect(find.text('Titulares 11/11'), findsOneWidget);
      // O atleta fora da escalação fica por último.
      await tester.scrollUntilVisible(find.text('Atleta Alfa'), 200, scrollable: find.byType(Scrollable).last);
      final alfaStarter = find.descendant(
        of: find.ancestor(of: find.text('Atleta Alfa'), matching: find.byType(Container)).first,
        matching: find.byKey(const ValueKey('report-role-starter')),
      );
      await tester.ensureVisible(alfaStarter);
      await tester.pumpAndSettle();
      await tester.tap(alfaStarter);
      await tester.pump();
      expect(find.text('Já há 11 titulares. Tire um titular para escalar outro.'), findsOneWidget);
      // O contador pode ter rolado para fora da tela: confere pelo estado.
      expect(MatchReport.lineupCount(cubit.state.match!.lineup.home).starters, 11);
      await cubit.close();
    });
  });
}
