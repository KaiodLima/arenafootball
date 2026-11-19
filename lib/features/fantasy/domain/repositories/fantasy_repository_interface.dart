import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';

abstract class IFantasyRepository {
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship);

  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config);

  Stream<Either<Failure, List<FantasyConfigDTO>>> watchActive(String season);

  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round);

  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid);

  Future<Either<Failure, void>> join(
    String fantasyId, {
    required String uid,
    required String name,
    required String photoUrl,
    required int currentRound,
  });

  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid);

  Future<Either<Failure, void>> saveLineup(String fantasyId, int round, FantasyLineupDTO lineup);

  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config);

  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config);

  Future<Either<Failure, void>> saveAthletesCache(FantasyConfigDTO config, List<FantasyAthleteDTO> athletes);

  Future<Either<Failure, List<FantasyRankingEntry>>> getRoundRanking(String fantasyId, int round);

  Future<Either<Failure, List<FantasyRankingEntry>>> getOverallRanking(String fantasyId);

  Future<Either<Failure, CachedValue<List<FantasyRankingEntry>>?>> getCachedRanking(String fantasyId, int? round);

  Future<Either<Failure, void>> saveRankingCache(String fantasyId, int? round, List<FantasyRankingEntry> entries);

  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round});

  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId);

  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid);

  Stream<Either<Failure, List<FantasyRoundDTO>>> watchRounds(String fantasyId);

  Future<Either<Failure, List<FantasyParticipantDTO>>> getParticipants(String fantasyId, {DateTime? before});

  Future<Either<Failure, void>> requestRescore(String fantasyId);

  Future<Either<Failure, void>> requestReset(String fantasyId);

  Future<Either<Failure, void>> requestRoundAction(String fantasyId, int round,
      {required bool open, DateTime? deadline});

  Future<Either<Failure, FantasyAthleteScoreDTO?>> getAthleteScore(String fantasyId, int round, String athleteId);

  Future<Either<Failure, List<FantasyAthleteScoreDTO>>> getTopAthletes(String fantasyId, int round);

  Future<Either<Failure, CachedValue<List<FantasyAthleteScoreDTO>>?>> getCachedTopAthletes(String fantasyId, int round);

  Future<Either<Failure, void>> saveTopAthletesCache(String fantasyId, int round, List<FantasyAthleteScoreDTO> list);
}
