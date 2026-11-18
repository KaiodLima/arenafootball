import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_settings_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_settings_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _copa = ChampionshipDTO(
  id: 'doc1',
  championshipId: 7,
  title: 'Copa Verde',
  region: 'Floresta',
  season: '2026',
  regionIds: ['fl'],
  imageUrl: 'https://x/logo.png',
);

class _Repo implements IFantasyRepository {
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

void main() {
  group('FantasyConfigDTO', () {
    test('sem o doc: desligado com os padrões e as cópias do campeonato', () {
      final config = FantasyConfigDTO.fromMap('doc1', null, championship: _copa);
      expect(config.active, isFalse);
      expect((config.minMinutes, config.minDefenseMinutes, config.captainMultiplier), (20, 45, 1.5));
      final map = config.toAdminMap();
      expect(map['idCampeonato'], 7);
      expect(map['temporada'], '2026');
      expect(map['titulo'], 'Copa Verde');
      expect(map['urlImagem'], 'https://x/logo.png');
      expect(map['idsRegioes'], ['fl']);
      expect(map.containsKey('participantes'), isFalse);
      expect(map.containsKey('rodadaAtual'), isFalse);
    });

    test('lê os parâmetros e os campos das functions', () {
      final config = FantasyConfigDTO.fromMap('doc1', {
        'ativo': true,
        'minMinutos': 30,
        'minMinutosDefesa': 60,
        'capitao': 2,
        'rodadaAtual': 3,
        'participantes': 12,
      });
      expect(
          (config.active, config.minMinutes, config.minDefenseMinutes, config.captainMultiplier), (true, 30, 60, 2.0));
      expect((config.currentRound, config.participants), (3, 12));
      final again = FantasyConfigDTO.fromMap('doc1', config.toAdminMap());
      expect((again.active, again.minMinutes, again.minDefenseMinutes, again.captainMultiplier), (true, 30, 60, 2.0));
    });
  });

  test('FantasySettings: faixas, defensivo e capitão', () {
    FantasySettingsError? v(int min, int defense, double captain) =>
        FantasySettings.validate(minMinutes: min, minDefenseMinutes: defense, captainMultiplier: captain);
    expect(v(20, 45, 1.5), isNull);
    expect(v(0, 0, 1), isNull);
    expect(v(121, 121, 1.5), FantasySettingsError.minMinutesRange);
    expect(v(30, 20, 1.5), FantasySettingsError.defenseBelowMin);
    expect(v(20, 125, 1.5), FantasySettingsError.defenseRange);
    expect(v(20, 45, 3.5), FantasySettingsError.captainRange);
    expect(FantasySettings.captainLabel(1.5), '1,5×');
    expect(FantasySettings.captainLabel(2.0000001), '2×');
  });

  test('use case: parâmetro inválido não vai ao servidor', () async {
    final repo = _Repo();
    final save = SaveFantasyConfigUseCase(repo);
    final bad = FantasyConfigDTO.forChampionship(_copa).copyWith(minMinutes: 50, minDefenseMinutes: 40);
    expect((await save(bad)).isLeft, isTrue);
    expect(repo.saved, isEmpty);
    expect((await save(bad.copyWith(minDefenseMinutes: 60, captainMultiplier: 1.7000001))).isRight, isTrue);
    expect(repo.saved.single.captainMultiplier, 1.7);
  });

  group('cubit', () {
    test('carrega, edita e salva; servidor não atropela o rascunho', () async {
      final repo = _Repo();
      final cubit = FantasySettingsCubit(WatchFantasyConfigUseCase(repo), SaveFantasyConfigUseCase(repo));
      addTearDown(cubit.close);
      cubit.load(_copa);
      repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', null, championship: _copa)));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.loading, isFalse);
      cubit.setActive(true);
      cubit.setMinMinutes(25);
      cubit.setCaptain(1.6);
      repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', {'participantes': 2}, championship: _copa)));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.draft?.active, isTrue);
      await cubit.save();
      expect(repo.saved.single.minMinutes, 25);
      expect(repo.saved.single.captainMultiplier, 1.6);
      expect(cubit.state.result, FantasySaveResult.saved);
      expect(cubit.state.dirty, isFalse);
    });

    test('inválido não salva; restaurar padrões', () async {
      final repo = _Repo();
      final cubit = FantasySettingsCubit(WatchFantasyConfigUseCase(repo), SaveFantasyConfigUseCase(repo));
      addTearDown(cubit.close);
      cubit.load(_copa);
      repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', null, championship: _copa)));
      await Future<void>.delayed(Duration.zero);
      cubit.setMinMinutes(60);
      expect(cubit.state.error, FantasySettingsError.defenseBelowMin);
      await cubit.save();
      expect(repo.saved, isEmpty);
      cubit.setCaptain(9);
      expect(cubit.state.draft?.captainMultiplier, 3);
      cubit.restoreDefaults();
      expect(cubit.state.error, isNull);
      expect(cubit.state.draft?.minMinutes, 20);
    });
  });

  testWidgets('página: liga, sobe o mínimo e salva', (tester) async {
    final repo = _Repo();
    final cubit = FantasySettingsCubit(WatchFantasyConfigUseCase(repo), SaveFantasyConfigUseCase(repo));
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider.value(value: cubit, child: const FantasySettingsPage(championship: _copa)),
    ));
    repo.controller.add(Right(FantasyConfigDTO.fromMap('doc1', null, championship: _copa)));
    await tester.pump();
    expect(find.text('Copa Verde'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('1,5×'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-active')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('fantasy-min-more')));
    await tester.pump();
    expect(find.text('25 min'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repo.saved.single.active, isTrue);
    expect(repo.saved.single.minMinutes, 25);
    expect(find.text('Arena Fantasy salvo.'), findsOneWidget);
  });
}
