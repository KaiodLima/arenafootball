import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_settings_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_rules_page.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_settings_page.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
import 'package:arena_soccer/features/scoring/domain/repositories/scoring_repository_interface.dart';
import 'package:arena_soccer/features/scoring/domain/usecases/scoring_usecases.dart';
import 'package:arena_soccer/features/scoring/presentation/bloc/scoring_config_cubit.dart';
import 'package:arena_soccer/features/scoring/presentation/bloc/scoring_settings_cubit.dart';
import 'package:arena_soccer/features/scoring/presentation/page/scoring_settings_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _ScoringRepo implements IScoringRepository {
  FantasyScoringTable table;
  PredictionRules rules;
  final savedTables = <FantasyScoringTable>[];
  final savedRules = <PredictionRules>[];

  _ScoringRepo({this.table = FantasyScoringTable.defaults, this.rules = PredictionRules.defaults});

  @override
  Stream<Either<Failure, FantasyScoringTable>> watchFantasyTable() => Stream.value(Right(table));

  @override
  Stream<Either<Failure, PredictionRules>> watchPredictionRules() => Stream.value(Right(rules));

  @override
  Future<Either<Failure, void>> saveFantasyTable(FantasyScoringTable table) async {
    savedTables.add(table);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> savePredictionRules(PredictionRules rules) async {
    savedRules.add(rules);
    return const Right(null);
  }
}

class _FantasyRepo implements IFantasyRepository {
  final controller = StreamController<Either<Failure, FantasyConfigDTO>>.broadcast();
  final saved = <FantasyConfigDTO>[];

  @override
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) => controller.stream;

  @override
  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config) async {
    saved.add(config);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _copa = ChampionshipDTO(id: 'doc1', championshipId: 7, title: 'Copa Verde', region: 'Floresta', season: '2026');

Widget _app(Widget home, {ScoringConfigCubit? config}) {
  final app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: home,
  );
  return config == null ? app : BlocProvider.value(value: config, child: app);
}

ScoringSettingsCubit _settings(_ScoringRepo repo) => ScoringSettingsCubit(
      WatchFantasyScoringTableUseCase(repo),
      WatchPredictionRulesUseCase(repo),
      SaveFantasyScoringTableUseCase(repo),
      SavePredictionRulesUseCase(repo),
    );

