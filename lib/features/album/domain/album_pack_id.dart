import 'dart:math' as math;

/// Pacotinho do álbum: um a cada 24 h por conta, contadas do último pedido
/// (não acumula). O id do doc é `<evento>_<uid>_<n>`, n = pacotes já abertos
/// + 1: as regras do Firestore conferem a sequência e as 24 h (igual a
/// `packId`/`canOpenPack` em `functions/src/album.ts`).
class AlbumPackId {
  const AlbumPackId._();

  static const Duration interval = Duration(hours: 24);

  /// Id do próximo pacote da conta, que já abriu [opened].
  static String next({required String eventId, required String userId, required int opened}) =>
      '${eventId}_${userId}_${opened + 1}';

  /// Quando libera o próximo (nulo = nunca abriu: já liberado).
  static DateTime? nextAt(DateTime? lastPack) => lastPack?.add(interval);

  static bool isAvailable(DateTime? lastPack, DateTime now) {
    final next = nextAt(lastPack);
    return next == null || !now.isBefore(next);
  }

  /// Quanto falta para o próximo (zero se já liberado).
  static Duration untilNext(DateTime? lastPack, DateTime now) {
    final next = nextAt(lastPack);
    if (next == null || !now.isBefore(next)) return Duration.zero;
    return next.difference(now);
  }

  /// Quanto falta até [nextAt] (zero se já passou ou nulo).
  static Duration leftUntil(DateTime? nextAt, DateTime now) {
    if (nextAt == null || !now.isBefore(nextAt)) return Duration.zero;
    return nextAt.difference(now);
  }

  /// Contagem curta do selo da home: "7h12", "7h" ou "45min".
  static String shortLabel(Duration left) {
    final hours = left.inHours;
    final minutes = left.inMinutes % 60;
    if (hours == 0) return '${math.max(1, minutes)}min';
    return minutes == 0 ? '${hours}h' : '${hours}h${minutes.toString().padLeft(2, '0')}';
  }
}
