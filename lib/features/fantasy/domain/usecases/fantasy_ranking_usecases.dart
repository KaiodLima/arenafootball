import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
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

/// As rodadas do Fantasy pelo fluxo [cacheFirst] (validade
/// [CacheTtl.fantasyRounds]); [force] (puxar para atualizar) ignora a
/// validade. Pedir reapuração/reinício ou abrir/fechar rodada apaga.
class GetFantasyRoundsCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyRoundsCacheFirstUseCase(this._repository);

  Stream<Either<Failure, List<FantasyRoundDTO>>> call(String fantasyId, {bool force = false}) =>
      cacheFirst<List<FantasyRoundDTO>>(
        readCache: () => _repository.getCachedRounds(fantasyId),
        fetchRemote: () => _repository.getRounds(fantasyId),
        saveCache: (rounds) => _repository.saveRoundsCache(fantasyId, rounds),
        ttl: CacheTtl.fantasyRounds,
        force: force,
        logName: 'GetFantasyRoundsCacheFirstUseCase',
      );

  /// O valor mais novo numa leitura só.
  Future<Either<Failure, List<FantasyRoundDTO>>> latest(String fantasyId, {bool force = false}) =>
      call(fantasyId, force: force).last;
}

/// Posição da conta [uid] fora do top 50 (os que têm mais + 1) com cache
/// (validade [CacheTtl.fantasyPosition]) por Fantasy, rodada (nula = geral) e
/// conta; o cache só vale para os mesmos [points]. Sem conta, só o remoto.
class GetFantasyPositionCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyPositionCacheFirstUseCase(this._repository);

  Future<Either<Failure, int>> call(
    String fantasyId,
    double points, {
    int? round,
    required String uid,
    bool force = false,
  }) async {
    Future<Either<Failure, int>> remote() async {
      final above = await _repository.countAbove(fantasyId, points, round: round);
      return above.map((count) => count + 1);
    }

    if (uid.isEmpty) return remote();
    return cacheFirst<int>(
      readCache: () async {
        final cached = await _repository.getCachedPosition(fantasyId, round: round, uid: uid);
        final value = cached.isRight ? cached.right : null;
        if (value == null || value.data.points != points) return const Right(null);
        return Right(CachedValue(value.data.position, value.savedAt));
      },
      fetchRemote: remote,
      saveCache: (position) => _repository.savePositionCache(
        fantasyId,
        FantasyPositionRecord(points: points, position: position),
        round: round,
        uid: uid,
      ),
      ttl: CacheTtl.fantasyPosition,
      force: force,
      logName: 'GetFantasyPositionCacheFirstUseCase',
    ).last;
  }
}

/// A conta numa rodada: a escalação e a posição nela (histórico e "sua
/// posição" no ranking da rodada). Rodada fechada vai para o cache
/// (validade [CacheTtl.fantasyScored]) com a versão da apuração
/// ([FantasyRoundDTO.scoringVersion]): reapurada, lê de novo. Falha (na
/// escalação ou na posição) nunca vai para o cache; "não jogou" vai.
class GetFantasyRoundRecordUseCase {
  final IFantasyRepository _repository;

  GetFantasyRoundRecordUseCase(this._repository);

  Future<Either<Failure, FantasyRoundRecord>> call(
    String fantasyId,
    FantasyRoundDTO round,
    String uid, {
    bool force = false,
  }) async {
    final version = round.scoringVersion;
    // Leu tudo sem falha (a posição falhar devolve o registro sem ela).
    var complete = true;
    Future<Either<Failure, FantasyRoundRecord>> remote() async {
      final lineup = await _repository.getLineup(fantasyId, round.number, uid);
      if (lineup.isLeft) return Left(lineup.left);
      final points = lineup.right?.points;
      if (points == null) return Right(FantasyRoundRecord(version: version, lineup: lineup.right));
      final above = await _repository.countAbove(fantasyId, points, round: round.number);
      complete = above.isRight;
      return Right(FantasyRoundRecord(
        version: version,
        lineup: lineup.right,
        position: above.fold((_) => null, (count) => count + 1),
      ));
    }

    if (!round.closed || uid.isEmpty) return remote();
    return cacheFirst<FantasyRoundRecord>(
      readCache: () async {
        final cached = await _repository.getCachedRoundRecord(fantasyId, round.number, uid);
        final value = cached.isRight ? cached.right : null;
        return Right(value != null && value.data.version == version ? value : null);
      },
      fetchRemote: remote,
      saveCache: (record) => complete
          ? _repository.saveRoundRecordCache(fantasyId, round.number, uid, record)
          : Future.value(const Right<Failure, void>(null)),
      ttl: CacheTtl.fantasyScored,
      force: force,
      logName: 'GetFantasyRoundRecordUseCase',
    ).last;
  }
}

/// Pontuação detalhada do atleta na rodada. Com a [version] da apuração
/// (rodada apurada, [FantasyRoundDTO.scoringVersion] > 0), pelo cache
/// (validade [CacheTtl.fantasyScored]) até a reapuração; sem ela, só o
/// remoto (rodada em aberto/painel do admin).
class GetFantasyAthleteScoreCacheFirstUseCase {
  final IFantasyRepository _repository;

  GetFantasyAthleteScoreCacheFirstUseCase(this._repository);

  Future<Either<Failure, FantasyAthleteScoreDTO?>> call(
    String fantasyId,
    int round,
    String athleteId, {
    int version = 0,
  }) async {
    if (version <= 0) return _repository.getAthleteScore(fantasyId, round, athleteId);
    final result = await cacheFirst<FantasyAthleteScoreRecord>(
      readCache: () async {
        final cached = await _repository.getCachedAthleteScore(fantasyId, round, athleteId);
        final value = cached.isRight ? cached.right : null;
        return Right(value != null && value.data.version == version ? value : null);
      },
      fetchRemote: () async {
        final score = await _repository.getAthleteScore(fantasyId, round, athleteId);
        return score.map((s) => FantasyAthleteScoreRecord(version: version, score: s));
      },
      saveCache: (record) => _repository.saveAthleteScoreCache(fantasyId, round, athleteId, record),
      ttl: CacheTtl.fantasyScored,
      logName: 'GetFantasyAthleteScoreCacheFirstUseCase',
    ).last;
    return result.map((record) => record.score);
  }
}
