import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_my_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_hub_cubit.dart';
import 'package:arena_soccer/features/predictions/presentation/page/prediction_ranking_page.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

// Prévia em PNG fora do CI: HUB_PREVIEW=1 flutter test test/features/predictions/prediction_hub_test.dart
// → build/hub_previews/<aba>.png

// 15/11/2026 13:00 em Brasília.
final _now = DateTime.utc(2026, 11, 15, 16);

const _ranking = [
  PredictionRankingEntry(uid: 'a', name: 'Ana Souza', points: 42, exact: 3, count: 6),
  PredictionRankingEntry(uid: 'b', name: 'Bruno Lima', points: 30, exact: 2, count: 5),
  PredictionRankingEntry(uid: 'c', name: 'Carla Dias', points: 27, exact: 1, count: 6),
  PredictionRankingEntry(uid: 'u1', name: 'Kaio', points: 22, exact: 1, count: 4),
  PredictionRankingEntry(uid: 'd', name: 'Dudu Rocha', points: 15, exact: 0, count: 4),
];

final _matches = [
  const MatchDTO(
      id: 'm1',
      homeTeam: 'Lava Jato',
      awayTeam: 'Volta',
      homeTeamId: 't1',
      awayTeamId: 't2',
      date: '15/11',
      time: '15:30'),
  const MatchDTO(id: 'm2', homeTeam: 'Açaí', awayTeam: 'Gralha', date: '16/11', time: '09:00'),
  const MatchDTO(id: 'm3', homeTeam: 'Floresta', awayTeam: 'Riacho', date: '22/11', time: '16:00'),
  const MatchDTO(
    id: 'f1',
    homeTeam: 'Lava Jato',
    awayTeam: 'Açaí',
    homeTeamId: 't1',
    date: '08/11',
    time: '15:00',
    homeGoals: 2,
    awayGoals: 1,
    manualStatus: MatchManualStatus.finished,
  ),
  const MatchDTO(
    id: 'f2',
    homeTeam: 'Volta',
    awayTeam: 'Gralha',
    date: '01/11',
    time: '15:00',
    homeGoals: 0,
    awayGoals: 0,
    manualStatus: MatchManualStatus.finished,
  ),
];

class _Ranking implements GetPredictionRankingUseCase {
  @override
  Future<Either<Failure, ({List<PredictionRankingEntry> top, PredictionRankingEntry? mine, int? myPosition})>> call({
    required String regionId,
    String uid = '',
    String? season,
  }) async =>
      Right((top: _ranking, mine: uid.isEmpty ? null : _ranking[3], myPosition: uid.isEmpty ? null : 4));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Matches implements GetRegionMatchesUseCase {
  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season}) async => Right(_matches);
}

class _Mine implements GetMyPredictionsUseCase {
  final asked = <List<String>>[];

