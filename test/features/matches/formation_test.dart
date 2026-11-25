import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/formation.dart';
import 'package:arena_soccer/features/matches/domain/match_pitch.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delay_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_report_page.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_lineup_pitch.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// 11 com posição (4-4-2 no cadastro): id → posição.
const _positions = {
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

List<LineupEntry> _starters([Map<String, int> numbers = const {}]) => [
      for (final id in _positions.keys) LineupEntry(playerId: id, playerName: 'Atleta $id', number: numbers[id]),
    ];

Map<String, int?> _slots(List<LineupEntry> lineup) => {for (final e in lineup) e.playerId: e.slot};

class _Squads implements WatchTeamPlayersUseCase {
  final Map<String, List<PlayerDTO>> byTeam;

  _Squads(this.byTeam);

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

final _homeSquad = [
  for (final e in _positions.entries) PlayerDTO(id: e.key, name: 'Atleta ${e.key}', team: 'Alfa', position: e.value),
];

void main() {
  group('Formation', () {
    test('parse e as listas por tamanho', () {
      final f = Formation.parse('4-2-3-1')!;
      expect(f.code, '4-2-3-1');
      expect(f.lines, [4, 2, 3, 1]);
      expect(f.players, 11);
      for (final bad in ['', 'abc', '4-4-4', '0-4', '4--3', null]) {
        expect(Formation.parse(bad), isNull, reason: '$bad');
      }
      expect(Formation.forStarters(11).map((f) => f.code),
          ['4-4-2', '4-3-3', '3-5-2', '4-2-3-1', '3-4-3', '5-3-2', '4-5-1']);
      expect(Formation.forStarters(7).map((f) => f.code), ['3-2-1', '2-3-1', '3-1-2', '2-2-2']);
      expect(Formation.forStarters(5).map((f) => f.code), ['2-2', '1-2-1', '3-1']);
      expect(Formation.forStarters(8), isEmpty);
      for (final size in Formation.sizes) {
        expect(Formation.forStarters(size).every((f) => f.players == size), isTrue);
      }
    });

    test('vagas: fileiras e funções (laterais nas pontas, volantes na 1ª do meio)', () {
      final f = Formation.parse('4-2-3-1')!;
      expect(f.seatOf(0), (row: 0, index: 0, count: 1));
      expect(f.seatOf(4), (row: 1, index: 3, count: 4));
      expect(f.seatOf(10), (row: 4, index: 0, count: 1));
      expect(f.seatOf(11), isNull);
      expect([for (var s = 0; s < 11; s++) f.roleOf(s)], [
        SlotRole.goalkeeper,
        SlotRole.fullBack,
        SlotRole.centerBack,
        SlotRole.centerBack,
        SlotRole.fullBack,
        SlotRole.defensiveMid,
        SlotRole.defensiveMid,
        SlotRole.midfielder,
        SlotRole.midfielder,
        SlotRole.midfielder,
        SlotRole.forward,
      ]);
      // Defesa de 3: todos zagueiros.
      expect(Formation.parse('3-5-2')!.roleOf(1), SlotRole.centerBack);
    });

    test('sugestão pela posição: goleiro, laterais nas pontas, sobra na linha mais perto', () {
      final f = Formation.parse('4-3-3')!;
      final slots = _slots(f.suggestSlots(_starters(), _positions));
      expect(slots['gk'], 0);
      expect(slots['lb'], 1);
      expect(slots['rb'], 4);
      expect({slots['cb1'], slots['cb2']}, {2, 3});
      expect({slots['a1'], slots['a2']}.every((s) => s! >= 8), isTrue);
      // 4 do meio para 3 vagas: um meia sobe para o ataque.
      final attack = slots.entries.where((e) => e.value! >= 8).map((e) => e.key).toSet();
      expect(attack.length, 3);
      expect(attack.difference({'a1', 'a2'}).single, startsWith('m'));
      expect(slots['v1'], inInclusiveRange(5, 7));
      expect(slots.values.toSet().length, 11);
    });

    test('sugestão mantém quem já está numa vaga válida; reserva sem vaga', () {
      final f = Formation.parse('4-4-2')!;
      final lineup = [
        for (final e in _starters()) e.playerId == 'a1' ? e.copyWith(slot: () => 1) : e,
        const LineupEntry(playerId: 'r1', playerName: 'Reserva', starter: false, slot: 3),
      ];
      final slots = _slots(f.suggestSlots(lineup, _positions));
      expect(slots['a1'], 1);
      expect(slots['r1'], isNull);
      expect(slots['lb'], isNot(1));
      // Sem manter: a1 volta para o ataque.
      expect(_slots(f.suggestSlots(lineup, _positions, keep: false))['a1'], greaterThanOrEqualTo(9));
    });

    test('troca de vaga: troca os dois; vaga vazia só recebe', () {
      final lineup = [
        const LineupEntry(playerId: 'a', playerName: 'A', slot: 1),
        const LineupEntry(playerId: 'b', playerName: 'B', slot: 2),
        const LineupEntry(playerId: 'r', playerName: 'R', starter: false),
      ];
      expect(_slots(Formation.swapSlot(lineup, 'a', 2)), {'a': 2, 'b': 1, 'r': null});
      expect(_slots(Formation.swapSlot(lineup, 'a', 5)), {'a': 5, 'b': 2, 'r': null});
      // Reserva não vai para vaga.
      expect(Formation.swapSlot(lineup, 'r', 1), lineup);
      expect(Formation.parse('2-2')!.emptySlots(lineup), 3);
    });

    test('lugar da vaga: 4-2-3-1 com as fileiras igualmente espaçadas; visitante espelhado', () {
      final f = Formation.parse('4-2-3-1')!;
      final ys = [for (final slot in [1, 5, 7, 10]) f.slotPlace(slot, MatchSide.home).y];
      final gaps = [for (var i = 1; i < ys.length; i++) ys[i - 1] - ys[i]];
      expect(gaps.every((g) => g > 0), isTrue);
      expect(gaps[0], closeTo(gaps[1], 1e-9));
      expect(gaps[1], closeTo(gaps[2], 1e-9));
      expect(f.slotPlace(10, MatchSide.home).x, closeTo(0.5, 1e-9));
      expect(f.slotPlace(0, MatchSide.home).y, greaterThan(ys.first));
      final home = f.slotPlace(1, MatchSide.home);
      final away = f.slotPlace(1, MatchSide.away);
      expect(away.x, closeTo(1 - home.x, 1e-9));
      expect(away.y, closeTo(1 - home.y, 1e-9));
      // A defesa na mesma altura do layout automático.
      expect(home.y, closeTo(MatchPitch.place(PitchLine.defense, 0, 4, MatchSide.home).y, 1e-9));
    });
  });

  group('campinho com formação', () {
    MatchDTO match({Map<MatchSide, String> formations = const {MatchSide.home: '4-3-3'}}) {
      final f = Formation.parse('4-3-3')!;
      return MatchDTO(
        id: 'm1',
        homeTeam: 'Alfa',
        awayTeam: 'Beta',
        lineupConfirmed: true,
        formations: formations,
        lineup: MatchLineup(
          home: [
            ...f.suggestSlots(_starters(), _positions),
            const LineupEntry(playerId: 's1', playerName: 'Reserva', starter: false),
          ],
          away: const [LineupEntry(playerId: 'x', playerName: 'X')],
        ),
      );
    }

    test('cada um na vaga; quem entra herda a vaga; expulso deixa a vaga vazia', () {
      final f = Formation.parse('4-3-3')!;
      final base = match();
      final slots = _slots(base.lineup.home);
      final withEvents = base.copyWith(
        substitutions: const [
          MatchSubstitution(id: 's', side: MatchSide.home, outId: 'a1', outName: 'a1', inId: 's1', inName: 'Reserva'),
        ],
        bookings: const [MatchBooking(id: 'c', side: MatchSide.home, type: BookingType.red, playerId: 'cb1')],
      );
      final spots = MatchPitch.side(withEvents, MatchSide.home, _positions);
      expect(spots.length, 10);
      final sub = spots.firstWhere((s) => s.playerId == 's1');
      expect(sub.slot, slots['a1']);
      expect((sub.x, sub.y), (f.slotPlace(slots['a1']!, MatchSide.home).x, f.slotPlace(slots['a1']!, MatchSide.home).y));
      expect(spots.any((s) => s.slot == slots['cb1']), isFalse);
      expect(MatchPitch.rowsOf(spots), 4);
    });

    test('Livre (ou vagas incompletas): o layout automático de sempre', () {
      final free = MatchPitch.side(match(formations: const {}), MatchSide.home, _positions);
      final auto = MatchPitch.side(
        match(formations: const {}).copyWith(
          lineup: MatchLineup(home: _starters(), away: const [LineupEntry(playerId: 'x', playerName: 'X')]),
        ),
        MatchSide.home,
        _positions,
      );
      expect([for (final s in free) (s.playerId, s.x, s.y)], [for (final s in auto) (s.playerId, s.x, s.y)]);
      expect(free.every((s) => s.slot == null), isTrue);
      final incomplete = match().copyWith(
        lineup: MatchLineup(home: _starters(), away: const [LineupEntry(playerId: 'x', playerName: 'X')]),
      );
      expect(MatchPitch.side(incomplete, MatchSide.home, _positions).every((s) => s.slot == null), isTrue);
    });

    test('Firestore e cache: formacoes e vaga vão e voltam', () {
      final m = match();
      final map = m.toMap();
      expect(map[MatchDTO.formationsField], {'casa': '4-3-3'});
      expect((map[MatchDTO.lineupField] as Map)['casa'][0]['vaga'], 0);
      final cached = MatchDTO.fromCache(m.toCache());
      expect(cached.formations, {MatchSide.home: '4-3-3'});
      expect(cached.lineup, m.lineup);
      expect(MatchDTO.formationsOf({'casa': ' ', 'fora': '4-4-2'}), {MatchSide.away: '4-4-2'});
    });
  });

  group('súmula', () {
    MatchReportCubit cubit(_Save save) => MatchReportCubit(
        _Squads({'tA': _homeSquad}), save, _Phase(), _Voting(), _Create(), _Delay());

    MatchDTO base() => MatchDTO(
          id: 'm1',
          homeTeam: 'Alfa',
          awayTeam: 'Beta',
          homeTeamId: 'tA',
          awayTeamId: 'tB',
          lineup: MatchLineup(home: _starters({'a1': 9, 'a2': 11, 'lb': 6})),
        );

    test('formação sugere; titular novo ganha vaga livre; reserva libera; conta como mudança', () async {
      final c = cubit(_Save());
      addTearDown(c.close);
      await c.load(match: base());
      c.setFormation(MatchSide.home, Formation.parse('4-3-3'));
      expect(c.state.dirty, isTrue);
      expect(c.state.match!.formations, {MatchSide.home: '4-3-3'});
      final slots = _slots(c.state.match!.lineup.home);
      expect(slots.values.whereType<int>().toSet().length, 11);
      final freed = slots['m1']!;
      c.setRole(MatchSide.home, _homeSquad.firstWhere((p) => p.id == 'm1'), LineupRole.sub);
      expect(_slots(c.state.match!.lineup.home)['m1'], isNull);
      c.setRole(MatchSide.home, const PlayerDTO(id: 'n', name: 'Novo', team: 'Alfa', position: 'meia'),
          LineupRole.starter);
      expect(_slots(c.state.match!.lineup.home)['n'], freed);
      // Livre: sem vagas.
      c.setFormation(MatchSide.home, null);
      expect(c.state.match!.formations, isEmpty);
      expect(c.state.match!.lineup.home.every((e) => e.slot == null), isTrue);
    });

    test('trocar de formação mantém quem está numa vaga da mesma função', () async {
      final c = cubit(_Save());
      addTearDown(c.close);
      await c.load(match: base());
      c.setFormation(MatchSide.home, Formation.parse('4-4-2'));
      final before = _slots(c.state.match!.lineup.home);
      c.setFormation(MatchSide.home, Formation.parse('4-3-3'));
      final after = _slots(c.state.match!.lineup.home);
      for (final id in ['gk', 'lb', 'cb1', 'cb2', 'rb']) {
        expect(after[id], before[id], reason: id);
      }
      expect(after.values.whereType<int>().toSet().length, 11);
    });

    testWidgets('escolhe 4-3-3, troca dois de vaga e o "Salvar" grava formacoes e vaga', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final save = _Save();
      final c = cubit(save);
      await c.load(match: base());
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider.value(value: c, child: const MatchReportPage()),
      ));
      await tester.pump();
      await tester.tap(find.text('Escalação'));
      await tester.pumpAndSettle();
      final pill = find.byKey(const ValueKey('report-formation-pill'));
      await tester.scrollUntilVisible(pill, 200, scrollable: find.byType(Scrollable).last);
      await tester.pumpAndSettle();
      expect(find.descendant(of: pill, matching: find.text('Livre')), findsOneWidget);
      await tester.tap(pill);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('formation-option-4-3-3')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: pill, matching: find.text('4-3-3')), findsOneWidget);

      // Vaga 1 (lateral esquerdo) recebe o camisa 9: o lateral vai para a vaga dele.
      final a1Before = _slots(c.state.match!.lineup.home)['a1']!;
      final slot1 = find.byKey(const ValueKey('slot-1'));
      await tester.ensureVisible(slot1);
      await tester.pumpAndSettle();
      expect(find.descendant(of: slot1, matching: find.text('LAT')), findsOneWidget);
      expect(find.descendant(of: slot1, matching: find.text('6')), findsOneWidget);
      await tester.tap(slot1);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('slot-player-a1')));
      await tester.pumpAndSettle();
      expect(find.descendant(of: slot1, matching: find.text('9')), findsOneWidget);
      expect(_slots(c.state.match!.lineup.home)['lb'], a1Before);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      final edited = save.edited!;
      expect(edited.formations, {MatchSide.home: '4-3-3'});
      expect(_slots(edited.lineup.home)['a1'], 1);
      final written = edited.toMap();
      expect(written[MatchDTO.formationsField], {'casa': '4-3-3'});
      expect(((written[MatchDTO.lineupField] as Map)['casa'] as List).every((e) => (e as Map).containsKey('vaga')),
          isTrue);
      expect(tester.takeException(), isNull);
      await c.close();
    });
  });

  testWidgets('detalhe: os jogadores ficam nas vagas da formação', (tester) async {
    tester.view.physicalSize = const Size(412, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final f = Formation.parse('4-3-3')!;
    // O admin pôs um zagueiro no centro do ataque (vaga 9).
    final lineup = Formation.swapSlot(f.suggestSlots(_starters(), _positions), 'cb1', 9);
    final match = MatchDTO(
      id: 'm1',
      homeTeam: 'Alfa',
      awayTeam: 'Beta',
      lineupConfirmed: true,
      formations: const {MatchSide.home: '4-3-3', MatchSide.away: '4-2-3-1'},
      lineup: MatchLineup(home: lineup, away: Formation.parse('4-2-3-1')!.suggestSlots(_starters(), _positions)),
    );
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: MatchLineupPitchCard(
            match: match,
            homeSquad: _homeSquad,
            awaySquad: _homeSquad,
            onPlayerTap: (_, __) {},
          ),
        ),
      ),
    ));
    expect(find.text('4-3-3'), findsOneWidget);
    expect(find.text('4-2-3-1'), findsOneWidget);
    Offset at(String side, String id) => tester.getCenter(find.byKey(ValueKey('pitch-$side-$id')));
    final cardCenter = tester.getCenter(find.byType(MatchLineupPitchCard)).dx;
    // O zagueiro no centro do ataque: no meio e acima dos meias.
    expect(at('casa', 'cb1').dx, closeTo(cardCenter, 1));
    final mids = [for (final id in ['v1', 'm1', 'm2', 'm3']) at('casa', id).dy];
    expect(mids.where((y) => y > at('casa', 'cb1').dy).length, greaterThanOrEqualTo(3));
    // Visitante 4-2-3-1: o centroavante sozinho, no meio.
    final strikers = MatchPitch.side(match, MatchSide.away, _positions).where((s) => s.slot == 10);
    expect(at('fora', strikers.single.playerId).dx, closeTo(cardCenter, 1));
    expect(tester.takeException(), isNull);
  });
}
