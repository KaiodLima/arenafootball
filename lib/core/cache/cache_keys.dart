import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';

/// Chaves do cache local. Temporada nula = a atual (pelo ano, para a troca de
/// temporada não reaproveitar o cache da anterior); região pelo id (o nome
/// pode mudar) e, sem id conhecido, pelo nome.
abstract final class CacheKeys {
  static const String regions = 'regions_cache';
  static const String seasonsConfig = 'seasons_config_cache';

  static const String _teamsPrefix = 'teams_';
  static const String _teamPrefix = 'team_';

  /// Times da [season] na [region] (nula/vazia = todas).
  static String teams({String? region, String? season}) => '$_teamsPrefix${_season(season)}_${_region(region)}_cache';

  /// Um time da [season] pelo id (ou, sem id, pelo nome).
  static String team({required String idOrName, String? season}) =>
      '$_teamPrefix${_season(season)}_${idOrName.trim()}_cache';

  /// Usuário da sessão.
  static String user(String uid) => 'user_${uid}_cache';

  /// Chaves de times (lista e time avulso): apagar depois de gravar um time.
  static bool isTeamKey(String key) => key.startsWith(_teamsPrefix) || key.startsWith(_teamPrefix);

  /// Todos os destaques (visíveis ou não).
  static const String highlights = 'highlights_cache';

  static const String _championshipPrefix = 'championship';

  /// Campeonatos da [region] na [season].
  static String championships({required String region, String? season}) =>
      '${_championshipPrefix}s_${_season(season)}_${_region(region)}_cache';

  /// O campeonato "da região" na [season] (o usado ao cadastrar partida).
  static String championship({required String region, String? season}) =>
      '${_championshipPrefix}_${_season(season)}_${_region(region)}_cache';

  /// Chaves de campeonatos (lista e avulso): apagar depois de gravar um.
  static bool isChampionshipKey(String key) => key.startsWith(_championshipPrefix);

  static const String _rankingPrefix = 'ranking_';

  /// Ranking ([type] = nome do quesito) da [region] na [season].
  static String ranking({required String type, required String region, String? season}) =>
      '$_rankingPrefix${type}_${_season(season)}_${_region(region)}_cache';

  /// Chaves de ranking: apagar depois de mexer nos números de um jogador.
  static bool isRankingKey(String key) => key.startsWith(_rankingPrefix);

  static const String _goalCardsPrefix = 'goalcards_';

  /// Cards de gol em que o jogador marcou ou deu o passe.
  static String goalCards(String playerId) => '$_goalCardsPrefix${playerId}_cache';

  /// Chaves dos cards de gol por jogador: apagar depois de criar/apagar notícia.
  static bool isGoalCardsKey(String key) => key.startsWith(_goalCardsPrefix);

  /// Uma notícia pelo id (deep link).
  static String news(String id) => 'news_${id}_cache';

  /// Resultados pelo mundo do [day] (ontem/hoje/amanhã) na [date] local: o
  /// "ontem" de hoje não é o de amanhã.
  static String globalResults({required String day, required DateTime date}) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'global_results_${day}_${date.year}-${two(date.month)}-${two(date.day)}_cache';
  }

  /// Gols de um jogo encerrado pela URL da página de análise.
  static String matchGoals(String url) {
    final id = url.replaceAll(RegExp(r'^https?://(www\.)?'), '').replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    // Chave do Hive tem limite de 255 caracteres.
    return 'match_goals_${id.length > 200 ? id.substring(id.length - 200) : id}_cache';
  }

  /// Chaves dos resultados pelo mundo (dias e gols).
  static bool isGlobalResultsKey(String key) => key.startsWith('global_results_') || key.startsWith('match_goals_');

  /// Votos da partida [matchId] na [season] (resultado de votação encerrada).
  static String votes({required String matchId, String? season}) => 'votes_${_season(season)}_${matchId}_cache';

  /// Ranking de torcidas da [season] (doc da function, todas as regiões).
  static String fanRanking(String season) => 'fan_ranking_${_season(season)}_cache';

  static String _season(String? season) => (season == null || season.isEmpty) ? SeasonCollection.currentSeason : season;

  static String _region(String? region) {
    final name = region?.trim() ?? '';
    if (name.isEmpty) return 'all';
    final id = RegionRegistry.idOf(name);
    return id.isNotEmpty ? id : name;
  }
}
