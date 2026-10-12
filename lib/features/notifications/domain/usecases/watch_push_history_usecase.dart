import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';

class WatchPushHistoryUseCase {
  final INotificationsRepository _repository;

  WatchPushHistoryUseCase(this._repository);

  Stream<Either<Failure, List<PushLogDTO>>> call() => _repository.watchHistory();
}
