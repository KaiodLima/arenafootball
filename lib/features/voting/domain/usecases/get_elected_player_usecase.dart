import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';

/// Apuração de uma partida para a tela do eleito: o ranking dos votados, o
/// eleito com foto, escudo, gols e assistências na temporada, e os escudos
/// dos dois times da partida. Sem votos, `elected` é `null`. Falha ao buscar
/// fotos/escudos/elenco não impede o resultado: a tela só fica sem o dado.
class GetElectedPlayerUseCase {
  final CalculateBestPlayerUseCase _calculateBestPlayer;
  final GetTeamsUseCase _getTeams;
  final WatchTeamPlayersUseCase _watchTeamPlayers;

  GetElectedPlayerUseCase(this._calculateBestPlayer, this._getTeams, this._watchTeamPlayers);

  Future<Either<Failure, VotingResult>> call({
    required String homeTeam,
    required String awayTeam,
    String? season,
  }) async {
    final response = await _calculateBestPlayer(homeTeam: homeTeam, awayTeam: awayTeam);
    if (response.isLeft) return Left(response.left);
    final ranking = response.right;

    final crests = <String, String>{};
    final teams = await _getTeams(season: season);
    if (teams.isRight) {
      for (final team in teams.right) {
        crests.putIfAbsent(team.name, () => team.imageUrl);
      }
    }

    ElectedPlayer? elected;
    if (ranking.isNotEmpty) {
      final winner = ranking.first;
      elected = ElectedPlayer(
        playerName: winner.playerName,
        team: winner.team,
        votes: winner.votes,
        teamImageUrl: crests[winner.team] ?? '',
      );
      if (winner.team.isNotEmpty) {
        final players = await _watchTeamPlayers(teamName: winner.team, season: season).first;
        if (players.isRight) {
          for (final player in players.right) {
            if (player.name == winner.playerName) {
              elected = elected!.copyWith(playerImageUrl: player.imageUrl, goals: player.goals, assists: player.assists);
              break;
            }
          }
        }
      }
    }

    return Right(VotingResult(
      elected: elected,
      ranking: ranking,
      homeCrest: crests[homeTeam] ?? '',
      awayCrest: crests[awayTeam] ?? '',
    ));
  }
}
