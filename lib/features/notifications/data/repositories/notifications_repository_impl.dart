import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';

class NotificationsRepositoryImpl implements INotificationsRepository {
  final NotificationsDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, Map<String, bool>>> watchConfig() => _dataSource.watchConfig();

  @override
  Future<Either<Failure, void>> setActionEnabled({required String key, required bool enabled}) =>
      _dataSource.setActionEnabled(key: key, enabled: enabled);

  @override
  Stream<Either<Failure, List<PushLogDTO>>> watchHistory() => _dataSource.watchHistory();

  @override
  Future<Either<Failure, void>> sendManual({required String title, required String body, required String region}) =>
      _dataSource.sendManual(title: title, body: body, region: region);
}
