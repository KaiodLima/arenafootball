import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_select_tile.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

void main() {
  testWidgets('campo mostra a região e a folha troca', (tester) async {
    String? changed;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RegionSelectTile(
          label: 'Procurar em',
          region: 'Floresta',
          regions: const ['Colônia', 'Floresta', 'Santo Inácio'],
          onChanged: (region) => changed = region,
        ),
      ),
    ));
    expect(find.text('Floresta'), findsOneWidget);
    // Só a região atual à vista (as outras ficam na folha).
    expect(find.text('Colônia'), findsNothing);

    await tester.tap(find.text('Floresta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Colônia').last);
    await tester.pumpAndSettle();
    expect(changed, 'Colônia');
  });

  testWidgets('com allLabel: "Todas as regiões" devolve vazio', (tester) async {
    String? changed;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RegionSelectTile(
          label: 'Público',
          region: 'Floresta',
          regions: const ['Colônia', 'Floresta'],
          allLabel: 'Todas as regiões',
          onChanged: (region) => changed = region,
        ),
      ),
    ));
    await tester.tap(find.text('Floresta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas as regiões'));
    await tester.pumpAndSettle();
    expect(changed, '');
  });
}
