import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Compartilhamento pelo seletor nativo do sistema (WhatsApp, Instagram...).
/// Isola o `share_plus` para as telas não dependerem do pacote.
class ShareService {
  /// Chamado depois de um compartilhamento que não foi cancelado (conta
  /// para as conquistas; quem liga é o `AchievementsSync`).
  static void Function()? onShared;

  static void _done(ShareResult result) {
    if (result.status != ShareResultStatus.dismissed) onShared?.call();
  }

  static Future<void> shareText(String text, {String? subject}) async {
    try {
      _done(await SharePlus.instance.share(ShareParams(text: text, subject: subject)));
    } catch (e) {
      // Cancelar ou não ter app de destino não é erro para o usuário.
      AppLogger.e('shareText', name: 'ShareService', error: e);
    }
  }

  /// Salva o PNG na galeria (pacote `gal`; pede a permissão só quando o
  /// sistema exige). Devolve se salvou.
  static Future<bool> saveImage(Uint8List png, {required String name}) async {
    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) return false;
      await Gal.putImageBytes(png, name: name);
      onShared?.call();
      return true;
    } catch (e) {
      AppLogger.e('saveImage', name: 'ShareService', error: e);
      return false;
    }
  }

  /// Compartilha uma imagem PNG (ex.: o "print" da carteirinha) com um texto.
  /// O `share_plus` grava o arquivo temporário sozinho.
  static Future<void> shareImage(Uint8List png, {String? text, String fileName = 'arena_football.png'}) async {
    try {
      _done(await SharePlus.instance.share(
        ShareParams(files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)], text: text),
      ));
    } catch (e) {
      AppLogger.e('shareImage', name: 'ShareService', error: e);
    }
  }
}
