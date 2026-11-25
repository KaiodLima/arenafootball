import 'package:arena_soccer/core/firebase/season_collection.dart';

/// Validade de cada dado no cache local. Dentro dela o app mostra o cache e
/// não lê o Firestore; vencido, mostra o cache e revalida.
abstract final class CacheTtl {
  static const Duration regions = Duration(hours: 24);
  static const Duration seasonsConfig = Duration(hours: 24);

  /// Regras da votação (o admin muda raramente).
  static const Duration votingRules = Duration(hours: 1);
  static const Duration teams = Duration(minutes: 30);
  static const Duration championships = Duration(minutes: 30);
  static const Duration groups = Duration(minutes: 30);
  static const Duration standings = Duration(minutes: 30);
  static const Duration highlights = Duration(minutes: 15);
  static const Duration ranking = Duration(minutes: 10);

  /// Ranking de torcidas (o servidor recalcula de hora em hora).
  static const Duration fanRanking = Duration(minutes: 30);

  /// Atletas elegíveis no Arena Fantasy (inscrições mudam pouco).
  static const Duration fantasyAthletes = Duration(minutes: 30);

  /// Arena Fantasy: rodadas e a posição da conta (as functions apuram).
  static const Duration fantasyRounds = Duration(minutes: 10);
  static const Duration fantasyPosition = Duration(minutes: 10);

  /// Arena Fantasy: histórico da rodada fechada e pontuação do atleta na
  /// rodada apurada (reapurar muda a versão e vence antes).
  static const Duration fantasyScored = Duration(hours: 24);
  static const Duration globalResults = Duration(minutes: 5);

  /// Apuração de votação encerrada (lida só depois de fechar).
  static const Duration votes = Duration(minutes: 1);

  /// Usuário da sessão (admin/time mudados em outro aparelho aparecem em até
  /// 30 min; as gravações do próprio app atualizam na hora).
  static const Duration user = Duration(minutes: 30);

  /// Aviso de atualização (`config/versao`).
  static const Duration appVersion = Duration(hours: 6);

  /// Partidas da região em leitura única (perfil, bolão, QR, card de gol...).
  static const Duration regionMatches = Duration(minutes: 3);

  /// Eventos de votação abertos (QR codes, "Acontecendo agora").
  static const Duration openEvents = Duration(minutes: 3);

  /// Ranking de colecionadores do álbum (as functions gravam a cada pacote).
  static const Duration albumRanking = Duration(minutes: 10);

  /// Catálogo de conquistas (o admin muda raramente).
  static const Duration achievementsCatalog = Duration(hours: 12);

  /// Bolão: ranking (top 50, a linha e a posição da conta), os palpites da
  /// conta e a contagem de palpites da partida (as functions pontuam depois).
  static const Duration predictionRanking = Duration(minutes: 10);
  static const Duration myPredictions = Duration(minutes: 10);
  static const Duration predictionCount = Duration(minutes: 10);

  /// Perfil do atleta (troféus e histórico): temporada atual muda; as
  /// passadas, quase nunca.
  static const Duration currentSeasonProfile = Duration(minutes: 10);
  static const Duration pastSeasonProfile = Duration(hours: 24);

  /// Validade do perfil do atleta na [season] (nula/vazia = a atual).
  static Duration profileFor(String? season) =>
      (season == null || season.isEmpty || season == SeasonCollection.currentSeason)
          ? currentSeasonProfile
          : pastSeasonProfile;

  /// Sempre revalida (o cache só abre o app sem rede).
  static const Duration alwaysRevalidate = Duration.zero;
}
