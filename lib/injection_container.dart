import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:arena_soccer/features/predictions/di/predictions_injection.dart';
import 'package:arena_soccer/features/achievements/di/achievements_injection.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/fan_ranking/di/fan_ranking_injection.dart';
import 'package:arena_soccer/features/global_results/di/global_results_injection.dart';
import 'package:arena_soccer/features/auth/di/auth_injection.dart';
import 'package:arena_soccer/features/championships/di/championships_injection.dart';
import 'package:arena_soccer/features/highlights/di/highlights_injection.dart';
import 'package:arena_soccer/features/notifications/di/notifications_injection.dart';
import 'package:arena_soccer/features/matches/di/matches_injection.dart';
import 'package:arena_soccer/features/news/di/news_injection.dart';
import 'package:arena_soccer/features/player_requests/di/player_requests_injection.dart';
import 'package:arena_soccer/features/players/di/players_injection.dart';
import 'package:arena_soccer/features/regions/di/regions_injection.dart';
import 'package:arena_soccer/features/seasons/di/seasons_injection.dart';
import 'package:arena_soccer/features/stats/di/stats_injection.dart';
import 'package:arena_soccer/features/team_requests/di/team_requests_injection.dart';
import 'package:arena_soccer/features/partner_requests/di/partner_requests_injection.dart';
import 'package:arena_soccer/features/maintenance/di/maintenance_injection.dart';
import 'package:arena_soccer/features/album/di/album_injection.dart';
import 'package:arena_soccer/features/teams/di/teams_injection.dart';
import 'package:arena_soccer/features/voting/di/voting_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _registerExternal();
  registerAuthDependencies();
  registerRegionsDependencies();
  registerSeasonsDependencies();
  registerTeamsDependencies();
  registerPlayersDependencies();
  registerPlayerRequestsDependencies();
  registerTeamRequestsDependencies();
  registerPartnerRequestsDependencies();
  registerMaintenanceDependencies();
  registerAlbumDependencies();
  registerChampionshipsDependencies();
  registerMatchesDependencies();
  registerVotingDependencies();
  registerStatsDependencies();
  registerNewsDependencies();
  registerHighlightsDependencies();
  registerGlobalResultsDependencies();
  registerNotificationsDependencies();
  registerFanRankingDependencies();
  registerAchievementsDependencies();
  registerPredictionsDependencies();
}

/// A persistência do Firestore só pode ser configurada antes do primeiro uso.
bool _firestoreConfigured = false;

void _registerExternal() {
  if (!_firestoreConfigured) {
    // Cache em disco do Firestore: releituras de docs iguais e uso offline.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _firestoreConfigured = true;
  }
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => PreferencesService());
  sl.registerLazySingleton(() => TourService(sl()));
  sl.registerLazySingleton(() => StorageUploadService(sl()));
  // Caixa aberta no `initCache()` (main), antes daqui.
  sl.registerLazySingleton(() => CacheStore(Hive.box<String>(CacheStore.boxName)));
}
