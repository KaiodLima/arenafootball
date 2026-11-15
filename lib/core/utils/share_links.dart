/// Links públicos do Arena (Hosting + Cloud Function `sharePage`) e o leitor
/// dos deep links que abrem o app. Os caminhos precisam ser os mesmos do
/// servidor (`functions/src/share_page.ts`).
class ShareLinks {
  static const String host = 'arenasoccerflutter.web.app';
  static const String baseUrl = 'https://$host';

  /// Esquema próprio usado pelo botão "Abrir no app" da página web.
  static const String appScheme = 'arenafootball';

  static const String newsPath = 'noticia';
  static const String athletePath = 'atleta';
  static const String highlightPath = 'destaque';
  static const String invitePath = 'convite';
  static const String appPath = 'app';

  /// Votação do craque da partida (`/votacao/<temporada>/<idPartida>`).
  static const String votePath = 'votacao';

  /// Detalhe da partida, com o palpite (`/partida/<temporada>/<idPartida>`).
  static const String matchPath = 'partida';

  /// Central do bolão.
  static const String poolPath = 'bolao';

  /// Álbum de figurinhas.
  static const String albumPath = 'album';

  /// QR fixo da região: "Acontecendo agora" (`/agora/<idRegiao>`).
  static const String nowPath = 'agora';
}

final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,128}$');
final RegExp _seasonPattern = RegExp(r'^\d{4}$');
final RegExp _invitePattern = RegExp(r'^[A-Za-z0-9]{8,10}$');

/// Página pública da notícia.
String newsLink(String id) => '${ShareLinks.baseUrl}/${ShareLinks.newsPath}/$id';

/// Página pública do atleta na temporada ([season] = ano da coleção dele).
String athleteLink(String season, String id) => '${ShareLinks.baseUrl}/${ShareLinks.athletePath}/$season/$id';

/// Página pública do destaque.
String highlightLink(String id) => '${ShareLinks.baseUrl}/${ShareLinks.highlightPath}/$id';

/// Convite do "Indique amigos" com o [code] da conta.
String inviteLink(String code) => '${ShareLinks.baseUrl}/${ShareLinks.invitePath}/$code';

/// Votação do craque da partida [matchId] da temporada [season].
String voteLink(String season, String matchId) => '${ShareLinks.baseUrl}/${ShareLinks.votePath}/$season/$matchId';

/// Partida [matchId] da temporada [season] (detalhe com o palpite).
String matchLink(String season, String matchId) => '${ShareLinks.baseUrl}/${ShareLinks.matchPath}/$season/$matchId';

/// Central do bolão.
const String poolLink = '${ShareLinks.baseUrl}/${ShareLinks.poolPath}';

/// Álbum de figurinhas.
const String albumLink = '${ShareLinks.baseUrl}/${ShareLinks.albumPath}';

/// QR fixo da região [regionId] (id do doc de `competicao`): "Acontecendo agora".
String nowLink(String regionId) => '${ShareLinks.baseUrl}/${ShareLinks.nowPath}/$regionId';

/// Página genérica do app (carteirinha, craque da partida).
const String appLink = '${ShareLinks.baseUrl}/${ShareLinks.appPath}';

/// Destino de um deep link.
sealed class DeepLinkTarget {
  const DeepLinkTarget();
}

class NewsLinkTarget extends DeepLinkTarget {
  final String id;

  const NewsLinkTarget(this.id);

  @override
  bool operator ==(Object other) => other is NewsLinkTarget && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class AthleteLinkTarget extends DeepLinkTarget {
  final String season;
  final String id;

  const AthleteLinkTarget({required this.season, required this.id});

  @override
  bool operator ==(Object other) => other is AthleteLinkTarget && other.season == season && other.id == id;

  @override
  int get hashCode => Object.hash(season, id);
}

class HighlightLinkTarget extends DeepLinkTarget {
  final String id;

  const HighlightLinkTarget(this.id);

  @override
  bool operator ==(Object other) => other is HighlightLinkTarget && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Convite do "Indique amigos": abre a tela com o código preenchido.
class InviteLinkTarget extends DeepLinkTarget {
  final String code;

