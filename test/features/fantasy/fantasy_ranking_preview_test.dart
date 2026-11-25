import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_ranking_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_ranking_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

import 'fantasy_no_cache.dart';

// Prévia em PNG fora do CI: FANTASY_RANKING_PREVIEW=1 flutter test test/features/fantasy/fantasy_ranking_preview_test.dart
// → build/fantasy_ranking_previews/<aba>_<largura>x<altura>.png
//
// O app não tem tema escuro (AppColors são constantes), então só o claro.
// Fotos de rede não carregam no teste: os participantes vão sem foto (iniciais).

const _copa =
    ChampionshipDTO(id: 'doc1', championshipId: 8, title: 'Copa Verde de Floresta', region: 'Floresta', season: '2026');

FantasyRankingEntry _e(String uid, String name, double points) =>
    FantasyRankingEntry(uid: uid, name: name, points: points);

// Rodada 5 (parcial): a conta (u1, Kaio) em 5º.
final _round5 = [
  _e('a', 'Ana Beatriz Fernandes', 64.5),
  _e('b', 'Bruno Costa', 58),
  _e('c', 'Carla Mendes', 52.5),
  _e('d', 'Diego Santos', 47),
  _e('u1', 'Kaio Lima', 41.5),
  _e('f', 'Fernanda Oliveira Rocha', 38),
  _e('g', 'Gustavo', 21.5),
  _e('h', 'Heitor Almeida', 9),
];

final _overall = [
  _e('a', 'Ana Beatriz Fernandes', 312.5),
  _e('b', 'Bruno Costa', 298),
  _e('c', 'Carla Mendes', 287),
  _e('u1', 'Kaio Lima', 254.5),
  _e('d', 'Diego Santos', 241),
  _e('f', 'Fernanda Oliveira Rocha', 199.5),
  _e('g', 'Gustavo', 160),
  _e('h', 'Heitor Almeida', 98),
];

FantasyAthleteScoreDTO _a(String id, String name, String team, double total, String pos) =>
    FantasyAthleteScoreDTO.fromMap(id, {'nome': name, 'time': team, 'total': total, 'posicao': pos});

final _top5 = [
  _a('fw1', 'Ângelo Atacante', 'Tigres', 24.5, 'ata'),
  _a('mf1', 'Mateus Ribeiro', 'Leões do Norte', 19, 'mei'),
  _a('gk1', 'Rafael Goleiro', 'Riacho', 17.5, 'gol'),
  _a('cb1', 'Caio Zagueiro', 'Tigres', 15, 'zag'),
  _a('fw2', 'Lucas Henrique da Silva', 'Açaí no Gralle', 15, 'ata'),
  _a('mf2', 'Davi Volante', 'Volta', 12.5, 'mei'),
  _a('cb2', 'Pedro Paulo', 'Bairro', 11, 'zag'),
  _a('fw3', 'Thiago Neves', 'Unidos', 9.5, 'ata'),
  _a('gk2', 'Marcos Goleiro', 'Lava Jato', 8, 'gol'),
  _a('mf3', 'João Victor', 'Estrela', 6, 'mei'),
];

const _athletes = [
  FantasyAthleteDTO(id: 'gk1', name: 'Rafael Goleiro', position: 'goleiro', teamId: 't3', team: 'Riacho'),
  FantasyAthleteDTO(id: 'cb1', name: 'Caio Zagueiro', position: 'zagueiro', teamId: 't1', team: 'Tigres'),
  FantasyAthleteDTO(id: 'mf1', name: 'Mateus Ribeiro', position: 'meia', teamId: 't2', team: 'Leões do Norte'),
  FantasyAthleteDTO(id: 'fw1', name: 'Ângelo Atacante', position: 'atacante', teamId: 't1', team: 'Tigres'),
  FantasyAthleteDTO(id: 'mf2', name: 'Davi Volante', position: 'meia', teamId: 't4', team: 'Volta'),
  FantasyAthleteDTO(id: 'fw2', name: 'Lucas Henrique da Silva', position: 'atacante', teamId: 't5', team: 'Açaí'),
  FantasyAthleteDTO(id: 'cb2', name: 'Pedro Paulo', position: 'zagueiro', teamId: 't6', team: 'Bairro'),
];

final _lineups = <int, FantasyLineupDTO>{
  // Rodada 6: escalou, ainda sem apuração.
  6: FantasyLineupDTO.fromMap('u1', {
    'atletas': {'gol': 'gk1', 'zag': 'cb2', 'mei': 'mf2', 'ata': 'fw2', 'livre': 'mf1'},
    'capitao': 'mf1',
  }),
  5: FantasyLineupDTO.fromMap('u1', {
    'atletas': {'gol': 'gk1', 'zag': 'cb1', 'mei': 'mf1', 'ata': 'fw1', 'livre': 'mf2'},
    'capitao': 'fw1',
    'pontos': 41.5,
    'pontosAtletas': {'gk1': 5, 'cb1': -2, 'mf1': 6, 'fw1': 30, 'mf2': 2.5},
  }),
  4: FantasyLineupDTO.fromMap('u1', {
    'atletas': {'gol': 'gk1', 'zag': 'cb1', 'mei': 'mf1', 'ata': 'fw2', 'livre': 'cb2'},
    'capitao': 'mf1',
    'pontos': 57,
    'pontosAtletas': {'gk1': 12, 'cb1': 8, 'mf1': 21, 'fw2': 11, 'cb2': 5},
  }),
};

