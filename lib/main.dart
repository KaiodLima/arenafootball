import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/arena_app.dart';
import 'package:arena_soccer/blocs_load.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/services/deep_link_service.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initCache();
  await di.init();
  await di.sl<PushService>().init();
  await di.sl<DeepLinkService>().init();

  runApp(const BlocsLoad(child: ArenaApp()));
}
