import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
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

  /// Nomes (minúsculos) de quem participou da partida por time; nulo = sem
  /// escalação (todos do elenco valem). Voto em quem não jogou não conta.
  final Set<String>? homeParticipants;
  final Set<String>? awayParticipants;

  const MatchVoteRef({
    required this.matchId,
    required this.season,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamId = '',
    this.awayTeamId = '',
    this.homeParticipants,
    this.awayParticipants,
  });

  /// O voto em [playerName] pelo time [teamId]/[team] vale? (participou ou o
  /// time não tem escalação).
  bool isEligible({required String playerName, String teamId = '', String team = ''}) {
    final home = (teamId.isNotEmpty && teamId == homeTeamId) || (teamId.isEmpty && team == homeTeam);
    final away = (teamId.isNotEmpty && teamId == awayTeamId) || (teamId.isEmpty && team == awayTeam);
    final names = home ? homeParticipants : (away ? awayParticipants : null);
    return names == null || names.contains(playerName.trim().toLowerCase());
  }

  factory MatchVoteRef.of(MatchDTO match, String season) => MatchVoteRef(
        matchId: match.id,
        season: season,
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
        homeParticipants: MatchReport.participantNames(match, MatchSide.home),
        awayParticipants: MatchReport.participantNames(match, MatchSide.away),
      );

  @override
  List<Object?> get props => [matchId, season, homeTeam, awayTeam, homeTeamId, awayTeamId];
}
