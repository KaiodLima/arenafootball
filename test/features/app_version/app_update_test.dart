import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';
import 'package:arena_soccer/features/app_version/domain/usecases/app_version_usecases.dart';
import 'package:arena_soccer/features/app_version/presentation/app_update_checker.dart';
import 'package:arena_soccer/features/app_version/presentation/bloc/app_version_settings_cubit.dart';
import 'package:arena_soccer/features/app_version/presentation/page/app_version_settings_page.dart';
import 'package:arena_soccer/features/app_version/presentation/widgets/app_update_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

class _Repo implements IAppVersionRepository {
  AppVersionConfig config;
  int installed;
  final saved = <AppVersionConfig>[];

  _Repo({this.config = const AppVersionConfig()}) : installed = 43;

  @override
  Future<Either<Failure, AppVersionConfig>> getConfig() async => Right(config);

  @override
  Future<Either<Failure, void>> saveConfig(AppVersionConfig config) async {
    saved.add(config);
    return const Right(null);
  }

  @override
  Future<int> installedBuild() async => installed;

  @override
  Future<String> installedVersionName() async => '2.0.18';

  // Sem cache: o aviso sempre lê a config (o cache tem teste próprio).
  @override
  Future<Either<Failure, CachedValue<AppVersionConfig>?>> getCachedConfig() async => const Right(null);

  @override
  Future<Either<Failure, void>> saveConfigCache(AppVersionConfig config) async => const Right(null);

  @override
  Future<void> deleteConfigCache() async {}
}

AppVersionCacheFirstUseCase _cacheFirst(IAppVersionRepository repo) => AppVersionCacheFirstUseCase(
      GetAppVersionConfigUseCase(repo),
      GetCachedAppVersionConfigUseCase(repo),
      SaveAppVersionConfigCacheUseCase(repo),
    );

Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: home,
    );

void main() {
  test('nível do aviso: abaixo do mínimo obriga, abaixo do recomendado sugere', () {
    const config = AppVersionConfig(minAndroid: 40, recommendedAndroid: 44, minIos: 30, recommendedIos: 35);
    expect(appUpdateLevel(39, config, ios: false), AppUpdateLevel.required);
    expect(appUpdateLevel(43, config, ios: false), AppUpdateLevel.recommended);
    expect(appUpdateLevel(44, config, ios: false), AppUpdateLevel.none);
    expect(appUpdateLevel(50, config, ios: false), AppUpdateLevel.none);
    // iOS lê os campos dele.
    expect(appUpdateLevel(33, config, ios: true), AppUpdateLevel.recommended);
    expect(appUpdateLevel(29, config, ios: true), AppUpdateLevel.required);
    // Sem config ou build desconhecido: nada.
    expect(appUpdateLevel(10, const AppVersionConfig(), ios: false), AppUpdateLevel.none);
    expect(appUpdateLevel(0, config, ios: false), AppUpdateLevel.none);
    expect(AppStores.forPlatform(ios: false), contains('com.caiolima.arenafootball'));
    expect(AppStores.forPlatform(ios: true), contains('apps.apple.com'));
  });

  test('config: lê e grava os campos do Firestore', () {
    final config = AppVersionConfig.fromMap(const {
      'minimoAndroid': 40,
      'recomendadoAndroid': 44,
      'minimoIos': 1,
      'recomendadoIos': 2,
      'mensagem': ' Chegou o Fantasy ',
    });
    expect((config.minAndroid, config.recommendedAndroid, config.minIos, config.recommendedIos, config.message),
        (40, 44, 1, 2, 'Chegou o Fantasy'));
    expect(config.toMap()['recomendadoAndroid'], 44);
    expect(AppVersionConfig.fromMap(null), const AppVersionConfig());
  });

  testWidgets('obrigatório: só "Atualizar agora" e não fecha com o voltar', (tester) async {
    var opened = 0;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showAppUpdateDialog(
            context,
            level: AppUpdateLevel.required,
            message: 'Chegou o Fantasy!',
            onUpdate: () async => opened++,
          ),
          child: const Text('abrir'),
        ),
      ),
    )));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-update-required')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-update-later')), findsNothing);
    expect(find.text('Chegou o Fantasy!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('app-update-now')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.byKey(const ValueKey('app-update-required')), findsOneWidget, reason: 'continua aberto');
    // Voltar do sistema não fecha.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-update-required')), findsOneWidget);
  });

  testWidgets('sugerido: "Depois" guarda o build e não avisa de novo o mesmo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _Repo(config: const AppVersionConfig(recommendedAndroid: 44, recommendedIos: 44));
    final checker = AppUpdateChecker(_cacheFirst(repo), GetInstalledBuildUseCase(repo), PreferencesService());
    late BuildContext ctx;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      ctx = context;
      return const Scaffold();
    })));
    checker.check(ctx);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-update-recommended')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('app-update-later')));
    await tester.pumpAndSettle();
    expect(await PreferencesService().getDismissedUpdateBuild(), 44);

    await checker.check(ctx);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-update-recommended')), findsNothing);

    // O admin subiu a recomendada: avisa de novo.
    repo.config = const AppVersionConfig(recommendedAndroid: 45, recommendedIos: 45);
    checker.check(ctx);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app-update-recommended')), findsOneWidget);
  });

  testWidgets('painel do admin: build instalado, "usar como recomendado" e salvar com confirmação do mínimo',
      (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo(config: const AppVersionConfig(minAndroid: 40, recommendedAndroid: 42));
    final cubit = AppVersionSettingsCubit(
        GetAppVersionConfigUseCase(repo), SaveAppVersionConfigUseCase(repo), GetInstalledBuildUseCase(repo));
    addTearDown(cubit.close);
    await tester.pumpWidget(_app(BlocProvider.value(value: cubit, child: const AppVersionSettingsPage())));
    await tester.pumpAndSettle();
    expect(find.text('Este aparelho: Android 2.0.18 (build 43)'), findsOneWidget);
    expect(find.text('Build mínimo'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('app-version-use-installed')));
    await tester.pump();
    expect(cubit.state.draft.recommendedAndroid, 43);
    // Sobe o mínimo do Android: pede confirmação.
    await tester.tap(find.byKey(const ValueKey('android-min-plus')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('app-version-save')));
    await tester.pumpAndSettle();
    expect(find.text('Subir a versão mínima?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('app-version-raise-confirm')));
    await tester.pumpAndSettle();
    expect(repo.saved.single, const AppVersionConfig(minAndroid: 41, recommendedAndroid: 43));
    expect(find.text('Versões salvas.'), findsOneWidget);
  });

  test('editar: mínimo acima do recomendado sobe o recomendado junto', () async {
    final repo = _Repo();
    final cubit = AppVersionSettingsCubit(
        GetAppVersionConfigUseCase(repo), SaveAppVersionConfigUseCase(repo), GetInstalledBuildUseCase(repo));
    addTearDown(cubit.close);
    await cubit.load();
    cubit.edit((d) => d.copyWith(minIos: 7));
    expect((cubit.state.draft.minIos, cubit.state.draft.recommendedIos), (7, 7));
    expect(cubit.state.raisesMinimum, isTrue);
  });
}
