import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/firebase/test_content.dart';

/// Chaves do cache local. Temporada nula = a atual (pelo ano, para a troca de
/// temporada não reaproveitar o cache da anterior); região pelo id (o nome
/// pode mudar) e, sem id conhecido, pelo nome.
abstract final class CacheKeys {
  static const String regions = 'regions_cache';
  static const String seasonsConfig = 'seasons_config_cache';
  static const String votingRules = 'voting_rules_cache';

  /// Versões exigidas pelo admin (`config/versao`).
  static const String appVersion = 'app_version_cache';

  /// Catálogo de conquistas (`conquistas`).
  static const String achievementsCatalog = 'achievements_catalog_cache';

  static const String _teamsPrefix = 'teams_';
  static const String _teamPrefix = 'team_';

  /// Times da [season] na [region] (nula/vazia = todas).
  static String teams({String? region, String? season}) => '$_teamsPrefix${_season(season)}_${_region(region)}_cache';

  /// Um time da [season] pelo id (ou, sem id, pelo nome).
  static String team({required String idOrName, String? season}) =>
      '$_teamPrefix${_season(season)}_${idOrName.trim()}_cache';

  /// Código de convite (já conferido/criado) da conta [uid].
  static String referralCode(String uid) => 'referral_code_${uid}_cache';

  /// Índices `campeonatos_org` já conferidos do organizador [uid].
  static String organizerIndexes(String uid) => 'organizer_indexes_${uid}_cache';

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

  /// Competições da [season] de todas as regiões.
  static String seasonChampionships({String? season}) => '${_championshipPrefix}s_season_${_season(season)}_cache';

  /// Chaves de campeonatos (lista e avulso): apagar depois de gravar um.
  static bool isChampionshipKey(String key) => key.startsWith(_championshipPrefix);

  static const String _rankingPrefix = 'ranking_';

  /// Ranking ([type] = nome do quesito) da [region] na [season]; com
  /// [championshipId], o da competição.
  static String ranking({required String type, required String region, String? season, int? championshipId}) =>
      '$_rankingPrefix${type}_${_season(season)}_${_region(region)}${championshipId == null ? '' : '_c$championshipId'}_cache';

  /// Chaves de ranking: apagar depois de mexer nos números de um jogador.
  static bool isRankingKey(String key) => key.startsWith(_rankingPrefix);

  static const String _goalCardsPrefix = 'goalcards_';

  /// Cards de gol em que o jogador marcou ou deu o passe.
  static String goalCards(String playerId) => '$_goalCardsPrefix${playerId}_cache';

  /// Chaves dos cards de gol por jogador: apagar depois de criar/apagar notícia.
  static bool isGoalCardsKey(String key) => key.startsWith(_goalCardsPrefix);

  /// Eventos de votação abertos (a mesma consulta para todas as regiões; a
  /// região é filtrada no app).
  static const String openEvents = 'open_events_cache';

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

  /// Atletas elegíveis no Arena Fantasy da competição [championshipId].
  static String fantasyAthletes({String? season, required int championshipId}) =>
      'fantasy_athletes_${_season(season)}_c${championshipId}_cache';

  /// "Craques da rodada": atletas que mais pontuaram na rodada [round].
  static String fantasyTopAthletes({required String fantasyId, required int round}) =>
      'fantasy_top_athletes_${fantasyId}_${round}_cache';

  /// Ranking do Arena Fantasy [fantasyId]: da rodada [round] ou geral (nula).
  static String fantasyRanking({required String fantasyId, int? round}) =>
      'fantasy_ranking_${fantasyId}_${round ?? 'geral'}_cache';

  /// Rodadas do Arena Fantasy [fantasyId].
  static String fantasyRounds(String fantasyId) => 'fantasy_rounds_${fantasyId}_cache';

  /// Posição da conta [uid] no Fantasy [fantasyId]: na rodada [round] ou no
  /// geral (nula), com os pontos de quando foi calculada.
  static String fantasyPosition({required String fantasyId, int? round, required String uid}) =>
      'fantasy_position_${fantasyId}_${round ?? 'geral'}_${uid}_cache';

