import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';

/// Registra o dia de uso ([DailyVisit]); no mesmo dia, não grava nada.
class RecordDailyVisitUseCase {
  final IAchievementsRepository _repository;

  RecordDailyVisitUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid, AchievementProgressDTO progress, {DateTime? now}) async {
    final visit = DailyVisit.next(progress, now ?? DateTime.now());
    if (uid.isEmpty || visit == null) return const Right(null);
    return _repository.recordVisit(
      uid,
      activeDays: visit.activeDays,
      streak: visit.streak,
      bestStreak: visit.bestStreak,
    );
  }
}
