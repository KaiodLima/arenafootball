import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/referrals/data/datasources/referrals_datasource.dart';
import 'package:arena_soccer/features/referrals/data/repositories/referrals_repository_impl.dart';
import 'package:arena_soccer/features/referrals/domain/repositories/referrals_repository_interface.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';

final _sl = GetIt.instance;

void registerReferralsDependencies() {
  // DataSource
  _sl.registerLazySingleton<ReferralsDataSource>(() => ReferralsDataSource(_sl(), _sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IReferralsRepository>(() => ReferralsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => EnsureReferralCodeUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchReferralUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchReferredFriendsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetReferralClaimUseCase(_sl()));
  _sl.registerLazySingleton(() => ClaimReferralUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchReferralConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SetReferralEnabledUseCase(_sl()));
}