void main() {
  group('FantasyScoringTable', () {
    test('lê o doc, inválido = padrão, e volta igual pelo toMap', () {
      final table = FantasyScoringTable.fromMap({
        'base': 12,
        'gol': 0.3,
        'empate': 1,
        'golsSofridos': {'gol': -4, 'zag': 'x'},
        'golEquipe': {'ata': 1.5},
      });
      expect(table.base, 12);
      expect(table.goal, 5, reason: '0,3 não é passo de 0,5');
      expect(table.draw, 1);
      expect(table.conceded[FantasySlot.goalkeeper], -4);
      expect(table.conceded[FantasySlot.defender], -2);
      expect(table.teamGoal[FantasySlot.forward], 1.5);
      expect(FantasyScoringTable.fromMap(table.toMap()), table);
      expect(FantasyScoringTable.fromMap(null), FantasyScoringTable.defaults);
    });

    test('editar: passos de 0,5 presos à faixa', () {
      var table = FantasyScoringTable.defaults.withValue(FantasyScoreRule.base, 25);
      expect(table.base, 20);
      table = table.withPositionValue(FantasyPositionRule.cleanSheet, FantasySlot.forward, 2.5);
      expect(table.cleanSheet[FantasySlot.forward], 2.5);
      expect(table.cleanSheet[FantasySlot.goalkeeper], 5);
    });
  });

  test('PredictionRules: ordem exato ≥ saldo ≥ vencedor, senão padrões', () {
    expect(PredictionRules.fromMap({'exato': 15, 'vencedorSaldo': 8, 'vencedor': 4}),
        const PredictionRules(exact: 15, winnerAndDiff: 8, winner: 4));
    expect(PredictionRules.fromMap({'exato': 3, 'vencedorSaldo': 8, 'vencedor': 4}), PredictionRules.defaults);
    expect(PredictionRules.fromMap({'exato': 60}), PredictionRules.defaults);
    expect(
      PredictionHub.hitRate(const PredictionRankingEntry(uid: 'a', name: 'A', points: 30, exact: 1, count: 2),
          maxPoints: 20),
      0.75,
    );
  });

  testWidgets('painel: edita o Fantasy e o bolão e salva cada um', (tester) async {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _ScoringRepo();
    final cubit = _settings(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(_app(BlocProvider.value(value: cubit, child: const ScoringSettingsPage())));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('scoring-fantasy-base-more')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('scoring-fantasy-conceded-gol-less')));
    await tester.pump();
    expect(find.text('+10,5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scoring-fantasy-save')));
    await tester.pumpAndSettle();
    expect(repo.savedTables.single.base, 10.5);
    expect(repo.savedTables.single.conceded[FantasySlot.goalkeeper], -3.5);
    expect(find.text('Pontuação salva.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('scoring-tab-bolao')));
    await tester.pumpAndSettle();
    // O vencedor não passa do saldo (7): para no 7.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const ValueKey('scoring-bolao-winner-more')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('scoring-bolao-exact-more')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('scoring-bolao-save')));
    await tester.pumpAndSettle();
    expect(repo.savedRules.single, const PredictionRules(exact: 11, winnerAndDiff: 7, winner: 7));
  });

  testWidgets('regras do Fantasy: a tabela própria do campeonato e, sem ela, a padrão em vigor', (tester) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final own = FantasyConfigDTO.fromMap('doc1', {
      'ativo': true,
      'pontuacao': {'base': 8, 'gol': 7.5},
    });
    await tester.pumpWidget(_app(FantasyRulesPage(config: own)));
    await tester.pumpAndSettle();
    expect(find.text('+8'), findsWidgets);
    expect(find.text('+7,5'), findsOneWidget);

    final config = ScoringConfigCubit(
        WatchFantasyScoringTableUseCase(_ScoringRepo(table: const FantasyScoringTable(base: 12))),
        WatchPredictionRulesUseCase(_ScoringRepo()))
      ..follow();
    addTearDown(config.close);
    await tester
        .pumpWidget(_app(FantasyRulesPage(config: FantasyConfigDTO.fromMap('doc1', {'ativo': true})), config: config));
    await tester.pumpAndSettle();
    expect(find.text('+12'), findsOneWidget);
  });

  testWidgets('bolão: as fichas "Como pontua" seguem o config', (tester) async {
    final config = ScoringConfigCubit(WatchFantasyScoringTableUseCase(_ScoringRepo()),
        WatchPredictionRulesUseCase(_ScoringRepo(rules: const PredictionRules(exact: 15, winnerAndDiff: 9, winner: 4))))
      ..follow();
    addTearDown(config.close);
    await tester.pumpWidget(_app(const Scaffold(body: HubHowItScores()), config: config));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('Fantasy do campeonato: tabela própria liga, edita, salva e volta à padrão', (tester) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FantasyRepo();
    final cubit = FantasySettingsCubit(WatchFantasyConfigUseCase(repo), SaveFantasyConfigUseCase(repo));
    addTearDown(cubit.close);
    await tester
        .pumpWidget(_app(BlocProvider.value(value: cubit, child: const FantasySettingsPage(championship: _copa))));
    repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', {'ativo': true}, championship: _copa)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fantasy-table-base-more')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fantasy-own-table')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fantasy-table-goal-more')));
    await tester.pump();
    await cubit.save();
    expect(repo.saved.last.scoringTable?.goal, 5.5);
    expect(repo.saved.last.toAdminMap()['pontuacao'], isA<Map<String, dynamic>>());

    await tester.tap(find.byKey(const ValueKey('fantasy-own-table')));
    await tester.pumpAndSettle();
    await cubit.save();
    expect(repo.saved.last.scoringTable, isNull);
    expect(repo.saved.last.toAdminMap().containsKey('pontuacao'), isFalse);
  });

  testWidgets('Fantasy do campeonato: o admin muda o número de atletas e confirma ao salvar', (tester) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FantasyRepo();
    final cubit = FantasySettingsCubit(WatchFantasyConfigUseCase(repo), SaveFantasyConfigUseCase(repo));
    addTearDown(cubit.close);
    await tester
        .pumpWidget(_app(BlocProvider.value(value: cubit, child: const FantasySettingsPage(championship: _copa))));
    repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', {'ativo': true}, championship: _copa)));
    await tester.pumpAndSettle();
    expect(find.text('5 atletas'), findsOneWidget);

    // Sem goleiro e sem livre: 3 atletas; tirar mais um não deixa salvar.
    await tester.tap(find.byKey(const ValueKey('fantasy-formation-gol-less')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('fantasy-formation-livre-less')));
    await tester.pump();
    expect(find.text('3 atletas'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-formation-ata-less')));
    await tester.pump();
    expect(find.text('A escalação tem de 3 a 7 atletas.'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(repo.saved, isEmpty);

    // 1-2-2-2 (7): pede confirmação e grava `vagas`.
    await tester.tap(find.byKey(const ValueKey('fantasy-formation-gol-more')));
    for (final slot in ['zag', 'mei', 'ata', 'ata']) {
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('fantasy-formation-$slot-more')));
    }
    await tester.pump();
    expect(find.text('7 atletas'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Mudar a escalação?'), findsOneWidget);
    await tester.tap(find.text('Mudar'));
    await tester.pumpAndSettle();
    expect(repo.saved.single.toAdminMap()['vagas'], {'gol': 1, 'zag': 2, 'mei': 2, 'ata': 2, 'livre': 0});
  });
}
