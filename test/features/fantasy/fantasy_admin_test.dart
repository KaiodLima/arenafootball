import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_admin_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_admin_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_admin_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _copa = ChampionshipDTO(id: 'doc1', championshipId: 8, title: 'Copa Verde', region: 'Floresta', season: '2026');

final _rounds = [
  FantasyRoundDTO.fromMap('3', {
    'status': 'aberta',
    'fechaEm': DateTime(2026, 11, 29, 18),
    'idsPartidas': ['m5']
  }),
  FantasyRoundDTO.fromMap('2', {
    'status': 'fechada',
    'idsPartidas': ['m3', 'm4'],
    'apuracao': {'encerradas': 1, 'escalacoes': 12, 'processadoEm': DateTime(2026, 11, 22, 21, 40)},
    'parametros': {'minMinutos': 20, 'minMinutosDefesa': 45, 'capitao': 1.5},
  }),
  FantasyRoundDTO.fromMap('1', {
    'status': 'fechada',
    'idsPartidas': ['m1'],
    'apuracao': {'encerradas': 1, 'escalacoes': 10},
    'finalizada': true,
  }),
];

class _Repo implements IFantasyRepository {
  final rounds = StreamController<Either<Failure, List<FantasyRoundDTO>>>.broadcast();
  final pages = <DateTime?>[];
  var rescores = 0;
  var resets = 0;

  @override
  Future<Either<Failure, void>> requestReset(String fantasyId) async {
    resets++;
    return const Right(null);
  }

  List<FantasyParticipantDTO> _page(int start, int count) => [
        for (var i = start; i < start + count; i++)
          FantasyParticipantDTO(
            uid: 'u$i',
            name: 'Torcedor $i',
            firstRound: 2,
            points: 10.0 + i,
            joinedAt: DateTime(2026, 11, 1).subtract(Duration(minutes: i)),
          ),
      ];

  @override
  Stream<Either<Failure, List<FantasyRoundDTO>>> watchRounds(String fantasyId) => rounds.stream;

  @override
  Future<Either<Failure, List<FantasyParticipantDTO>>> getParticipants(String fantasyId, {DateTime? before}) async {
    pages.add(before);
    return Right(before == null ? _page(0, 30) : _page(30, 5));
  }

  @override
  Future<Either<Failure, void>> requestRescore(String fantasyId) async {
    rescores++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid) async =>
      Right(round == 1
          ? FantasyLineupDTO.fromMap(uid, {
              'atletas': {'gol': 'gk', 'zag': 'cb', 'mei': 'mf', 'ata': 'fw', 'livre': 'dm'},
              'capitao': 'fw',
              'pontos': 33,
              'pontosAtletas': {'fw': 15},
            })
          : null);

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) async => const Right(2);

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) async => const Right([
        FantasyAthleteDTO(id: 'fw', name: 'Ângelo Atacante', position: 'atacante', teamId: 't1'),
      ]);

  @override
  Future<Either<Failure, void>> saveAthletesCache(FantasyConfigDTO config, List<FantasyAthleteDTO> athletes) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FantasyAdminCubit _cubit(_Repo repo) => FantasyAdminCubit(
      WatchFantasyRoundsUseCase(repo),
      GetFantasyParticipantsUseCase(repo),
      RequestFantasyRescoreUseCase(repo),
      GetFantasyLineupUseCase(repo),
      GetFantasyPositionUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      reset: RequestFantasyResetUseCase(repo),
    );

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('rodada com a apuração e os parâmetros congelados', () {
    final round = _rounds[1];
    expect((round.matchesFinished, round.lineups, round.processedAt), (1, 12, DateTime(2026, 11, 22, 21, 40)));
    expect(round.params, (minMinutes: 20, minDefenseMinutes: 45, captain: 1.5));
    expect(_rounds[0].params, isNull);
  });

  test('cubit: participantes em páginas de 30, histórico do participante e a reapuração', () async {
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    cubit.load(_copa);
    repo.rounds.add(Right(_rounds));
    await _settle();
    expect(cubit.state.participants.length, 30);
    expect(cubit.state.hasMore, isTrue);
    await cubit.loadMore();
    expect(repo.pages.last, DateTime(2026, 11, 1).subtract(const Duration(minutes: 29)));
    expect(cubit.state.participants.length, 35);
    expect(cubit.state.hasMore, isFalse);

    await cubit.openParticipant('u3');
    expect(cubit.state.history.map((h) => (h.round.number, h.position)), [(1, 3)]);
    cubit.closeParticipant();
    expect(cubit.state.openUid, isNull);

    await cubit.rescore();
    expect(repo.rescores, 1);
    expect(cubit.state.rescore, FantasyRescoreResult.requested);
  });

  testWidgets('tela: cartões das rodadas, reapurar com confirmação e a folha do participante', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider.value(value: cubit, child: const FantasyAdminPage(championship: _copa)),
    ));
    repo.rounds.add(Right(_rounds));
    await tester.pumpAndSettle();
    expect(find.text('ABERTA'), findsOneWidget);
    expect(find.text('FECHADA'), findsNWidgets(2));
    expect(find.text('FINALIZADA'), findsOneWidget);
    expect(find.text('Partidas terminadas: 1 de 2'), findsOneWidget);
    expect(find.text('12 escalações apuradas'), findsOneWidget);
    expect(find.text('Parâmetros: 20 min · 45 min · 1,5×'), findsOneWidget);
    expect(find.text('Ainda não apurada'), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('fantasy-rescore')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fantasy-rescore-confirm')));
    await tester.pumpAndSettle();
    expect(repo.rescores, 1);

    await tester.tap(find.text('Participantes'));
    await tester.pumpAndSettle();
    expect(find.text('Desde a rodada 2'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('fantasy-participant-u0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-history-1')), findsOneWidget);
    expect(find.text('Ângelo Atacante'), findsOneWidget);
  });

  testWidgets('zerar pontuações: menu, duas confirmações e só então o pedido; cancelar não pede', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider.value(value: cubit, child: const FantasyAdminPage(championship: _copa)),
    ));
    repo.rounds.add(Right(_rounds));
    await tester.pumpAndSettle();

    Future<void> openMenu() async {
      await tester.tap(find.byKey(const ValueKey('fantasy-admin-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fantasy-reset')));
      await tester.pumpAndSettle();
    }

    // Cancelar na 2ª confirmação: nada é pedido.
    await openMenu();
    expect(find.text('Zerar as pontuações deste Fantasy?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-reset-confirm-1')));
    await tester.pumpAndSettle();
    expect(find.text('Tem certeza?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.resets, 0);

    await openMenu();
    await tester.tap(find.byKey(const ValueKey('fantasy-reset-confirm-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fantasy-reset-confirm-2')));
    await tester.pumpAndSettle();
    expect(repo.resets, 1);
    expect(find.text('Pedido enviado: as pontuações serão zeradas em instantes.'), findsOneWidget);
  });
}
