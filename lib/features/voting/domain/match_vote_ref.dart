import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

/// Partida da votação: os votos ficam em `partidas{season}/{matchId}/votos`.
/// Os nomes dos times servem à coleção antiga `melhorjogador{timeC}{timeF}`,
/// ainda lida (votos de antes e de versões antigas do app); os ids, para
/// achar escudos e elencos.
class MatchVoteRef extends Equatable {
  final String matchId;
  final String season;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamId;
  final String awayTeamId;

  const MatchVoteRef({
    required this.matchId,
    required this.season,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamId = '',
    this.awayTeamId = '',
  });

  factory MatchVoteRef.of(MatchDTO match, String season) => MatchVoteRef(
        matchId: match.id,
        season: season,
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
      );

  @override
  List<Object?> get props => [matchId, season, homeTeam, awayTeam, homeTeamId, awayTeamId];
}
