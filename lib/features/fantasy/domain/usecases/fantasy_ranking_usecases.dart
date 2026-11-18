import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';

/// Ranking da rodada [round] (nula = geral) pelo fluxo [cacheFirst]
/// (validade [CacheTtl.ranking]); [force] ignora a validade.
class GetFantasyRankingCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyRankingCacheFirstUseCase(this._repository);

  Stream<Either<Failure, List<FantasyRankingEntry>>> call(String fantasyId, {int? round, bool force = false}) =>
      cacheFirst<List<FantasyRankingEntry>>(
        readCache: () => _repository.getCachedRanking(fantasyId, round),
        fetchRemote: () =>
            round == null ? _repository.getOverallRanking(fantasyId) : _repository.getRoundRanking(fantasyId, round),
        saveCache: (entries) => _repository.saveRankingCache(fantasyId, round, entries),
        ttl: CacheTtl.ranking,
        force: force,
        logName: 'GetFantasyRankingCacheFirstUseCase',
      );
}

/// "Craques da rodada": os atletas que mais pontuaram na rodada [round]
/// (top 20), pelo fluxo [cacheFirst] (validade [CacheTtl.ranking]).
class GetFantasyTopAthletesCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyTopAthletesCacheFirstUseCase(this._repository);

  Stream<Either<Failure, List<FantasyAthleteScoreDTO>>> call(String fantasyId, int round, {bool force = false}) =>
      cacheFirst<List<FantasyAthleteScoreDTO>>(
        readCache: () => _repository.getCachedTopAthletes(fantasyId, round),
        fetchRemote: () => _repository.getTopAthletes(fantasyId, round),
        saveCache: (list) => _repository.saveTopAthletesCache(fantasyId, round, list),
        ttl: CacheTtl.ranking,
        force: force,
        logName: 'GetFantasyTopAthletesCacheFirstUseCase',
      );
}

/// Posição de quem tem [points] fora do top 50: os que têm mais + 1.
class GetFantasyPositionUseCase {
  final IFantasyRepository _repository;

  GetFantasyPositionUseCase(this._repository);

  Future<Either<Failure, int>> call(String fantasyId, double points, {int? round}) async {
    final above = await _repository.countAbove(fantasyId, points, round: round);
    return above.map((count) => count + 1);
  }
}

/// As rodadas do Fantasy (em ordem).
class GetFantasyRoundsUseCase {
  final IFantasyRepository _repository;

  GetFantasyRoundsUseCase(this._repository);

  Future<Either<Failure, List<FantasyRoundDTO>>> call(String fantasyId) => _repository.getRounds(fantasyId);
}

/// Escalação da conta numa rodada (uma leitura).
class GetFantasyLineupUseCase {
  final IFantasyRepository _repository;

  GetFantasyLineupUseCase(this._repository);

  Future<Either<Failure, FantasyLineupDTO?>> call(String fantasyId, int round, String uid) =>
      _repository.getLineup(fantasyId, round, uid);
}

/// Pontuação detalhada do atleta na rodada (uma leitura).
class GetFantasyAthleteScoreUseCase {
  final IFantasyRepository _repository;

  GetFantasyAthleteScoreUseCase(this._repository);

  Future<Either<Failure, FantasyAthleteScoreDTO?>> call(String fantasyId, int round, String athleteId) =>
      _repository.getAthleteScore(fantasyId, round, athleteId);
}
