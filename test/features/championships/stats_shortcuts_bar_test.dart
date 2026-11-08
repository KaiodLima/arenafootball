import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcuts_bar.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Prévia em PNG fora do CI: STATS_BAR_PREVIEW=1 flutter test test/features/championships/stats_shortcuts_bar_test.dart
// → build/stats_bar_previews/rodape.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  final opened = <Object?>[];

  Future<void> pump(WidgetTester tester, {GlobalKey? key}) async {
    tester.view.physicalSize = const Size(392, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.statsRankingPage) opened.add(settings.arguments);
        return MaterialPageRoute(builder: (_) => const SizedBox());
      },
      home: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar:
            RepaintBoundary(key: key, child: const StatsShortcutsBar(region: 'Floresta', season: '2026')),
      ),
    ));
    await tester.pump();
  }

  testWidgets('dois cartões, cada um abre o seu ranking', (tester) async {
    opened.clear();
    await pump(tester);
    expect(find.text('ARTILHARIA'), findsOneWidget);
    expect(find.text('ASSISTÊNCIAS'), findsOneWidget);
    await tester.tap(find.text('ARTILHARIA'));
    await tester.pumpAndSettle();
    expect((opened.last as Map)['type'], StatsRankingType.goals);
    await tester.pumpWidget(const SizedBox()); // recomeça sem a rota aberta
    await pump(tester);
    await tester.tap(find.text('ASSISTÊNCIAS'));
    await tester.pumpAndSettle();
    expect((opened.last as Map)['type'], StatsRankingType.assists);
    expect((opened.last as Map)['region'], 'Floresta');
  });

  testWidgets('prévia do rodapé', (tester) async {
    await tester.runAsync(() async {
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/stats_bar_previews').createSync(recursive: true);
    final key = GlobalKey();
    await pump(tester, key: key);
    expect(tester.takeException(), isNull);
    final png = await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('build/stats_bar_previews/rodape.png').writeAsBytesSync(png!);
  }, skip: Platform.environment['STATS_BAR_PREVIEW'] != '1');
}