  /// Histórico da conta [uid] numa rodada fechada (escalação + posição).
  static String fantasyHistory({required String fantasyId, required int round, required String uid}) =>
      'fantasy_history_${fantasyId}_${round}_${uid}_cache';

  /// Pontuação detalhada do atleta [athleteId] na rodada apurada [round].
  static String fantasyAthleteScore({required String fantasyId, required int round, required String athleteId}) =>
      'fantasy_score_${fantasyId}_${round}_${athleteId}_cache';

  /// Chaves de rodadas, posições, histórico e pontuação do Fantasy
  /// [fantasyId]: apagar depois de pedir reapuração/reinício.
  static bool isFantasyScoringKey(String key, String fantasyId) =>
      key == fantasyRounds(fantasyId) ||
      key.startsWith('fantasy_position_${fantasyId}_') ||
      key.startsWith('fantasy_history_${fantasyId}_') ||
      key.startsWith('fantasy_score_${fantasyId}_');

  static const String _albumRankingPrefix = 'album_ranking_';

  /// Ranking de colecionadores do evento [eventId] visto pela conta [uid]
  /// (top 50 + a linha e a posição dela).
  static String albumRanking({required String eventId, required String uid}) =>
      '$_albumRankingPrefix${eventId}_${uid}_cache';

  /// Chaves do ranking do álbum do evento [eventId].
  static bool isAlbumRankingKey(String key, String eventId) => key.startsWith('$_albumRankingPrefix${eventId}_');

  static const String _regionMatchesPrefix = 'region_matches_';

  /// Partidas da [region] na [season] (leitura única). A conta admin (que vê
  /// as partidas de teste) tem a chave dela, para não mostrar teste a outro.
  static String regionMatches({required String region, String? season}) =>
      '$_regionMatchesPrefix${_season(season)}_${_region(region)}${TestContent.visible ? '_t' : ''}_cache';

  /// Chaves das partidas por região: apagar depois de gravar uma partida.
  static bool isRegionMatchesKey(String key) => key.startsWith(_regionMatchesPrefix);

  /// Top 50 do bolão da região [regionId] na [season] (todas as contas).
  static String predictionRanking({required String regionId, String? season}) =>
      'prediction_ranking_${_season(season)}_${regionId}_cache';

  /// Linha e posição da conta [uid] no bolão da região (fora do top 50).
  static String predictionStanding({required String regionId, required String uid, String? season}) =>
      'prediction_standing_${_season(season)}_${regionId}_${uid}_cache';

  /// Palpite da conta [uid] na partida [matchId] (nulo salvo = sem palpite).
  static String myPrediction({required String matchId, required String uid, String? season}) =>
      'my_prediction_${_season(season)}_${matchId}_${uid}_cache';

  /// Quantas pessoas palpitaram na partida [matchId].
  static String predictionCount({required String matchId, String? season}) =>
      'prediction_count_${_season(season)}_${matchId}_cache';

  /// Partidas em que o atleta [playerId] foi o craque na [season] (troféus).
  static String electedMatches({required String playerId, String? season}) =>
      'elected_matches_${_season(season)}_${playerId}_cache';

  static const String _playerSeasonPrefix = 'player_season_';

  /// Histórico do atleta da conta [userId] na [season] (cadastro + troféus).
  static String playerSeason({required String userId, String? season}) =>
      '$_playerSeasonPrefix${_season(season)}_${userId}_cache';

  /// Chaves do histórico por temporada: apagar depois de gravar um jogador.
  static bool isPlayerSeasonKey(String key) => key.startsWith(_playerSeasonPrefix);

  static String _season(String? season) => (season == null || season.isEmpty) ? SeasonCollection.currentSeason : season;

  static String _region(String? region) {
    final name = region?.trim() ?? '';
    if (name.isEmpty) return 'all';
    final id = RegionRegistry.idOf(name);
    return id.isNotEmpty ? id : name;
  }
}
