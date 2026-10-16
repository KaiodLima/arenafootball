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
  static const String appPath = 'app';
}

final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,128}$');
final RegExp _seasonPattern = RegExp(r'^\d{4}$');

/// Página pública da notícia.
String newsLink(String id) => '${ShareLinks.baseUrl}/${ShareLinks.newsPath}/$id';

/// Página pública do atleta na temporada ([season] = ano da coleção dele).
String athleteLink(String season, String id) => '${ShareLinks.baseUrl}/${ShareLinks.athletePath}/$season/$id';

/// Página pública do destaque.
String highlightLink(String id) => '${ShareLinks.baseUrl}/${ShareLinks.highlightPath}/$id';

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
    case ShareLinks.appPath when segments.length == 1:
      return const AppLinkTarget();
    default:
      return null;
  }
}
