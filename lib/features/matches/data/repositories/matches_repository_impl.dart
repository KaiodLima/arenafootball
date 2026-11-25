import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/match_round.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesDataSource _dataSource;
  final CacheStore _cache;

  MatchesRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) =>
      _dataSource.watchMatches(season: season, region: region);

  @override
  Stream<Either<Failure, MatchDTO?>> watchMatch({required String matchId, String? season}) =>
      _dataSource.watchMatch(matchId: matchId, season: season);

  @override
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) =>
      _invalidate(_dataSource.createMatch(match, season: season));

  @override
  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) =>
      _invalidate(
          _dataSource.updateScore(matchId: matchId, homeGoals: homeGoals, awayGoals: awayGoals, season: season));

  @override
  Future<Either<Failure, void>> updateGoals(
          {required String matchId, required List<MatchGoal> goals, String? season}) =>
      _invalidate(_dataSource.updateGoals(matchId: matchId, goals: goals, season: season));

  @override
  Future<Either<Failure, void>> updateReport(MatchDTO match, {String? season}) => _invalidate(_dataSource.updateReport(
        matchId: match.id,
        bookings: match.bookings,
        substitutions: match.substitutions,
        missedPenalties: match.missedPenalties,
        lineup: match.lineup,
        lineupConfirmed: match.lineupConfirmed,
        stampConfirmation: match.lineupConfirmed && match.lineupConfirmedAt == null,
        formations: match.formations,
        referee: match.referee,
        notes: match.notes,
        date: match.date,
        time: match.time,
        durationMinutes: match.durationMinutes,
        venue: match.venue,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> appendGoal({
    required String matchId,
    required MatchGoal goal,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) =>
      _invalidate(_dataSource.appendGoal(
        matchId: matchId,
        goal: goal,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season}) =>
      _invalidate(_dataSource.setVotingOpen(matchId: matchId, isOpen: isOpen, season: season));

  @override
  Future<Either<Failure, void>> setManualStatus({
    required String matchId,
    required MatchManualStatus status,
    String? stampField,
    List<String> clearFields = const [],
    String? season,
  }) =>
      _invalidate(_dataSource.setManualStatus(
        matchId: matchId,
        status: status,
        stampField: stampField,
        clearFields: clearFields,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> updateMatchInfo({
    required String matchId,
    required String date,
    required String time,
    required int durationMinutes,
    required String venue,
    MatchRound? round,
    bool writeRound = false,
    int? matchday,
    bool writeMatchday = false,
    String? season,
  }) =>
      _invalidate(_dataSource.updateMatchInfo(
        matchId: matchId,
        date: date,
        time: time,
        durationMinutes: durationMinutes,
        venue: venue,
        round: round,
        writeRound: writeRound,
        matchday: matchday,
        writeMatchday: writeMatchday,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> delayMatch({
    required String matchId,
    required String newTime,
    required String originalTime,
    required bool resetClock,
    String? season,
  }) =>
      _invalidate(_dataSource.delayMatch(
        matchId: matchId,
        newTime: newTime,
        originalTime: originalTime,
        resetClock: resetClock,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) =>
      _invalidate(_dataSource.deleteMatch(matchId: matchId, season: season));

  @override
  Future<Either<Failure, List<MatchDTO>>> getElectedMatches({required String playerId, String? season}) =>
      _dataSource.getElectedMatches(playerId: playerId, season: season);

  @override
  Future<Either<Failure, int>> countElectedMatches({required String playerId, String? season}) =>
      _dataSource.countElectedMatches(playerId: playerId, season: season);

  @override
  Future<Either<Failure, CachedValue<List<MatchDTO>>?>> getCachedRegionMatches(
          {required String region, String? season}) =>
      _cache.read(
        CacheKeys.regionMatches(region: region, season: season),
        (json) => [for (final item in json as List) MatchDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveRegionMatchesCache(List<MatchDTO> matches,
          {required String region, String? season}) =>
      _cache.save(CacheKeys.regionMatches(region: region, season: season), [for (final m in matches) m.toCache()]);

  @override
  Future<void> deleteRegionMatchesCache() => _cache.deleteWhere(CacheKeys.isRegionMatchesKey);

  @override
  Future<Either<Failure, CachedValue<List<MatchDTO>>?>> getCachedElectedMatches(
          {required String playerId, String? season}) =>
      _cache.read(
        CacheKeys.electedMatches(playerId: playerId, season: season),
        (json) => [for (final item in json as List) MatchDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveElectedMatchesCache(List<MatchDTO> matches,
          {required String playerId, String? season}) =>
      _cache.save(
        CacheKeys.electedMatches(playerId: playerId, season: season),
        [for (final m in matches) m.toCache()],
      );

  /// Depois de gravar uma partida: o cache das partidas por região fica velho.
  /// Apaga mesmo na falha (gravação na fila offline também muda a partida).
  Future<Either<Failure, void>> _invalidate(Future<Either<Failure, void>> write) async {
    final response = await write;
    await deleteRegionMatchesCache();
    return response;
  }
}
