import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/arena_app.dart';
import 'package:arena_soccer/blocs_load.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/services/deep_link_service.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/injection_container.dart' as di;
import 'package:arena_soccer/utils/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android de ponta a ponta: barra de navegação do sistema transparente, por cima do app
  // (as telas e folhas somam o espaço dela: safeBottom / SafeArea).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  await Firebase.initializeApp();
  await initCache();
  await di.init();
  await di.sl<PushService>().init();
  await di.sl<DeepLinkService>().init();

  runApp(const BlocsLoad(child: ArenaApp()));
}
