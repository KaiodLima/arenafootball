import 'package:arena_soccer/features/stats/domain/repositories/stats_repository_interface.dart';

/// Apaga todos os rankings do cache local (as gravações de jogador já fazem
/// isso no repositório de jogadores).
class DeleteStatsRankingCacheUseCase {
  final IStatsRepository _repository;

  DeleteStatsRankingCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteRankingCache();
}