  const InviteLinkTarget(this.code);

  @override
  bool operator ==(Object other) => other is InviteLinkTarget && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Votação do craque da partida.
class VoteLinkTarget extends DeepLinkTarget {
  final String season;
  final String matchId;

  const VoteLinkTarget({required this.season, required this.matchId});

  @override
  bool operator ==(Object other) => other is VoteLinkTarget && other.season == season && other.matchId == matchId;

  @override
  int get hashCode => Object.hash('vote', season, matchId);
}

/// Detalhe da partida (palpite e placar).
class MatchLinkTarget extends DeepLinkTarget {
  final String season;
  final String matchId;

  const MatchLinkTarget({required this.season, required this.matchId});

  @override
  bool operator ==(Object other) => other is MatchLinkTarget && other.season == season && other.matchId == matchId;

  @override
  int get hashCode => Object.hash('match', season, matchId);
}

/// Central do bolão.
class PoolLinkTarget extends DeepLinkTarget {
  const PoolLinkTarget();

  @override
  bool operator ==(Object other) => other is PoolLinkTarget;

  @override
  int get hashCode => 1;
}

/// Álbum de figurinhas.
class AlbumLinkTarget extends DeepLinkTarget {
  const AlbumLinkTarget();

  @override
  bool operator ==(Object other) => other is AlbumLinkTarget;

  @override
  int get hashCode => 2;
}

/// QR fixo da região: o que está acontecendo agora nela.
class NowLinkTarget extends DeepLinkTarget {
  final String regionId;

  const NowLinkTarget(this.regionId);

  @override
  bool operator ==(Object other) => other is NowLinkTarget && other.regionId == regionId;

  @override
  int get hashCode => Object.hash('now', regionId);
}

class AppLinkTarget extends DeepLinkTarget {
  const AppLinkTarget();

  @override
  bool operator ==(Object other) => other is AppLinkTarget;

  @override
  int get hashCode => 0;
}

/// Lê `https://arenasoccerflutter.web.app/<caminho>` ou
/// `arenafootball://<caminho>` (no esquema próprio o 1º trecho é o host da
/// URI). Qualquer outra coisa (host errado, id ou temporada inválidos) = nulo.
DeepLinkTarget? parseDeepLink(Uri uri) {
  final List<String> segments;
  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'https' || scheme == 'http') {
    if (uri.host.toLowerCase() != ShareLinks.host) return null;
    segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  } else if (scheme == ShareLinks.appScheme) {
    segments = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).toList();
  } else {
    return null;
  }
  if (segments.isEmpty) return null;

  bool validId(String id) => _idPattern.hasMatch(id);

  switch (segments.first) {
    case ShareLinks.newsPath when segments.length == 2 && validId(segments[1]):
      return NewsLinkTarget(segments[1]);
    case ShareLinks.athletePath
        when segments.length == 3 && _seasonPattern.hasMatch(segments[1]) && validId(segments[2]):
      return AthleteLinkTarget(season: segments[1], id: segments[2]);
    case ShareLinks.highlightPath when segments.length == 2 && validId(segments[1]):
      return HighlightLinkTarget(segments[1]);
    case ShareLinks.invitePath when segments.length == 2 && _invitePattern.hasMatch(segments[1]):
      return InviteLinkTarget(segments[1].toUpperCase());
    case ShareLinks.votePath
        when segments.length == 3 && _seasonPattern.hasMatch(segments[1]) && validId(segments[2]):
      return VoteLinkTarget(season: segments[1], matchId: segments[2]);
    case ShareLinks.matchPath
        when segments.length == 3 && _seasonPattern.hasMatch(segments[1]) && validId(segments[2]):
      return MatchLinkTarget(season: segments[1], matchId: segments[2]);
    case ShareLinks.poolPath when segments.length == 1:
      return const PoolLinkTarget();
    case ShareLinks.albumPath when segments.length == 1:
      return const AlbumLinkTarget();
    case ShareLinks.nowPath when segments.length == 2 && validId(segments[1]):
      return NowLinkTarget(segments[1]);
    case ShareLinks.appPath when segments.length == 1:
      return const AppLinkTarget();
    default:
      return null;
  }
}
