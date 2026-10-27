import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/partner_requests/data/datasources/partner_requests_datasource.dart';
import 'package:arena_soccer/features/partner_requests/data/repositories/partner_requests_repository_impl.dart';
import 'package:arena_soccer/features/partner_requests/domain/repositories/partner_requests_repository_interface.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/answer_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/cancel_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/partner_highlight_links_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/submit_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/update_partner_permissions_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_my_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_partner_requests_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_pending_partner_requests_count_usecase.dart';

final _sl = GetIt.instance;

void registerPartnerRequestsDependencies() {
  // DataSource
  _sl.registerLazySingleton<PartnerRequestsDataSource>(() => PartnerRequestsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IPartnerRequestsRepository>(() => PartnerRequestsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyPartnerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => SubmitPartnerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => CancelPartnerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPartnerRequestsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPendingPartnerRequestsCountUseCase(_sl()));
  _sl.registerLazySingleton(() => AnswerPartnerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdatePartnerPermissionsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPartnerSlotsUseCase(_sl()));
  _sl.registerLazySingleton(() => PartnerHighlightLinksUseCase(_sl()));
}
