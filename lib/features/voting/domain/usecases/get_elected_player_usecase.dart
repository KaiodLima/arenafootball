import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_voting_rules_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/domain/voting_outcome.dart';

/// Apuração de uma partida para a tela do eleito: o ranking dos votados (sem
/// os votos em si mesmo), o resultado pelas regras da votação
/// ([VotingOutcome]: mínimo de votos, porcentagem e vantagem sobre o 2º), o
/// eleito com foto, escudo, gols e assistências na temporada (só quando a
/// votação vale) e os escudos e as cores dos dois times. Falha ao buscar
/// fotos/escudos/elenco/regras não impede o resultado: fica sem o dado (regras
/// = os padrões).
class GetElectedPlayerUseCase {
  final CalculateBestPlayerUseCase _calculateBestPlayer;
  final GetTeamsCacheFirstUseCase _getTeams;
  final WatchTeamPlayersUseCase _watchTeamPlayers;
  final GetVotingRulesCacheFirstUseCase _getRules;

  GetElectedPlayerUseCase(this._calculateBestPlayer, this._getTeams, this._watchTeamPlayers, this._getRules);

  Future<List<PlayerDTO>> _squad(String teamId, String teamName, String? season) async {
    if (teamId.isEmpty && teamName.trim().isEmpty) return const [];
    final response = await _watchTeamPlayers(teamId: teamId, teamName: teamName, season: season).first;
    return response.fold((_) => const [], (list) => list);
  }

  Future<Either<Failure, VotingResult>> call(MatchVoteRef ref) async {
    final season = ref.season;

    // Times pelo cache local: a última emissão (o remoto quando revalidou).
    final teams = await _getTeams(season: season).last;
    final directory = teams.isRight ? TeamDirectory(teams.right) : TeamDirectory.empty;
    final home = directory.resolve(id: ref.homeTeamId, name: ref.homeTeam);
    final away = directory.resolve(id: ref.awayTeamId, name: ref.awayTeam);

    final squads = [
      ...await _squad(home?.id ?? ref.homeTeamId, ref.homeTeam, season),
      ...await _squad(away?.id ?? ref.awayTeamId, ref.awayTeam, season),
    ];
    final response = await _calculateBestPlayer(ref, players: squads);
    if (response.isLeft) return Left(response.left);
    final ranking = response.right;

    final rules = (await _getRules().last).fold((_) => const VotingRulesDTO(), (rules) => rules);
    final outcome = VotingOutcome.evaluate(ranking, rules);

    ElectedPlayer? elected;
    if (outcome.isValid) {
      final winner = ranking.first;
      final winnerTeam = directory.resolve(id: winner.teamId, name: winner.team);
      elected = ElectedPlayer(
        playerName: winner.playerName,
        team: winner.team,
        teamId: winnerTeam?.id ?? winner.teamId,
        votes: winner.votes,
        teamImageUrl: winnerTeam?.imageUrl ?? '',
      );
      var players = squads;
      if (!players.any((p) => p.name == winner.playerName) && winner.team.isNotEmpty) {
        players = await _squad(winnerTeam?.id ?? '', winner.team, season);
      }
      for (final player in players) {
        if (player.name == winner.playerName) {
          elected = elected!.copyWith(playerImageUrl: player.imageUrl, goals: player.goals, assists: player.assists);
          break;
        }
      }
    }

    return Right(VotingResult(
      elected: elected,
      outcome: outcome,
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
