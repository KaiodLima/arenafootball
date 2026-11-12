import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/share_art/domain/player_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';

/// Dados da arte "atleta na partida": o atleta ([player], com o time dele já
/// resolvido) e a partida que vai acontecer ([match], a mesma preparação da
/// divulgação), com o lado do atleta e o adversário.
class PlayerMatchArtData extends Equatable {
  final PlayerArtData player;
  final ResultArtData match;
  final MatchSide side;

  const PlayerMatchArtData({required this.player, required this.match, required this.side});

  /// O time do atleta e o adversário (pela partida).
  ArtTeam get team => side == MatchSide.home ? match.home : match.away;
  ArtTeam get opponent => side == MatchSide.home ? match.away : match.home;

  /// Monta pelo atleta: o time do lado dele, a competição da partida (nome,
  /// logo e os números dela; amistoso = os de amistoso) e o link do atleta.
  factory PlayerMatchArtData.of({
    required PlayerDTO player,
    required ResultArtData match,
    required MatchSide side,
    required int championshipId,
    required String season,
  }) {
    final enrollment = championshipId > 0 ? player.enrollmentIn(championshipId) : null;
    final friendly = championshipId <= 0;
    // Atleta antigo (sem inscrições) não tem número por competição: o geral.
    final goals = friendly ? player.friendlyGoals : (enrollment?.goals ?? (player.isLegacy ? player.goals : 0));
    final assists = friendly ? player.friendlyAssists : (enrollment?.assists ?? (player.isLegacy ? player.assists : 0));
    final team = side == MatchSide.home ? match.home : match.away;
    return PlayerMatchArtData(
      side: side,
      match: match,
      player: PlayerArtData(
        name: player.name,
        photoUrl: player.imageUrl.trim(),
        positionKey: player.position,
        team: team,
        championship: match.championship,
        championshipLogoUrl: match.championshipLogoUrl,
        goals: goals,
        assists: assists,
        link: player.id.isEmpty ? appLink : athleteLink(season, player.id),
      ),
    );
  }

  @override
  List<Object?> get props => [player, match, side];
}
