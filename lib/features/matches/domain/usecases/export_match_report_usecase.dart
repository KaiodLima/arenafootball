import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Dados para o PDF da súmula além da partida: o nome da competição (pelo
/// `id_campeonato`, nos campeonatos da região) e os escudos dos times. Pelo
/// cache; sem eles o documento sai do mesmo jeito (só sem o nome/escudos).
class ExportMatchReportUseCase {
  final GetRegionChampionshipsCacheFirstUseCase _getChampionships;
  final GetTeamsCacheFirstUseCase _getTeams;

  ExportMatchReportUseCase(this._getChampionships, this._getTeams);

  /// [championship] vazio = amistoso (sem competição) ou não achou.
  Future<({String championship, String homeCrest, String awayCrest})> call({
    required MatchDTO match,
    required String season,
  }) async {
    var championship = '';
    if (match.championshipId > 0 && match.region.isNotEmpty) {
      final response = await _getChampionships(region: match.region, season: season).last;
      championship = response.fold(
        (_) => '',
        (list) => list.where((c) => c.championshipId == match.championshipId).firstOrNull?.title ?? '',
      );
    }
    final teams = await _getTeams(season: season).last;
    final directory = teams.isRight ? TeamDirectory(teams.right) : TeamDirectory.empty;
    return (
      championship: championship,
      homeCrest: directory.resolve(id: match.homeTeamId, name: match.homeTeam)?.imageUrl ?? '',
      awayCrest: directory.resolve(id: match.awayTeamId, name: match.awayTeam)?.imageUrl ?? '',
    );
  }
}
