import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/domain/player_season_summary.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_season_history_usecase.dart';

/// Uma temporada do histórico da conta, do cache local.
class GetCachedPlayerSeasonSummaryUseCase {
  final IPlayersRepository _repository;

  GetCachedPlayerSeasonSummaryUseCase(this._repository);

  Future<Either<Failure, CachedValue<PlayerSeasonSummary?>?>> call({required String userId, required String season}) =>
      _repository.getCachedSeasonSummary(userId: userId, season: season);
}

class SavePlayerSeasonSummaryCacheUseCase {
  final IPlayersRepository _repository;

  SavePlayerSeasonSummaryCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerSeasonSummary? summary, {required String userId, required String season}) =>
      _repository.saveSeasonSummaryCache(summary, userId: userId, season: season);
}

/// Histórico por temporada do atleta da conta, cada temporada pelo fluxo
/// [cacheFirst] (validade [CacheTtl.profileFor]: a atual 10 min, as passadas
/// 24 h). Gravar um jogador apaga o histórico do cache (no repositório).
/// Devolve o valor mais novo de cada temporada numa leitura só.
class GetPlayerSeasonHistoryCacheFirstUseCase {
  final GetPlayerSeasonHistoryUseCase _getHistory;
  final GetCachedPlayerSeasonSummaryUseCase _getCached;
  final SavePlayerSeasonSummaryCacheUseCase _saveCache;

  GetPlayerSeasonHistoryCacheFirstUseCase(this._getHistory, this._getCached, this._saveCache);

  Future<Either<Failure, List<PlayerSeasonSummary>>> call({
    required String userId,
    required List<String> seasons,
    bool force = false,
  }) async {
    if (userId.isEmpty) return const Right([]);
    final rows = await Future.wait(seasons.map((season) async {
      final response = await cacheFirst<PlayerSeasonSummary?>(
        readCache: () => _getCached(userId: userId, season: season),
        fetchRemote: () => _getHistory.season(userId: userId, season: season),
        saveCache: (summary) => _saveCache(summary, userId: userId, season: season),
        ttl: CacheTtl.profileFor(season),
        force: force,
        logName: 'GetPlayerSeasonHistoryCacheFirstUseCase',
      ).last;
      return response.fold((_) => null, (summary) => summary);
    }));
    return Right(GetPlayerSeasonHistoryUseCase.sortHistory(rows));
  }
}
