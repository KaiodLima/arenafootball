import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';

/// Melhor jogador eleito de uma partida, com a foto do jogador e o escudo do
/// time da temporada. Sem votos devolve `null`. Falha ao buscar foto/escudo
/// não impede o resultado: a tela só fica sem a imagem.
class GetElectedPlayerUseCase {
  final CalculateBestPlayerUseCase _calculateBestPlayer;
  final GetTeamsUseCase _getTeams;
  final WatchTeamPlayersUseCase _watchTeamPlayers;

  GetElectedPlayerUseCase(this._calculateBestPlayer, this._getTeams, this._watchTeamPlayers);

  Future<Either<Failure, ElectedPlayer?>> call({
    required String homeTeam,
    required String awayTeam,
    String? season,
  }) async {
    final response = await _calculateBestPlayer(homeTeam: homeTeam, awayTeam: awayTeam);
    if (response.isLeft) return Left(response.left);
    final elected = response.right;
    if (elected == null || elected.team.isEmpty) return Right(elected);

    var teamImageUrl = '';
    final teams = await _getTeams(season: season);
    if (teams.isRight) {
      for (final team in teams.right) {
        if (team.name == elected.team) {
          teamImageUrl = team.imageUrl;
          break;
        }
      }
    }

    var playerImageUrl = '';
    final players = await _watchTeamPlayers(teamName: elected.team, season: season).first;
    if (players.isRight) {
      for (final player in players.right) {
        if (player.name == elected.playerName) {
          playerImageUrl = player.imageUrl;
          break;
        }
      }
    }

    return Right(elected.copyWith(playerImageUrl: playerImageUrl, teamImageUrl: teamImageUrl));
  }
}
