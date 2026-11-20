import 'package:flutter/widgets.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/usecases/app_version_usecases.dart';
import 'package:arena_soccer/features/app_version/presentation/widgets/app_update_dialog.dart';

/// Aviso de atualização: compara o build instalado com o `config/versao` e abre
/// o modal. Verifica na home (`check`) e quando o app volta do segundo plano
/// (no máximo a cada [interval]; o obrigatório, sempre). Sugerido + "Depois"
/// guarda o build recomendado dispensado: só volta quando o admin subir de novo.
class AppUpdateChecker with WidgetsBindingObserver {
  final GetAppVersionConfigUseCase _config;
  final GetInstalledBuildUseCase _installed;
  final PreferencesService _prefs;

  AppUpdateChecker(this._config, this._installed, this._prefs);

  static const Duration interval = Duration(hours: 6);

  DateTime? _lastCheck;
  bool _showing = false;
  bool _observing = false;

  /// O último aviso foi o obrigatório (volta a verificar a cada retorno).
  bool _blocked = false;

  /// Começa a ouvir a volta do segundo plano (uma vez).
  void start() {
    if (_observing) return;
    _observing = true;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final context = AppSession.navigatorKey.currentContext;
    if (context == null) return;
    final last = _lastCheck;
    if (!_blocked && last != null && DateTime.now().difference(last) < interval) return;
    check(context);
  }

  /// Verifica e, se precisar, mostra o modal. Sem rede/config = nada.
  Future<void> check(BuildContext context) async {
    if (_showing) return;
    _lastCheck = DateTime.now();
    final installed = await _installed();
    final response = await _config();
    if (response.isLeft) return;
    final config = response.right;
    final ios = appUpdateIsIos;
    final level = appUpdateLevel(installed, config, ios: ios);
    _blocked = level == AppUpdateLevel.required;
    if (level == AppUpdateLevel.none) return;
    final recommended = config.recommendedFor(ios: ios);
    if (level == AppUpdateLevel.recommended && await _prefs.getDismissedUpdateBuild() >= recommended) return;
    if (!context.mounted) return;
    _showing = true;
    final result = await showAppUpdateDialog(context, level: level, message: config.message);
    _showing = false;
    if (level == AppUpdateLevel.recommended && result == false) await _prefs.setDismissedUpdateBuild(recommended);
  }
}