  @override
  Future<Either<Failure, Map<String, PredictionDTO>>> call({
    required List<String> matchIds,
    required String uid,
    String? season,
  }) async {
    asked.add(matchIds);
    if (uid.isEmpty) return const Right({});
    const all = {
      'm1': PredictionDTO(uid: 'u1', home: 2, away: 1),
      'f1': PredictionDTO(uid: 'u1', home: 2, away: 1, points: 10, exact: true, valid: true),
    };
    return Right({
      for (final id in matchIds)
        if (all.containsKey(id)) id: all[id]!
    });
  }
}

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(Right([
        TeamDTO(id: 't1', name: 'Lava Jato', primaryColor: TeamColor.navy.hex),
        TeamDTO(id: 't2', name: 'Volta', primaryColor: TeamColor.red.hex),
      ]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session({bool guest = false})
      : super(guest
            ? const GuestSessionState()
            : const AuthenticatedSessionState(user: UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta'], selectedRegion: 'Floresta'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  setUpAll(() => RegionRegistry.configure(const [RegionRef(id: 'r1', name: 'Floresta')]));
  tearDownAll(RegionRegistry.reset);

  group('PredictionHub', () {
    test('início pela data/horário de Brasília e "fecha em"', () {
      final kickoff = PredictionHub.kickoffOf(_matches.first, _now)!;
      expect(kickoff, DateTime.utc(2026, 11, 15, 18, 30));
      expect(PredictionHub.closesIn(kickoff, _now), '2h 30min');
      expect(PredictionHub.closesIn(kickoff, _now.add(const Duration(days: 1))), '');
      // Janeiro visto em dezembro é do ano que vem.
      expect(
        PredictionHub.kickoffOf(
                const MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '03/01', time: '10:00'), DateTime.utc(2026, 12, 20))!
            .year,
        2027,
      );
    });

    test('quem a conta persegue, líder e aproveitamento', () {
      expect(PredictionHub.chase(_ranking, _ranking[3]), (name: 'Carla Dias', gap: 6));
      expect(PredictionHub.chase(_ranking, _ranking[0]), isNull);
      expect(PredictionHub.leads(_ranking, _ranking[0]), isTrue);
      expect(PredictionHub.leads(_ranking, _ranking[3]), isFalse);
      expect(PredictionHub.hitRate(_ranking[0]), 0.7);
    });
  });

  test('cubit: próximos por horário, últimos só com palpite', () async {
    final mine = _Mine();
    final cubit = PredictionHubCubit(_Ranking(), _Matches(), mine, _Teams(), () => _now);
    await cubit.load(region: 'Floresta', uid: 'u1');
    expect(cubit.state.upcoming.map((m) => m.id), ['m1', 'm2', 'm3']);
    expect(cubit.state.recent.map((m) => m.id), ['f1']);
    expect(cubit.state.predictions.keys, containsAll(['m1', 'f1']));
    expect(mine.asked.single, ['m1', 'm2', 'm3', 'f1', 'f2']);
    await cubit.close();
  });

  test('fase na aba Palpitar: aberto, ao vivo, intervalo, aguardando; terminado sai', () {
    HubMatchPhase? phase({bool upcoming = false, bool live = false, bool halfTime = false, bool waiting = false}) =>
        PredictionHub.phaseOf(upcoming: upcoming, live: live, halfTime: halfTime, waiting: waiting);
    expect(phase(upcoming: true), HubMatchPhase.open);
    expect(phase(live: true), HubMatchPhase.live);
    expect(phase(live: true, halfTime: true), HubMatchPhase.halfTime);
    expect(phase(waiting: true), HubMatchPhase.waiting);
    expect(phase(), isNull);
  });

  test('cubit: o jogo começado segue na lista até terminar', () async {
    // 15/11 15:45 em Brasília: m1 (15:30) em andamento pelo horário.
    final live = DateTime.utc(2026, 11, 15, 18, 45);
    final cubit = PredictionHubCubit(_Ranking(), _Matches(), _Mine(), _Teams(), () => live);
    await cubit.load(region: 'Floresta', uid: 'u1');
    expect(cubit.state.upcoming.map((m) => m.id), ['m1', 'm2', 'm3']);
    expect(hubPhaseOf(_matches.first, live), HubMatchPhase.live);
    // Encerrada pelo admin: sai.
    expect(
      hubPhaseOf(
          MatchDTO(
              id: 'x',
              homeTeam: 'A',
              awayTeam: 'B',
              date: '15/11',
              time: '15:30',
              manualStatus: MatchManualStatus.finished),
          live),
      isNull,
    );
    await cubit.close();
  });

  testWidgets('destaque travado: ao vivo com placar, palpite sem "Alterar", sem palpite = encerrados', (tester) async {
    var taps = 0;
    Future<void> show(PredictionDTO? prediction) => tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: HubFeaturedMatch(
              match: const MatchDTO(
                  id: 'm1',
                  homeTeam: 'Lava Jato',
                  awayTeam: 'Volta',
                  date: '15/11',
                  time: '15:30',
                  homeGoals: 1,
                  awayGoals: 0),
              teams: TeamDirectory(const []),
              prediction: prediction,
              now: DateTime.utc(2026, 11, 15, 18, 45),
              phase: HubMatchPhase.live,
              onPredict: () => taps++,
            ),
          ),
        ));
    await show(const PredictionDTO(uid: 'u1', home: 2, away: 1));
    expect(find.text('AO VIVO'), findsOneWidget);
    expect(find.text('1 × 0'), findsOneWidget);
    expect(find.text('2 × 1'), findsOneWidget);
    expect(find.text('Alterar'), findsNothing);
    expect(find.text('PALPITAR'), findsNothing);
    await tester.tap(find.text('AO VIVO'));
    expect(taps, 1);
    await show(null);
    expect(find.byKey(const ValueKey('hub-predictions-closed')), findsOneWidget);
    expect(find.text('PALPITAR'), findsNothing);
  });

  Future<void> pump(WidgetTester tester, {bool guest = false, Key? boundary, Size size = const Size(400, 1300)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(create: (_) => _Session(guest: guest)),
        BlocProvider<RegionCubit>(create: (_) => _Region()),
        BlocProvider<PredictionHubCubit>(
          create: (_) => PredictionHubCubit(_Ranking(), _Matches(), _Mine(), _Teams(), () => _now),
        ),
      ],
      child: RepaintBoundary(
        key: boundary,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('pt'),
          home: PredictionHubPage(),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Palpitar: posição, quem persegue, jogo com e sem palpite, último palpite', (tester) async {
    await pump(tester);
    expect(find.text('4º'), findsOneWidget);
    expect(find.text('Faltam 6 pts para passar Carla Dias'), findsOneWidget);
    expect(find.text('Fecha em 2h 30min'), findsOneWidget);
    expect(find.text('2 × 1'), findsWidgets);
    expect(find.text('PALPITAR'), findsWidgets);
    expect(find.text('+10 Exato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ranking: pódio, a linha da conta, "Sua posição" e desafiar amigos', (tester) async {
    final shared = <String>[];
    final original = predictionHubShare;
    predictionHubShare = (text) async => shared.add(text);
    addTearDown(() => predictionHubShare = original);
    await pump(tester);
    await tester.tap(find.text('Ranking'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('Sua posição'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hub-challenge')));
    expect(shared.single, startsWith('Tô em 4º no bolão do Arena Football em Floresta!'));
  });

  testWidgets('convidado: chamada para entrar, sem "últimos palpites"', (tester) async {
    await pump(tester, guest: true);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('SEUS ÚLTIMOS PALPITES'), findsNothing);
  });

  testWidgets('prévias', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/hub_previews').createSync(recursive: true);
    Future<void> shot(String name, GlobalKey key) async {
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      });
      File('build/hub_previews/$name.png').writeAsBytesSync(png!);
    }

    final key = GlobalKey();
    await pump(tester, boundary: key, size: const Size(400, 1500));
    await shot('palpitar', key);
    await tester.tap(find.text('Ranking'));
    await tester.pumpAndSettle();
    await shot('ranking', key);
  }, skip: Platform.environment['HUB_PREVIEW'] != '1');
}