class _Repo with FantasyNoCache implements IFantasyRepository {
  final rounds = [
    FantasyRoundDTO.fromMap('3', {'status': 'fechada', 'apuracao': {}, 'finalizada': true}),
    FantasyRoundDTO.fromMap('4', {'status': 'fechada', 'apuracao': {}, 'finalizada': true}),
    FantasyRoundDTO.fromMap('5', {'status': 'fechada', 'apuracao': {}}),
    FantasyRoundDTO.fromMap('6', {'status': 'fechada'}),
    FantasyRoundDTO.fromMap('7', {'status': 'aberta'}),
  ];

  @override
  Future<Either<Failure, List<FantasyAthleteScoreDTO>>> getTopAthletes(String fantasyId, int round) async =>
      Right(round == 5 ? _top5 : const []);

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteScoreDTO>>?>> getCachedTopAthletes(
          String fantasyId, int round) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveTopAthletesCache(
          String fantasyId, int round, List<FantasyAthleteScoreDTO> list) async =>
      const Right(null);

  @override
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) => Stream.value(Right(
        FantasyConfigDTO.fromMap(
            'doc1',
            {
              'ativo': true,
              'campeao': [
                {'uid': 'a', 'nome': 'Ana Beatriz Fernandes', 'pontos': 312.5},
              ],
            },
            championship: championship),
      ));

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) async => Right(rounds);

  @override
  Future<Either<Failure, CachedValue<List<FantasyRankingEntry>>?>> getCachedRanking(
          String fantasyId, int? round) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveRankingCache(String fantasyId, int? round, List<FantasyRankingEntry> e) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getRoundRanking(String fantasyId, int round) async =>
      Right(switch (round) {
        5 => _round5,
        4 => [for (final e in _round5) _e(e.uid, e.name, e.points + 10)],
        _ => const [],
      });

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getOverallRanking(String fantasyId) async => Right(_overall);

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) async =>
      Right(round == 4 ? 2 : 4);

  @override
  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid) async =>
      Right(_lineups[round]);

  @override
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) =>
      Stream.value(const Right(FantasyParticipantDTO(uid: 'u1', points: 254.5)));

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) async =>
      const Right(_athletes);

  @override
  Future<Either<Failure, void>> saveAthletesCache(FantasyConfigDTO config, List<FantasyAthleteDTO> athletes) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session() : super(const SessionState(user: UserDTO(id: 'u1', name: 'Kaio Lima', email: 'k@x.com', isAdmin: false)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FantasyRankingCubit _cubit(_Repo repo) => FantasyRankingCubit(
      WatchFantasyConfigUseCase(repo),
      GetFantasyRankingCacheFirstUseCase(repo),
      GetFantasyPositionCacheFirstUseCase(repo),
      GetFantasyRoundsCacheFirstUseCase(repo),
      GetFantasyRoundRecordUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      topAthletes: GetFantasyTopAthletesCacheFirstUseCase(repo),
    );

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  for (final size in const [Size(360, 780), Size(412, 915)]) {
    testWidgets('prévias ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await tester.runAsync(() async {
        await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
        await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
        await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
        final root = Platform.environment['FLUTTER_ROOT'] ?? '';
        await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
      });
      const dir = 'build/fantasy_ranking_previews';
      Directory(dir).createSync(recursive: true);

      {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final boundary = GlobalKey();
        final cubit = _cubit(_Repo());
        addTearDown(cubit.close);
        await tester.pumpWidget(KeyedSubtree(
          key: ValueKey(size),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: _Session()),
              BlocProvider<FantasyRankingCubit>.value(value: cubit),
            ],
            child: RepaintBoundary(
              key: boundary,
              child: const MaterialApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale('pt'),
                home: FantasyRankingPage(championship: _copa),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        // Rodada 5 = a parcial (a 6 ainda aguarda apuração).
        await tester.tap(find.byKey(const ValueKey('fantasy-round-older')));
        await tester.pumpAndSettle();

        Future<void> shot(String tab) async {
          final png = await tester.runAsync(() async {
            final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await render.toImage(pixelRatio: 2);
            return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
          });
          File('$dir/${tab}_${size.width.toInt()}x${size.height.toInt()}.png').writeAsBytesSync(png!);
        }

        await shot('rodada');
        // Fim da lista: a última linha fica acima do "Sua posição" flutuante.
        await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
        await tester.pumpAndSettle();
        await shot('rodada_fim');
        for (final (label, name) in const [('Atletas', 'atletas'), ('Geral', 'geral'), ('Histórico', 'historico')]) {
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          await shot(name);
        }
        expect(tester.takeException(), isNull);
      }
    }, skip: Platform.environment['FANTASY_RANKING_PREVIEW'] != '1');
  }
}
