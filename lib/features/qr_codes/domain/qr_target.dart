import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';

/// O que o QR code abre.
enum QrKind { vote, match, pool, album, event, now }

/// Destino de um QR code: o tipo, os textos do cartaz e o link público
/// (abre o app no conteúdo; sem o app, a página web com as lojas).
class QrTarget extends Equatable {
  final QrKind kind;

  /// Título grande do cartaz ("Gol mais bonito da rodada", "Lava Jato x Volta").
  final String title;

  /// Linha de apoio ("15/11 · 15:30"); vazia = nenhuma.
  final String subtitle;
  final String link;

  /// Os dois times (cartazes de partida e de votação).
  final ArtTeam? home;
  final ArtTeam? away;

  const QrTarget({
    required this.kind,
    required this.title,
    required this.link,
    this.subtitle = '',
    this.home,
    this.away,
  });

  bool get hasTeams => home != null && away != null;

  /// Central do bolão.
  factory QrTarget.pool({required String title, String subtitle = ''}) =>
      QrTarget(kind: QrKind.pool, title: title, subtitle: subtitle, link: poolLink);

  /// Álbum de figurinhas (o título do evento ativo).
  factory QrTarget.album({required String title, String subtitle = ''}) =>
      QrTarget(kind: QrKind.album, title: title, subtitle: subtitle, link: albumLink);

  /// QR fixo da região: "Acontecendo agora" (sempre o que está ativo nela).
  factory QrTarget.now({required String regionId, required String title, String subtitle = ''}) =>
      QrTarget(kind: QrKind.now, title: title, subtitle: subtitle, link: nowLink(regionId));

  /// Evento de votação do admin (a página do evento abre pelo link da notícia).
  factory QrTarget.event(NewsDTO news) =>
      QrTarget(kind: QrKind.event, title: news.title, subtitle: news.description, link: newsLink(news.id));

  /// Partida: com a votação do craque aberta, o QR da votação; senão, o da
  /// partida (palpite e placar). [voting] força um dos dois.
  factory QrTarget.forMatch(MatchDTO match, {required String season, ArtTeam? home, ArtTeam? away, bool? voting}) {
    final vote = voting ?? match.isVotingOpen;
    return QrTarget(
      kind: vote ? QrKind.vote : QrKind.match,
      title: '${match.homeTeam} x ${match.awayTeam}',
      subtitle: [match.date, match.time].where((p) => p.trim().isNotEmpty).join(' · '),
      link: vote ? voteLink(season, match.id) : matchLink(season, match.id),
      home: home ?? ArtTeam(name: match.homeTeam),
      away: away ?? ArtTeam(name: match.awayTeam),
    );
  }

  /// Link sem o "https://" (escrito embaixo do QR).
  String get shortLink => link.replaceFirst(RegExp(r'^https?://'), '');

  @override
  List<Object?> get props => [kind, title, subtitle, link, home, away];
}
