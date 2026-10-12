import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
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
  registerChampionshipsDependencies();
  registerMatchesDependencies();
  registerVotingDependencies();
  registerStatsDependencies();
  registerNewsDependencies();
  registerHighlightsDependencies();
  registerGlobalResultsDependencies();
  registerNotificationsDependencies();
}

void _registerExternal() {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => PreferencesService());
  sl.registerLazySingleton(() => StorageUploadService(sl()));
}
