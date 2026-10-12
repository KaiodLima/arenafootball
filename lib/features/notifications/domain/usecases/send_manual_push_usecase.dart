import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';

/// Aviso manual: a Cloud Function envia ([region] vazia = todos).
class SendManualPushUseCase {
  static const int titleMax = 60;
  static const int bodyMax = 180;

  final INotificationsRepository _repository;

  SendManualPushUseCase(this._repository);

  Future<Either<Failure, void>> call({required String title, required String body, required String region}) =>
      _repository.sendManual(title: title.trim(), body: body.trim(), region: region);
}
