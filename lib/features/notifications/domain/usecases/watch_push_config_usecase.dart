import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';

/// Liga/desliga de cada ação, já com o padrão das que nunca foram mexidas.
class WatchPushConfigUseCase {
  final INotificationsRepository _repository;

  WatchPushConfigUseCase(this._repository);

  Stream<Either<Failure, Map<PushAction, bool>>> call() => _repository.watchConfig().map(
        (response) => response.map(
          (saved) => {for (final action in PushAction.values) action: saved[action.key] ?? action.defaultEnabled},
        ),
      );
}
