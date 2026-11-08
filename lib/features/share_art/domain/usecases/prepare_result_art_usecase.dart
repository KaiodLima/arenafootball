import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Dados do card de resultado: os times (escudo e cores pelo `idTime`) e o
/// nome da competição pelos caches que já existem (sem leitura nova); sem
/// eles, a arte sai do mesmo jeito (substitutos). O link do QR é o card de
/// resultado (página pública, com Open Graph) quando a partida terminou;
/// senão, a página do app.
class PrepareResultArtUseCase {
  final GetTeamsCacheFirstUseCase _getTeams;
  final GetRegionChampionshipsCacheFirstUseCase _getChampionships;

  PrepareResultArtUseCase(this._getTeams, this._getChampionships);

  /// Id do card de resultado (gravado pelas functions ao fim da partida).
  static String resultNewsId(String matchId) => 'resultado_$matchId';

  Future<ResultArtData> call({required MatchDTO match, required String season, DateTime? now}) async {
    final teams = await _getTeams(season: season).last;
    final directory = teams.isRight ? TeamDirectory(teams.right) : TeamDirectory.empty;
    var championship = '';
    var logoUrl = '';
    if (match.championshipId > 0 && match.region.isNotEmpty) {
      final response = await _getChampionships(region: match.region, season: season).last;
      final found =
          response.isRight ? response.right.where((c) => c.championshipId == match.championshipId).firstOrNull : null;
      championship = found?.title ?? '';
      logoUrl = found?.imageUrl ?? '';
    }
    final at = now ?? DateTime.now();
    final finished = ResultArtData.statusOf(match, at) == ArtMatchStatus.finished;
    return ResultArtData.of(
      match,
      homeTeam: directory.resolve(id: match.homeTeamId, name: match.homeTeam),
      awayTeam: directory.resolve(id: match.awayTeamId, name: match.awayTeam),
      championship: championship,
      championshipLogoUrl: logoUrl,
      link: finished && match.id.isNotEmpty ? newsLink(resultNewsId(match.id)) : appLink,
      now: at,
    );
  }
}
