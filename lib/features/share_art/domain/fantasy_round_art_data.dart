import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Dados da arte dos "Craques da rodada" do Arena Fantasy (sem leitura: tudo
/// vem do card do feed). O link leva quem vê a arte ao Fantasy do campeonato.
class FantasyRoundArtData extends Equatable {
  final String newsId;
  final int round;
  final String championship;
  final String logoUrl;

  /// Os 3 de maior pontuação, na ordem (empate = mesma colocação).
  final List<FantasyNewsAthlete> athletes;

  /// `/fantasy/<idDocCampeonato>` (QR e texto de compartilhar); vazio = sem o campeonato.
  final String link;

  const FantasyRoundArtData({
    this.newsId = '',
    this.round = 0,
    this.championship = '',
    this.logoUrl = '',
    this.athletes = const [],
    this.link = '',
  });

  factory FantasyRoundArtData.of(NewsDTO news) {
    final athletes = [...news.fantasyAthletes]..sort((a, b) {
        final byRank = a.rank.compareTo(b.rank);
        return byRank != 0 ? byRank : b.points.compareTo(a.points);
      });
    return FantasyRoundArtData(
      newsId: news.id,
      round: news.fantasyRound,
      championship: news.championshipTitle,
      logoUrl: news.imageUrl,
      athletes: athletes.take(3).toList(),
      link: news.championshipDocId.isEmpty ? '' : fantasyLink(news.championshipDocId),
    );
  }

  /// "25", "12,5" (vírgula, sem casas à toa).
  static String pointsText(double points) {
    final rounded = (points * 10).round() / 10;
    final text = rounded == rounded.truncateToDouble() ? rounded.toInt().toString() : rounded.toString();
    return text.replaceAll('.', ',');
  }

  @override
  List<Object?> get props => [newsId, round, championship, logoUrl, athletes, link];
}
