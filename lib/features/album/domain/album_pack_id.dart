import 'dart:math' as math;

import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';

/// Pacotinho do dia do álbum: o id do doc é `<evento>_<uid>_<a-m-d>` (dia em
/// Brasília), o que garante um por dia pelas regras do Firestore (igual a
/// `packId` em `functions/src/album.ts`).
class AlbumPackId {
  const AlbumPackId._();

  static String of({required String eventId, required String userId, required DateTime now}) =>
      '${eventId}_${userId}_${PartnerSlots.brasiliaDay(now)}';

  /// Quanto falta para o próximo pacote: a meia-noite de Brasília (UTC-3).
  static Duration untilNext(DateTime now) {
    final local = now.toUtc().subtract(const Duration(hours: 3));
    final midnight = DateTime.utc(local.year, local.month, local.day + 1);
    return midnight.difference(local);
  }

  /// Contagem curta do selo da home: "7h12", "7h" ou "45min".
  static String shortLabel(Duration left) {
    final hours = left.inHours;
    final minutes = left.inMinutes % 60;
    if (hours == 0) return '${math.max(1, minutes)}min';
    return minutes == 0 ? '${hours}h' : '${hours}h${minutes.toString().padLeft(2, '0')}';
  }
}
