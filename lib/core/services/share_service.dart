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
}
