import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:arena_soccer/core/services/deep_link_service.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:arena_soccer/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/send_manual_push_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/set_push_action_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_config_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_history_usecase.dart';

final _sl = GetIt.instance;

void registerNotificationsDependencies() {
  // Push no aparelho (FCM + notificação local) e a sincronia de tópicos
  _sl.registerLazySingleton(() => PushService(FirebaseMessaging.instance));
  _sl.registerLazySingleton(() => PushTopicSync(_sl<PushService>()));

  // Links compartilhados que abrem o app (deep links)
  _sl.registerLazySingleton(() => DeepLinkService());

  // Painel do admin
  _sl.registerLazySingleton(() => NotificationsDataSource(_sl()));
  _sl.registerLazySingleton<INotificationsRepository>(() => NotificationsRepositoryImpl(_sl()));
  _sl.registerLazySingleton(() => WatchPushConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SetPushActionUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPushHistoryUseCase(_sl()));
  _sl.registerLazySingleton(() => SendManualPushUseCase(_sl()));
}
