import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_in_championship_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_usecase.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Ranking de artilharia/assistências de uma região na temporada (ou, com
/// `championshipId`, de uma competição: os números da inscrição, com o time
/// pelo qual o atleta joga nela).
///
/// Busca só os [limit] melhores no quesito entre os times da região (consulta
/// por `idTime`, ordenada e limitada no servidor), em vez de todos os
/// jogadores da temporada. Quem fica de fora do top não tem posição.
///
/// Regra (a mesma do app antigo):
/// - só entram jogadores de um time da região (pelo `idTime`; jogador antigo
///   sem id só entra depois da manutenção "Vincular times por id");
/// - quem tem 0 no quesito não aparece;
/// - ordem decrescente pelo quesito; empate mantém a ordem em que os
///   jogadores vieram do Firestore (não há critério de desempate), e os
///   empatados dividem a posição.
class GetStatsRankingUseCase {
  final GetTeamsCacheFirstUseCase _getTeams;
  final GetTopPlayersUseCase _getTopPlayers;
  final GetTopPlayersInChampionshipUseCase? _getTopInChampionship;

  /// Tamanho do ranking (por quesito).
  static const int limit = 50;

  GetStatsRankingUseCase(this._getTeams, this._getTopPlayers, [this._getTopInChampionship]);

  Future<Either<Failure, StatsRanking>> call({
    required StatsRankingType type,
    required String region,
    String? season,
    int? championshipId,
  }) async {
    // Times pelo cache local: a última emissão (o remoto quando revalidou).
    final teams = await _getTeams(region: region, season: season).last;
    if (teams.isLeft) return Left(teams.left);
    final teamIds = [
      for (final team in teams.right)
        if (team.id.isNotEmpty) team.id,
    ];
    final inChampionship = _getTopInChampionship;
    final byChampionship = championshipId != null && inChampionship != null;
    final response = byChampionship
        ? await inChampionship(championshipId: championshipId, field: type.field, limit: limit, season: season)
        : await _getTopPlayers(teamIds: teamIds, field: type.field, limit: limit, season: season);
    if (response.isLeft) return Left(response.left);
    // Na competição, o atleta aparece pelo time e pelos números dela.
    final players = byChampionship
        ? [
            for (final player in response.right)
              if (player.enrollmentIn(championshipId) case final e?)
                player.copyWith(team: e.team, teamId: e.teamId, goals: e.goals, assists: e.assists),
          ]
        : response.right;

    // Rede de segurança: só jogadores de um time da região (a consulta já filtra pelo id).
    final directory = TeamDirectory(teams.right);
    final ranked = players
        .where((player) => directory.resolve(id: player.teamId, name: player.team) != null && type.valueOf(player) > 0)
        .toList();

    // Ordenação estável: o índice original desempata.
    final indexed = ranked.asMap().entries.toList()
      ..sort((a, b) {
        final byValue = type.valueOf(b.value).compareTo(type.valueOf(a.value));
        return byValue != 0 ? byValue : a.key.compareTo(b.key);
      });
    final sorted = indexed.map((entry) => entry.value).toList();
    return Right(StatsRanking(
      entries: buildRanking(sorted, type),
      crests: {
        for (final team in teams.right)
          if (team.imageUrl.isNotEmpty) team.name: team.imageUrl,
      },
    ));
  }
}
