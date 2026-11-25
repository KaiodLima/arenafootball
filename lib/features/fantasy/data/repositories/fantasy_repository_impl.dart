import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/datasources/fantasy_datasource.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';

class FantasyRepositoryImpl implements IFantasyRepository {
  final FantasyDataSource _dataSource;
  final CacheStore _cache;

  FantasyRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) =>
      _dataSource.watchConfig(championship);

  @override
  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config) => _dataSource.saveConfig(config);

  @override
  Stream<Either<Failure, List<FantasyConfigDTO>>> watchActive(String season) => _dataSource.watchActive(season);

  @override
  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round) =>
      _dataSource.watchRound(fantasyId, round);

  @override
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) =>
      _dataSource.watchParticipant(fantasyId, uid);

  @override
  Future<Either<Failure, void>> join(
    String fantasyId, {
    required String uid,
    required String name,
    required String photoUrl,
    required int currentRound,
  }) =>
      _dataSource.join(fantasyId, uid: uid, name: name, photoUrl: photoUrl, currentRound: currentRound);

  @override
  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid) =>
      _dataSource.watchLineup(fantasyId, round, uid);

  @override
  Future<Either<Failure, void>> saveLineup(String fantasyId, int round, FantasyLineupDTO lineup) =>
      _dataSource.saveLineup(fantasyId, round, lineup);

  @override
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) =>
      _dataSource.getEligibleAthletes(config);

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config) =>
      _cache.read<List<FantasyAthleteDTO>>(
        CacheKeys.fantasyAthletes(season: config.season, championshipId: config.championshipId),
        (json) => [
          for (final item in json as List) FantasyAthleteDTO.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
      );

  @override
  Future<Either<Failure, void>> saveAthletesCache(FantasyConfigDTO config, List<FantasyAthleteDTO> athletes) =>
      _cache.save(
        CacheKeys.fantasyAthletes(season: config.season, championshipId: config.championshipId),
        [for (final a in athletes) a.toCache()],
      );

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getRoundRanking(String fantasyId, int round) =>
      _dataSource.getRoundRanking(fantasyId, round);

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getOverallRanking(String fantasyId) =>
      _dataSource.getOverallRanking(fantasyId);

  @override
  Future<Either<Failure, CachedValue<List<FantasyRankingEntry>>?>> getCachedRanking(String fantasyId, int? round) =>
      _cache.read<List<FantasyRankingEntry>>(
        CacheKeys.fantasyRanking(fantasyId: fantasyId, round: round),
        (json) => [
          for (final item in json as List) FantasyRankingEntry.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
      );

  @override
  Future<Either<Failure, void>> saveRankingCache(String fantasyId, int? round, List<FantasyRankingEntry> entries) =>
      _cache.save(CacheKeys.fantasyRanking(fantasyId: fantasyId, round: round), [for (final e in entries) e.toCache()]);

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) =>
      _dataSource.countAbove(fantasyId, points, round: round);

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) => _dataSource.getRounds(fantasyId);

  @override
  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid) =>
      _dataSource.getLineup(fantasyId, round, uid);

  @override
  Stream<Either<Failure, List<FantasyRoundDTO>>> watchRounds(String fantasyId) => _dataSource.watchRounds(fantasyId);

  @override
  Future<Either<Failure, List<FantasyParticipantDTO>>> getParticipants(String fantasyId, {DateTime? before}) =>
      _dataSource.getParticipants(fantasyId, before: before);

  @override
  Future<Either<Failure, void>> requestRescore(String fantasyId) async {
    final result = await _dataSource.requestRescore(fantasyId);
    if (result.isRight) await _clearScoring(fantasyId);
    return result;
  }

  @override
  Future<Either<Failure, void>> requestReset(String fantasyId) async {
    final result = await _dataSource.requestReset(fantasyId);
    if (result.isRight) await _clearScoring(fantasyId);
    return result;
  }

  @override
  Future<Either<Failure, void>> requestTeamsReset(String fantasyId, List<String> teamIds) async {
    final result = await _dataSource.requestTeamsReset(fantasyId, teamIds);
    if (result.isRight) await _clearScoring(fantasyId);
    return result;
  }

  @override
  Future<Either<Failure, void>> requestRoundAction(String fantasyId, int round,
      {required bool open, DateTime? deadline}) async {
    final result = await _dataSource.requestRoundAction(fantasyId, round, open: open, deadline: deadline);
    if (result.isRight) await _cache.delete(CacheKeys.fantasyRounds(fantasyId));
    return result;
  }

  @override
  Future<Either<Failure, FantasyAthleteScoreDTO?>> getAthleteScore(String fantasyId, int round, String athleteId) =>
      _dataSource.getAthleteScore(fantasyId, round, athleteId);

  @override
  Future<Either<Failure, List<FantasyAthleteScoreDTO>>> getTopAthletes(String fantasyId, int round) =>
      _dataSource.getTopAthletes(fantasyId, round);

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteScoreDTO>>?>> getCachedTopAthletes(
          String fantasyId, int round) =>
      _cache.read<List<FantasyAthleteScoreDTO>>(
        CacheKeys.fantasyTopAthletes(fantasyId: fantasyId, round: round),
        (json) => [
          for (final item in json as List) FantasyAthleteScoreDTO.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
      );

  @override
  Future<Either<Failure, void>> saveTopAthletesCache(String fantasyId, int round, List<FantasyAthleteScoreDTO> list) =>
      _cache
          .save(CacheKeys.fantasyTopAthletes(fantasyId: fantasyId, round: round), [for (final a in list) a.toCache()]);

  /// Pedido de reapuração/reinício: rodadas, posições, histórico e pontuações
  /// do Fantasy saem do cache (as rodadas reapuradas também mudam de versão).
  Future<void> _clearScoring(String fantasyId) =>
      _cache.deleteWhere((key) => CacheKeys.isFantasyScoringKey(key, fantasyId));

  @override
  Future<Either<Failure, CachedValue<List<FantasyRoundDTO>>?>> getCachedRounds(String fantasyId) =>
      _cache.read<List<FantasyRoundDTO>>(
        CacheKeys.fantasyRounds(fantasyId),
        (json) => [for (final item in json as List) FantasyRoundDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveRoundsCache(String fantasyId, List<FantasyRoundDTO> rounds) =>
      _cache.save(CacheKeys.fantasyRounds(fantasyId), [for (final r in rounds) r.toCache()]);

  @override
  Future<Either<Failure, CachedValue<FantasyPositionRecord>?>> getCachedPosition(String fantasyId,
          {int? round, required String uid}) =>
      _cache.read<FantasyPositionRecord>(
        CacheKeys.fantasyPosition(fantasyId: fantasyId, round: round, uid: uid),
        (json) => FantasyPositionRecord.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> savePositionCache(String fantasyId, FantasyPositionRecord record,
          {int? round, required String uid}) =>
      _cache.save(CacheKeys.fantasyPosition(fantasyId: fantasyId, round: round, uid: uid), record.toCache());

  @override
  Future<Either<Failure, CachedValue<FantasyRoundRecord>?>> getCachedRoundRecord(
          String fantasyId, int round, String uid) =>
      _cache.read<FantasyRoundRecord>(
        CacheKeys.fantasyHistory(fantasyId: fantasyId, round: round, uid: uid),
        (json) => FantasyRoundRecord.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveRoundRecordCache(
          String fantasyId, int round, String uid, FantasyRoundRecord record) =>
      _cache.save(CacheKeys.fantasyHistory(fantasyId: fantasyId, round: round, uid: uid), record.toCache());

  @override
  Future<Either<Failure, CachedValue<FantasyAthleteScoreRecord>?>> getCachedAthleteScore(
          String fantasyId, int round, String athleteId) =>
      _cache.read<FantasyAthleteScoreRecord>(
        CacheKeys.fantasyAthleteScore(fantasyId: fantasyId, round: round, athleteId: athleteId),
        (json) => FantasyAthleteScoreRecord.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveAthleteScoreCache(
          String fantasyId, int round, String athleteId, FantasyAthleteScoreRecord record) =>
      _cache.save(
          CacheKeys.fantasyAthleteScore(fantasyId: fantasyId, round: round, athleteId: athleteId), record.toCache());
}
