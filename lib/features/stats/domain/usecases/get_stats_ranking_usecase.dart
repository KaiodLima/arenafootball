import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_players_usecase.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Ranking de artilharia/assistências de uma região na temporada.
///
/// Regra (a mesma do app antigo):
/// - só entram jogadores cujo `time` é o nome de um time da região;
/// - quem tem 0 no quesito não aparece;
/// - ordem decrescente pelo quesito; empate mantém a ordem em que os
///   jogadores vieram do Firestore (não há critério de desempate), e os
///   empatados dividem a posição.
class GetStatsRankingUseCase {
  final GetTeamsUseCase _getTeams;
  final GetPlayersUseCase _getPlayers;

  GetStatsRankingUseCase(this._getTeams, this._getPlayers);

  Future<Either<Failure, StatsRanking>> call({
    required StatsRankingType type,
    required String region,
    String? season,
  }) async {
    final teams = await _getTeams(region: region, season: season);
    if (teams.isLeft) return Left(teams.left);
    final players = await _getPlayers(season: season);
    if (players.isLeft) return Left(players.left);

    final teamNames = teams.right.map((team) => team.name).toSet();
    final ranked = players.right
        .where((player) => teamNames.contains(player.team) && type.valueOf(player) > 0)
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
