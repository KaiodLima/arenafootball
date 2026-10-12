import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';

class SetPushActionUseCase {
  final INotificationsRepository _repository;

  SetPushActionUseCase(this._repository);

  Future<Either<Failure, void>> call(PushAction action, bool enabled) =>
      _repository.setActionEnabled(key: action.key, enabled: enabled);
}
