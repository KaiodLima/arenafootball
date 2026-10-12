import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';

abstract class INotificationsRepository {
  Stream<Either<Failure, Map<String, bool>>> watchConfig();

  Future<Either<Failure, void>> setActionEnabled({required String key, required bool enabled});

  Stream<Either<Failure, List<PushLogDTO>>> watchHistory();

  Future<Either<Failure, void>> sendManual({required String title, required String body, required String region});
}
