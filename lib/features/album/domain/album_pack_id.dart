import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';

/// Pacotinho do dia do álbum: o id do doc é `<evento>_<uid>_<a-m-d>` (dia em
/// Brasília), o que garante um por dia pelas regras do Firestore (igual a
/// `packId` em `functions/src/album.ts`).
class AlbumPackId {
  const AlbumPackId._();

  static String of({required String eventId, required String userId, required DateTime now}) =>
      '${eventId}_${userId}_${PartnerSlots.brasiliaDay(now)}';
}
