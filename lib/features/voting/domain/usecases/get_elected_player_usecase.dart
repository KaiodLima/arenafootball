import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';

/// Apuração de uma partida para a tela do eleito: o ranking dos votados, o
/// eleito com foto, escudo, gols e assistências na temporada, e os escudos
/// e as cores dos dois times da partida. Sem votos, `elected` é `null`. Falha ao buscar
/// fotos/escudos/elenco não impede o resultado: a tela só fica sem o dado.
class GetElectedPlayerUseCase {
  final CalculateBestPlayerUseCase _calculateBestPlayer;
  final GetTeamsUseCase _getTeams;
  final WatchTeamPlayersUseCase _watchTeamPlayers;

  GetElectedPlayerUseCase(this._calculateBestPlayer, this._getTeams, this._watchTeamPlayers);

  Future<Either<Failure, VotingResult>> call(MatchVoteRef ref) async {
    final season = ref.season;
    final response = await _calculateBestPlayer(ref);
    if (response.isLeft) return Left(response.left);
    final ranking = response.right;

    final teams = await _getTeams(season: season);
    final directory = teams.isRight ? TeamDirectory(teams.right) : TeamDirectory.empty;
    final home = directory.resolve(id: ref.homeTeamId, name: ref.homeTeam);
    final away = directory.resolve(id: ref.awayTeamId, name: ref.awayTeam);

    ElectedPlayer? elected;
    if (ranking.isNotEmpty) {
      final winner = ranking.first;
      final winnerTeam = directory.resolve(id: winner.teamId, name: winner.team);
      elected = ElectedPlayer(
        playerName: winner.playerName,
        team: winner.team,
        teamId: winnerTeam?.id ?? winner.teamId,
        votes: winner.votes,
        teamImageUrl: winnerTeam?.imageUrl ?? '',
      );
      if (winner.team.isNotEmpty) {
        final players =
            await _watchTeamPlayers(teamId: winnerTeam?.id ?? '', teamName: winner.team, season: season).first;
        if (players.isRight) {
          for (final player in players.right) {
            if (player.name == winner.playerName) {
              elected =
                  elected!.copyWith(playerImageUrl: player.imageUrl, goals: player.goals, assists: player.assists);
              break;
            }
          }
        }
      }
    }

    return Right(VotingResult(
      elected: elected,
      ranking: ranking,
      homeCrest: home?.imageUrl ?? '',
      awayCrest: away?.imageUrl ?? '',
      homePrimaryColor: home?.primaryColor ?? '',
      homeSecondaryColor: home?.secondaryColor ?? '',
      awayPrimaryColor: away?.primaryColor ?? '',
      awaySecondaryColor: away?.secondaryColor ?? '',
    ));
  }
}
