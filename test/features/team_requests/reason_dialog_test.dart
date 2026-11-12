import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/reason_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

void main() {
  Future<List<String?>> open(WidgetTester tester) async {
    final results = <String?>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              results.add(await showReasonDialog(context, title: 'Rejeitar pedido', confirmLabel: 'Rejeitar')),
          child: const Text('abrir'),
        ),
      ),
    ));
    return results;
  }

  Future<void> tapOpen(WidgetTester tester) async {
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('abre no modal padrão; confirmar devolve o motivo (ou vazio)', (tester) async {
    final results = await open(tester);
    await tapOpen(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Rejeitar pedido'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Time já cadastrado  ');
    await tester.tap(find.text('Rejeitar'));
    await tester.pumpAndSettle();
    await tapOpen(tester);
    await tester.tap(find.text('Rejeitar'));
    await tester.pumpAndSettle();
    expect(results, ['Time já cadastrado', '']);
  });

  testWidgets('Cancelar e o ✕ devolvem nulo', (tester) async {
    final results = await open(tester);
    await tapOpen(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tapOpen(tester);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(results, [null, null]);
  });
}
