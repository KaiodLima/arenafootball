import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/formation.dart';
import 'package:arena_soccer/features/matches/domain/match_pitch.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/publish_goal_cards_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_report_page.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_lineup_pitch.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_formation.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

// Prévia em PNG fora do CI: MATCH_PITCH_PREVIEW=1 flutter test test/features/matches/match_pitch_test.dart
// → build/match_pitch_previews/<caso>.png

LineupEntry _e(String id, {bool starter = true, int? number}) =>
    LineupEntry(playerId: id, playerName: 'Atleta $id', starter: starter, number: number);

MatchDTO _match({List<LineupEntry> home = const [], List<LineupEntry> away = const [], bool confirmed = true}) =>
    MatchDTO(
      id: 'm1',
      homeTeam: 'Alfa',
      awayTeam: 'Beta',
      homeTeamId: 'tA',
      awayTeamId: 'tB',
      lineup: MatchLineup(home: home, away: away),
      lineupConfirmed: confirmed,
    );

// ------------------------------------------------------------------- fakes

class _Squads implements WatchTeamPlayersUseCase {
  final Map<String, List<PlayerDTO>> byTeam;

  _Squads([this.byTeam = const {}]);

  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(byTeam[teamId] ?? const []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Save implements SaveMatchReportUseCase {
  MatchDTO? edited;

  @override
  Future<Either<Failure, ({MatchDTO match, int publishedCards})>> call({
    required MatchDTO original,
    required List<MatchGoal> goalsBefore,
    required MatchDTO edited,
    bool publishCards = true,
    String? season,
  }) async {
    this.edited = edited;
    return Right((match: edited, publishedCards: 0));
  }

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

class _Goals implements UpdateMatchGoalsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cards implements PublishGoalCardsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Matches implements IMatchesRepository {
  MatchDTO? saved;

  @override
  Future<Either<Failure, void>> updateReport(MatchDTO match, {String? season}) async {
    saved = match;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MatchReportCubit _cubit(Map<String, List<PlayerDTO>> squads, _Save save) =>
    MatchReportCubit(_Squads(squads), save, _Phase(), _Voting(), _Create(), _Delay());

// ------------------------------------------------------------------ dados

const _positions442 = {
  'gk': 'goleiro',
  'lb': 'lateral',
  'cb1': 'zagueiro',
  'cb2': 'zagueiro',
  'rb': 'lateral',
  'v1': 'volante',
  'm1': 'meia',
  'm2': 'meia',
  'm3': 'meia',
  'a1': 'atacante',
  'a2': 'atacante',
};

/// Elenco de 11 com nomes reais, posição e camisa (prévias e testes).
List<(String id, String name, String position, int number)> _eleven(String prefix) => [
      ('${prefix}gk', 'Marcos Rocha', 'goleiro', 1),
      ('${prefix}lb', 'Carlos Henrique', 'lateral', 6),
      ('${prefix}cb1', 'Diego Ferreira', 'zagueiro', 3),
      ('${prefix}cb2', 'Thiago Almeida', 'zagueiro', 4),
      ('${prefix}rb', 'Bruno Cavalcanti', 'lateral', 2),
      ('${prefix}v1', 'Josué Nascimento', 'volante', 5),
      ('${prefix}m1', 'Rafael Souza Júnior', 'meia', 8),
      ('${prefix}m2', 'Pedro Bittencourt', 'meia', 10),
      ('${prefix}m3', 'Lucas', 'meia', 7),
      ('${prefix}a1', 'Gabriel Albuquerque', 'atacante', 9),
      ('${prefix}a2', 'Vinícius Montenegro', 'atacante', 11),
    ];

List<(String id, String name, String position, int number)> _seven(String prefix) => [
      ('${prefix}gk', 'Zé Carlos', 'goleiro', 1),
      ('${prefix}cb1', 'Anderson Lima', 'zagueiro', 3),
      ('${prefix}cb2', 'Felipe', 'zagueiro', 4),
      ('${prefix}m1', 'Matheus Oliveira', 'meia', 8),
      ('${prefix}m2', 'Caio', '', 10),
      ('${prefix}m3', 'Renan Batista', 'volante', 5),
      ('${prefix}a1', 'Igor Costa', 'atacante', 9),
    ];

List<PlayerDTO> _squad(List<(String, String, String, int)> rows, String teamId) => [
      for (final (id, name, position, _) in rows) PlayerDTO(id: id, name: name, team: teamId, position: position),
    ];

List<LineupEntry> _lineup(List<(String, String, String, int)> rows) => [
      for (final (id, name, _, number) in rows) LineupEntry(playerId: id, playerName: name, number: number),
    ];

void main() {
  group('MatchPitch: linhas e lugares', () {
    test('linhas pela posição; laterais nas pontas da defesa; formação', () {
      final match = _match(home: [for (final id in _positions442.keys) _e(id)], away: [_e('x')]);
      final spots = MatchPitch.side(match, MatchSide.home, _positions442);
      PitchLine lineOf(String id) => spots.firstWhere((s) => s.playerId == id).line;
      expect(lineOf('gk'), PitchLine.goalkeeper);
      expect([lineOf('lb'), lineOf('cb1'), lineOf('rb')], everyElement(PitchLine.defense));
      expect([lineOf('v1'), lineOf('m1')], everyElement(PitchLine.midfield));
      expect(lineOf('a1'), PitchLine.attack);
      final defense = spots.where((s) => s.line == PitchLine.defense).toList()..sort((a, b) => a.x.compareTo(b.x));
      expect(defense.first.playerId, 'lb');
      expect(defense.last.playerId, 'rb');
      expect(MatchPitch.formation(spots), '4-4-2');
      // Mandante na metade de baixo, goleiro mais perto do gol que o ataque.
      expect(spots.every((s) => s.y > 0.5 && s.y < 1), isTrue);
      final gk = spots.firstWhere((s) => s.playerId == 'gk');
      final a1 = spots.firstWhere((s) => s.playerId == 'a1');
      expect(gk.y, greaterThan(a1.y));
      expect(gk.x, closeTo(0.5, 1e-9));
    });

    test('sem posição: a linha com menos gente, o meio no empate; nunca o gol', () {
      final lines = MatchPitch.assignLines(
        [_e('d1'), _e('d2'), _e('a1'), _e('u1'), _e('u2'), _e('u3')],
        const {'d1': 'zagueiro', 'd2': 'zagueiro', 'a1': 'atacante'},
      );
      // u1: meio (0) — u2: meio e ataque empatam com 1 → meio? não: o meio já tem 1 e o ataque 1 → meio.
      expect(lines[PitchLine.midfield]!.map((e) => e.playerId), ['u1', 'u2']);
      // u3: meio 2, defesa 2, ataque 1 → ataque.
      expect(lines[PitchLine.attack]!.map((e) => e.playerId), ['a1', 'u3']);
      expect(lines[PitchLine.goalkeeper], isEmpty);
      // Todos sem posição: espalhados, começando pelo meio.
      final unknown = MatchPitch.assignLines([for (var i = 0; i < 4; i++) _e('u$i')], const {});
      expect(unknown[PitchLine.midfield]!.length, 2);
      expect(unknown[PitchLine.defense]!.length, 1);
      expect(unknown[PitchLine.attack]!.length, 1);
    });

    test('dois goleiros: o 2º vai para a defesa', () {
      final lines = MatchPitch.assignLines([_e('g1'), _e('g2')], const {'g1': 'goleiro', 'g2': 'goleiro'});
      expect(lines[PitchLine.goalkeeper]!.single.playerId, 'g1');
      expect(lines[PitchLine.defense]!.single.playerId, 'g2');
    });

    test('7 x 7: mais espaçado; visitante espelhado na metade de cima', () {
      final home = _lineup(_seven('h'));
      final away = _lineup(_seven('a'));
      final positions = {for (final (id, _, pos, _) in [..._seven('h'), ..._seven('a')]) id: pos};
      final match = _match(home: home, away: away);
      final h = MatchPitch.side(match, MatchSide.home, positions);
      final a = MatchPitch.side(match, MatchSide.away, positions);
      expect(h.length, 7);
      // Caio (sem posição) vai para o ataque, a linha com menos gente.
      expect(MatchPitch.formation(h), '2-2-2');
      expect(a.every((s) => s.y < 0.5), isTrue);
      for (final spot in h) {
        final mirror = a.firstWhere((s) => s.playerId == 'a${spot.playerId.substring(1)}');
        expect(mirror.x, closeTo(1 - spot.x, 1e-9));
        expect(mirror.y, closeTo(1 - spot.y, 1e-9));
      }
      // Dois zagueiros bem mais afastados que os 4 de uma linha de 11.
      final cbs = h.where((s) => s.line == PitchLine.defense).map((s) => s.x).toList()..sort();
      expect(cbs.last - cbs.first, greaterThan(0.4));
    });

    test('linha com mais de 5: zigue-zague (ímpares mais atrás)', () {
      final match = _match(home: [for (var i = 0; i < 6; i++) _e('m$i')], away: [_e('x')]);
      final spots = MatchPitch.side(match, MatchSide.home, {for (var i = 0; i < 6; i++) 'm$i': 'meia'});
      final ys = spots.map((s) => s.y).toSet();
      expect(ys.length, 2);
    });

    test('em campo: substituição e vermelho; selos de gol, cartão e "entrou"', () {
      final match = _match(home: [
        _e('p1', number: 9),
        _e('p2'),
        _e('p3'),
        _e('r1', starter: false),
      ], away: [
        _e('x')
      ]).copyWith(
        substitutions: const [
          MatchSubstitution(id: 's1', side: MatchSide.home, outId: 'p2', outName: 'p2', inId: 'r1', inName: 'r1'),
        ],
        bookings: const [
          MatchBooking(id: 'c1', side: MatchSide.home, type: BookingType.red, playerId: 'p3'),
          MatchBooking(id: 'c2', side: MatchSide.home, type: BookingType.yellow, playerId: 'p1'),
        ],
        goals: const [
          MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'p1'),
          MatchGoal(id: 'g2', side: MatchSide.home, scorerId: 'p1'),
        ],
      );
      final spots = MatchPitch.side(match, MatchSide.home, const {});
      expect(spots.map((s) => s.playerId).toSet(), {'p1', 'r1'});
      final p1 = spots.firstWhere((s) => s.playerId == 'p1');
      expect((p1.goals, p1.booking, p1.subbedIn, p1.entry.number), (2, BookingType.yellow, false, 9));
      expect(spots.firstWhere((s) => s.playerId == 'r1').subbedIn, isTrue);
    });

    test('nome curto: apelido, sobrenome, Júnior com o nome de antes', () {
      expect(MatchPitch.shortName('Lucas'), 'Lucas');
      expect(MatchPitch.shortName('Gabriel Albuquerque'), 'Albuquerque');
      expect(MatchPitch.shortName('Rafael Souza Júnior'), 'Souza Júnior');
      expect(MatchPitch.shortName('Neto Filho'), 'Neto');
      expect(MatchPitch.shortName('  '), '');
    });
  });

  group('confirmação das escalações', () {
    test('vale com titular nos dois times; cai sem titular num deles', () {
      final ok = _match(home: [_e('a')], away: [_e('b')]);
      expect(MatchReport.canConfirmLineup(ok.lineup), isTrue);
      expect(MatchReport.lineupConfirmedValid(ok), isTrue);
      expect(MatchPitch.visible(ok), isTrue);
      final onlySubs = _match(home: [_e('a')], away: [_e('b', starter: false)]);
      expect(MatchReport.canConfirmLineup(onlySubs.lineup), isFalse);
      expect(MatchReport.lineupConfirmedValid(onlySubs), isFalse);
      expect(MatchReport.keepLineupConfirmation(onlySubs).lineupConfirmed, isFalse);
      expect(MatchPitch.visible(ok.copyWith(lineupConfirmed: false)), isFalse);
    });

    test('Firestore: só grava quando confirmada; volta do cache com a hora', () {
      final at = DateTime(2026, 11, 20, 15, 30);
      final confirmed = _match(home: [_e('a')], away: [_e('b')]).copyWith(lineupConfirmedAt: () => at);
      expect(confirmed.toMap()[MatchDTO.lineupConfirmedField], isTrue);
      expect(confirmed.toMap().containsKey(MatchDTO.lineupConfirmedAtField), isTrue);
      expect(_match(confirmed: false).toMap().containsKey(MatchDTO.lineupConfirmedField), isFalse);
      final cached = MatchDTO.fromCache(confirmed.toCache());
      expect((cached.lineupConfirmed, cached.lineupConfirmedAt), (true, at));
    });

    test('salvar súmula grava a confirmação (com a hora na 1ª vez)', () async {
      final matches = _Matches();
      final save = SaveMatchReportUseCase(_Goals(), _Cards(), matches);
      final original = _match(home: [_e('a')], away: [_e('b')], confirmed: false);
      final response = await save(
        original: original,
        goalsBefore: const [],
        edited: original.copyWith(lineupConfirmed: true),
        publishCards: false,
      );
      expect(matches.saved!.lineupConfirmed, isTrue);
      expect(matches.saved!.lineupConfirmedAt, isNull); // o servidor carimba
      expect(response.right.match.lineupConfirmedAt, isNotNull);
    });

    test('cubit: confirma, desfaz e cai ao tirar o último titular', () async {
      final save = _Save();
      final cubit = _cubit(const {}, save);
      addTearDown(cubit.close);
      await cubit.load(match: _match(home: [_e('a')], away: const [], confirmed: false));
      cubit.confirmLineup();
      expect(cubit.state.match!.lineupConfirmed, isFalse); // visitante sem titular
      cubit.setRole(MatchSide.away, const PlayerDTO(id: 'b', name: 'B', team: 'Beta'), LineupRole.starter);
      cubit.confirmLineup();
      expect(cubit.state.match!.lineupConfirmed, isTrue);
      expect(cubit.state.notice, MatchReportNotice.lineupConfirmed);
      expect(cubit.state.dirty, isTrue);
      // Mexer na escalação mantém; ficar sem titular derruba.
      cubit.setNumber(MatchSide.home, 'a', 7);
      expect(cubit.state.match!.lineupConfirmed, isTrue);
      cubit.setRole(MatchSide.away, const PlayerDTO(id: 'b', name: 'B', team: 'Beta'), LineupRole.sub);
      expect(cubit.state.match!.lineupConfirmed, isFalse);
      cubit.setRole(MatchSide.away, const PlayerDTO(id: 'b', name: 'B', team: 'Beta'), LineupRole.starter);
      cubit.confirmLineup();
      cubit.undoLineupConfirmation();
      expect(cubit.state.match!.lineupConfirmed, isFalse);
    });
  });

  group('tela', () {
    Widget app(Widget child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
          ),
        );

    MatchDTO full() => _match(home: _lineup(_eleven('h')), away: _lineup(_eleven('a'))).copyWith(
          goals: const [
            MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'ha1', scorerName: 'Gabriel Albuquerque'),
          ],
          bookings: const [
            MatchBooking(id: 'c1', side: MatchSide.away, type: BookingType.yellow, playerId: 'acb1'),
          ],
        );

    Widget card(MatchDTO match, {void Function(String id)? onTap}) => MatchLineupPitchCard(
          match: match,
          homeSquad: _squad(_eleven('h'), 'tA'),
          awaySquad: _squad(_eleven('a'), 'tB'),
          homeColor: TeamColor.red.color,
          awayColor: TeamColor.blue.color,
          onPlayerTap: (spot, _) => onTap?.call(spot.playerId),
        );

    testWidgets('sem confirmação, nada; confirmada, os 22 com número e selos', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(card(full().copyWith(lineupConfirmed: false))));
      expect(find.text('Escalações'), findsNothing);
      expect(find.byKey(const ValueKey('pitch-casa-ha1')), findsNothing);

      String? tapped;
      await tester.pumpWidget(app(card(full(), onTap: (id) => tapped = id)));
      expect(find.text('Escalações'), findsOneWidget);
      expect(find.byType(GestureDetector).evaluate().length, greaterThanOrEqualTo(22));
      expect(find.text('4-4-2'), findsNWidgets(2));
      final striker = find.byKey(const ValueKey('pitch-casa-ha1'));
      expect(find.descendant(of: striker, matching: find.text('9')), findsOneWidget);
      expect(find.descendant(of: striker, matching: find.byKey(const ValueKey('pitch-goals'))), findsOneWidget);
      expect(find.descendant(of: striker, matching: find.text('Albuquerque')), findsOneWidget);
      final booked = find.byKey(const ValueKey('pitch-fora-acb1'));
      expect(find.descendant(of: booked, matching: find.byKey(const ValueKey('pitch-card-amarelo'))), findsOneWidget);
      await tester.tap(striker);
      expect(tapped, 'ha1');
      expect(tester.takeException(), isNull);
    });

    testWidgets('súmula: "Confirmar escalações" marca e o "Salvar" grava', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final save = _Save();
      final cubit = _cubit({
        'tA': const [PlayerDTO(id: 'pa', name: 'Atleta Alfa', team: 'Alfa', teamId: 'tA')],
        'tB': const [PlayerDTO(id: 'pb', name: 'Atleta Beta', team: 'Beta', teamId: 'tB')],
      }, save);
      await cubit.load(match: _match(home: [_e('pa')], away: const [], confirmed: false));
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider.value(value: cubit, child: const MatchReportPage()),
      ));
      await tester.pump();
      await tester.tap(find.text('Escalação'));
      await tester.pumpAndSettle();
      // Visitante sem titular: o botão fica travado com o aviso.
      expect(find.text('Confirme com pelo menos um titular em cada time'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('report-lineups-confirm')));
      await tester.pump();
      expect(cubit.state.match!.lineupConfirmed, isFalse);

      cubit.setRole(MatchSide.away, const PlayerDTO(id: 'pb', name: 'Atleta Beta', team: 'Beta'), LineupRole.starter);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('report-lineups-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('report-lineups-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('report-lineups-confirmed')), findsOneWidget);
      expect(find.text('Escalações confirmadas'), findsOneWidget);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(save.edited!.lineupConfirmed, isTrue);
      expect(tester.takeException(), isNull);
      await cubit.close();
    });
  });

  testWidgets('prévias', (tester) async {
    await tester.runAsync(() async {
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/match_pitch_previews').createSync(recursive: true);

    MatchDTO eleven() => _match(home: _lineup(_eleven('h')), away: _lineup(_eleven('a'))).copyWith(
          goals: const [
            MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'ha1'),
            MatchGoal(id: 'g2', side: MatchSide.home, scorerId: 'ha1'),
            MatchGoal(id: 'g3', side: MatchSide.away, scorerId: 'am2'),
          ],
          bookings: const [
            MatchBooking(id: 'c1', side: MatchSide.away, type: BookingType.yellow, playerId: 'acb1'),
            MatchBooking(id: 'c2', side: MatchSide.home, type: BookingType.yellow, playerId: 'hv1'),
          ],
          substitutions: const [
            MatchSubstitution(
                id: 's1', side: MatchSide.home, outId: 'hm3', outName: 'Lucas', inId: 'hsub', inName: 'Wellington Dias'),
          ],
          lineup: MatchLineup(
            home: [
              ..._lineup(_eleven('h')),
              const LineupEntry(playerId: 'hsub', playerName: 'Wellington Dias', starter: false, number: 17),
            ],
            away: _lineup(_eleven('a')),
          ),
        );
    MatchDTO seven() => _match(home: _lineup(_seven('h')), away: _lineup(_seven('a'))).copyWith(
          goals: const [MatchGoal(id: 'g1', side: MatchSide.away, scorerId: 'aa1')],
          bookings: const [MatchBooking(id: 'c1', side: MatchSide.home, type: BookingType.yellow, playerId: 'hcb2')],
        );

    final positions = {
      for (final (id, _, position, _) in [..._eleven('h'), ..._eleven('a'), ..._seven('h'), ..._seven('a')]) id: position,
    };
    // Formação da súmula nos dois lados, com as vagas sugeridas pela posição.
    MatchDTO formed(MatchDTO match, String home, String away) => match.copyWith(
          formations: {MatchSide.home: home, MatchSide.away: away},
          lineup: MatchLineup(
            home: Formation.parse(home)!.suggestSlots(match.lineup.home, positions),
            away: Formation.parse(away)!.suggestSlots(match.lineup.away, positions),
          ),
        );
    final cases = [
      ('11x11', eleven(), _squad(_eleven('h'), 'tA'), _squad(_eleven('a'), 'tB'), TeamColor.red, TeamColor.white),
      ('7x7', seven(), _squad(_seven('h'), 'tA'), _squad(_seven('a'), 'tB'), TeamColor.navy, TeamColor.yellow),
      (
        '433x4231',
        formed(eleven(), '4-3-3', '4-2-3-1'),
        _squad(_eleven('h'), 'tA'),
        _squad(_eleven('a'), 'tB'),
        TeamColor.red,
        TeamColor.white
      ),
      (
        '352x442',
        formed(eleven(), '3-5-2', '4-4-2'),
        _squad(_eleven('h'), 'tA'),
        _squad(_eleven('a'), 'tB'),
        TeamColor.green,
        TeamColor.black
      ),
      ('7x7_321', formed(seven(), '3-2-1', '2-3-1'), _squad(_seven('h'), 'tA'), _squad(_seven('a'), 'tB'),
          TeamColor.navy, TeamColor.yellow),
    ];
    for (final (name, match, home, away, homeColor, awayColor) in cases) {
      for (final size in const [Size(360, 780), Size(412, 915)]) {
        // Altura de sobra: a prévia mostra o card inteiro (a largura é a do aparelho).
        tester.view.physicalSize = Size(size.width, 1100);
        tester.view.devicePixelRatio = 1;
        final boundary = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MatchLineupPitchCard(
                  match: match,
                  homeSquad: home,
                  awaySquad: away,
                  homeColor: homeColor.color,
                  awayColor: awayColor.color,
                  onPlayerTap: (_, __) {},
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final png = await tester.runAsync(() async {
          final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: 2);
          return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        });
        File('build/match_pitch_previews/${name}_${size.width.toInt()}.png').writeAsBytesSync(png!);
      }
    }

    // Editor de vagas da súmula (aba Escalação).
    final full = Formation.parse('4-3-3')!.suggestSlots(_lineup(_eleven('h')), positions);
    final missing = Formation.parse('4-2-3-1')!
        .suggestSlots(_lineup(_eleven('h')).where((e) => e.playerId != 'hm2').toList(), positions);
    final editors = [('editor_433', '4-3-3', full), ('editor_4231_vaga', '4-2-3-1', missing)];
    for (final (name, code, lineup) in editors) {
      for (final width in const [360.0, 412.0]) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        final boundary = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ReportFormationSection(
                  side: MatchSide.home,
                  teamName: 'Alfa',
                  lineup: lineup,
                  formationCode: code,
                  squad: _squad(_eleven('h'), 'tA'),
                  color: TeamColor.red.color,
                  onFormation: (_) {},
                  onSlot: (_, __) {},
                  onSuggest: () {},
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final png = await tester.runAsync(() async {
          final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: 2);
          return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        });
        File('build/match_pitch_previews/${name}_${width.toInt()}.png').writeAsBytesSync(png!);
      }
    }
    tester.view.reset();
  }, skip: Platform.environment['MATCH_PITCH_PREVIEW'] != '1');
}

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}
