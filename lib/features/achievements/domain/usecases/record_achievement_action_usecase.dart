import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Soma 1 numa métrica contada pelo app (compartilhar, ler notícia).
/// Métrica do servidor é ignorada.
class RecordAchievementActionUseCase {
  final IAchievementsRepository _repository;

  RecordAchievementActionUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid, AchievementMetric metric) async {
    if (uid.isEmpty || !metric.countedByApp) return const Right(null);
    return _repository.increment(uid, metric);
  }
}
