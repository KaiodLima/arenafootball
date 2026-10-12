import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Compartilhamento pelo seletor nativo do sistema (WhatsApp, Instagram...).
/// Isola o `share_plus` para as telas não dependerem do pacote.
class ShareService {
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: subject));
    } catch (e) {
      // Cancelar ou não ter app de destino não é erro para o usuário.
      AppLogger.e('shareText', name: 'ShareService', error: e);
    }
  }

  /// Compartilha uma imagem PNG (ex.: o "print" da carteirinha) com um texto.
  /// O `share_plus` grava o arquivo temporário sozinho.
  static Future<void> shareImage(Uint8List png, {String? text, String fileName = 'arena_football.png'}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)], text: text),
      );
    } catch (e) {
      AppLogger.e('shareImage', name: 'ShareService', error: e);
    }
  }
}
