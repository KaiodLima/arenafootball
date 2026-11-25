import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';

/// Fakes do repositório do Fantasy sem cache local (rodadas, posição,
/// histórico e pontuação do atleta): sempre lê o "remoto".
mixin FantasyNoCache {
  Future<Either<Failure, CachedValue<List<FantasyRoundDTO>>?>> getCachedRounds(String fantasyId) async =>
      const Right(null);

  Future<Either<Failure, void>> saveRoundsCache(String fantasyId, List<FantasyRoundDTO> rounds) async =>
      const Right(null);

  Future<Either<Failure, CachedValue<FantasyPositionRecord>?>> getCachedPosition(String fantasyId,
          {int? round, required String uid}) async =>
      const Right(null);

  Future<Either<Failure, void>> savePositionCache(String fantasyId, FantasyPositionRecord record,
          {int? round, required String uid}) async =>
      const Right(null);

  Future<Either<Failure, CachedValue<FantasyRoundRecord>?>> getCachedRoundRecord(
          String fantasyId, int round, String uid) async =>
      const Right(null);

  Future<Either<Failure, void>> saveRoundRecordCache(
          String fantasyId, int round, String uid, FantasyRoundRecord record) async =>
      const Right(null);

  Future<Either<Failure, CachedValue<FantasyAthleteScoreRecord>?>> getCachedAthleteScore(
          String fantasyId, int round, String athleteId) async =>
      const Right(null);

  Future<Either<Failure, void>> saveAthleteScoreCache(
          String fantasyId, int round, String athleteId, FantasyAthleteScoreRecord record) async =>
      const Right(null);
}
