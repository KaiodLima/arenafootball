import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';

/// Troca de repetidas por pacotinho: a conta entrega [AlbumEventDTO.tradeSize]
/// repetidas diferentes (cada uma perde 1 e continua colada) e ganha um
/// pacotinho, até [AlbumEventDTO.tradesPerDay] vezes por dia (Brasília). As
/// mesmas regras da function (`tradeRefusal` em `functions/src/album.ts`).
class AlbumTrade {
  const AlbumTrade._();

  /// As repetidas (2 ou mais) do catálogo, da mais repetida para a menos
  /// (empate: a ordem do álbum).
  static List<StickerDTO> duplicates(List<StickerDTO> stickers, UserAlbumDTO album) {
    final list = [
      for (final s in stickers)
        if (album.countOf(s.id) > 1) s,
    ];
    final order = {for (var i = 0; i < stickers.length; i++) stickers[i].id: i};
    list.sort((a, b) {
      final byCount = album.countOf(b.id).compareTo(album.countOf(a.id));
      return byCount != 0 ? byCount : order[a.id]!.compareTo(order[b.id]!);
    });
    return list;
  }

  /// "Escolher automático": as [size] mais repetidas (menos, se não houver).
  static List<String> autoPick(List<StickerDTO> stickers, UserAlbumDTO album, int size) =>
      duplicates(stickers, album).take(size).map((s) => s.id).toList();

  /// Trocas que ainda dá para fazer hoje.
  static int tradesLeft(AlbumEventDTO event, UserAlbumDTO album, DateTime now) {
    final left = event.tradesPerDay - album.tradesOn(PartnerSlots.brasiliaDay(now));
    return left < 0 ? 0 : left;
  }

  /// Há repetidas diferentes suficientes para uma troca.
  static bool hasEnough(AlbumEventDTO event, List<StickerDTO> stickers, UserAlbumDTO album) =>
      event.tradeOn && duplicates(stickers, album).length >= event.tradeSize;

  /// Dá para trocar agora: troca ligada, repetidas suficientes e troca sobrando hoje.
  static bool canTrade(AlbumEventDTO event, List<StickerDTO> stickers, UserAlbumDTO album, DateTime now) =>
      hasEnough(event, stickers, album) && tradesLeft(event, album, now) > 0;

  /// A seleção [ids] está pronta: o tamanho do evento, sem repetir, todas repetidas.
  static bool validSelection(AlbumEventDTO event, UserAlbumDTO album, List<String> ids) =>
      event.tradeOn &&
      ids.length == event.tradeSize &&
      ids.toSet().length == ids.length &&
      ids.every((id) => album.countOf(id) > 1);
}
