import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/core/utils/share_links.dart';

/// Links que abrem o app (`https://arenasoccerflutter.web.app/...` e
/// `arenafootball://...`): guarda o que abriu o app e avisa os que chegam
/// com ele aberto. Nunca derruba o app: falhas só vão para o log.
class DeepLinkService {
  final AppLinks _appLinks;
  final _targets = StreamController<DeepLinkTarget>.broadcast();
  StreamSubscription<Uri>? _subscription;
  DeepLinkTarget? _pending;
  Uri? _initialUri;

  DeepLinkService([AppLinks? appLinks]) : _appLinks = appLinks ?? AppLinks();

  /// Destinos de links abertos com o app já rodando.
  Stream<DeepLinkTarget> get targets => _targets.stream;

  /// Destino do link que abriu o app (uma vez só).
  DeepLinkTarget? takePending() {
    final target = _pending;
    _pending = null;
    return target;
  }

  Future<void> init() async {
    try {
      _initialUri = await _appLinks.getInitialLink();
      if (_initialUri != null) _pending = _parse(_initialUri!);
      _subscription ??= _appLinks.uriLinkStream.listen(
        _onLink,
        onError: (Object e) => AppLogger.e('uriLinkStream', name: 'DeepLinkService', error: e),
      );
    } catch (e) {
      AppLogger.e('init', name: 'DeepLinkService', error: e);
    }
  }

  void _onLink(Uri uri) {
    // O stream também entrega o link inicial: não abre duas vezes.
    if (_initialUri != null && uri == _initialUri) {
      _initialUri = null;
      return;
    }
    final target = _parse(uri);
    if (target == null) return;
    // Ninguém ouvindo ainda (home não abriu): fica para o takePending.
    if (_targets.hasListener) {
      _targets.add(target);
    } else {
      _pending = target;
    }
  }

  DeepLinkTarget? _parse(Uri uri) {
    final target = parseDeepLink(uri);
    if (target == null) AppLogger.d('link ignorado: $uri', name: 'DeepLinkService');
    return target;
  }
}
