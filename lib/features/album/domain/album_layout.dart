import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Uma página do álbum: um time e as figurinhas dele (escudo primeiro).
class AlbumTeamPage extends Equatable {
  final String teamId;
  final String team;
  final List<StickerDTO> stickers;

  const AlbumTeamPage({required this.teamId, required this.team, required this.stickers});

  /// Coladas desta página no álbum [album].
  int collected(UserAlbumDTO album) => stickers.where((s) => album.has(s.id)).length;

  bool isComplete(UserAlbumDTO album) => stickers.isNotEmpty && collected(album) == stickers.length;

  /// Figurinhas coladas da página, na ordem (o "folhear" da tela de detalhe).
  List<StickerDTO> collectedStickers(UserAlbumDTO album) => stickers.where((s) => album.has(s.id)).toList();

  @override
  List<Object?> get props => [teamId, team, stickers];
}

/// Organização do álbum: páginas por time, numeração e figurinhas geradas do
/// elenco (admin).
class AlbumLayout {
  const AlbumLayout._();

  /// Escudo primeiro; depois a ordem e o nome.
  static int _compare(StickerDTO a, StickerDTO b) {
    if (a.kind != b.kind) return a.kind == StickerKind.crest ? -1 : 1;
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// Páginas na ordem dos times do evento; figurinha de time fora do evento
  /// entra numa página no fim (não some do álbum).
  static List<AlbumTeamPage> pages(AlbumEventDTO event, List<StickerDTO> stickers) {
    final byTeam = <String, List<StickerDTO>>{};
    for (final sticker in stickers) {
      byTeam.putIfAbsent(sticker.teamId, () => []).add(sticker);
    }
    final pages = <AlbumTeamPage>[];
    for (final teamId in event.teamIds) {
      final list = (byTeam.remove(teamId) ?? [])..sort(_compare);
      pages.add(AlbumTeamPage(teamId: teamId, team: event.teamName(teamId), stickers: list));
    }
    for (final entry in byTeam.entries) {
      final list = entry.value..sort(_compare);
      pages.add(AlbumTeamPage(teamId: entry.key, team: list.first.team, stickers: list));
    }
    return pages;
  }

  /// Numera o álbum todo em sequência (página por página). Devolve só as
  /// figurinhas cujo número mudou (para gravar).
  static List<StickerDTO> renumber(AlbumEventDTO event, List<StickerDTO> stickers) {
    var number = 0;
    final changed = <StickerDTO>[];
    for (final page in pages(event, stickers)) {
      for (final sticker in page.stickers) {
        number++;
        if (sticker.number != number) changed.add(sticker.copyWith(number: number));
      }
    }
    return changed;
  }

  /// Elenco do time [teamId]/[team] na competição [championshipId] (nula =
  /// elenco geral): a mesma regra das chips do elenco (`PlayerDTO.playsIn`;
  /// atleta antigo, sem inscrições, conta em toda competição do time).
  static List<PlayerDTO> squadIn(
    List<PlayerDTO> players, {
    required int? championshipId,
    required String teamId,
    required String team,
  }) {
    if (championshipId == null) return players;
    return players.where((p) => p.playsIn(championshipId, teamId: teamId, teamName: team)).toList();
  }

  /// Figurinhas novas do time a partir do elenco: o escudo (se ainda não tem)
  /// e cada atleta que ainda não está no álbum (pelo id), com a foto atual.
  static List<StickerDTO> fromSquad({
    required String teamId,
    required String team,
    required String crestUrl,
    required List<PlayerDTO> players,
    required List<StickerDTO> existing,
  }) {
    final mine = existing.where((s) => s.teamId == teamId).toList();
    final hasCrest = mine.any((s) => s.kind == StickerKind.crest);
    final playerIds = {
      for (final s in mine)
        if (s.playerId.isNotEmpty) s.playerId
    };
    var order = mine.fold(0, (max, s) => s.order > max ? s.order : max);
    final sorted = [...players]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [
      if (!hasCrest) StickerDTO(kind: StickerKind.crest, name: team, teamId: teamId, team: team, imageUrl: crestUrl),
      for (final player in sorted)
        if (!playerIds.contains(player.id))
          StickerDTO(
            kind: StickerKind.athlete,
            name: player.name,
            teamId: teamId,
            team: team,
            playerId: player.id,
            imageUrl: player.imageUrl,
            order: ++order,
          ),
    ];
  }
}
