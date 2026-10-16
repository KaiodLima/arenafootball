import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext host;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Builder(builder: (context) {
        host = context;
        return const Scaffold();
      }),
    ));
    return host;
  }

  Future<bool?> open(WidgetTester tester, BuildContext context) async {
    bool? result;
    showArenaConfirm(context, title: 'Excluir?', message: 'Some do feed.', confirmLabel: 'Excluir')
        .then((value) => result = value);
    await tester.pumpAndSettle();
    expect(find.text('Excluir?'), findsOneWidget);
    expect(find.text('Confirmação'), findsOneWidget);
    return result;
  }

  testWidgets('confirmar devolve true', (tester) async {
    final context = await pumpHost(tester);
    bool? result;
    showArenaConfirm(context, title: 'Excluir?', confirmLabel: 'Excluir').then((value) => result = value);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('cancelar ou ✕ devolve false', (tester) async {
    final context = await pumpHost(tester);
    await open(tester, context);
    bool? cancelled;
    showArenaConfirm(context, title: 'Outro?', confirmLabel: 'Ok').then((value) => cancelled = value);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();
    expect(cancelled, isFalse);

    bool? closed;
    showArenaConfirm(context, title: 'Mais um?', confirmLabel: 'Ok').then((value) => closed = value);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();
    expect(closed, isFalse);
  });

  testWidgets('aviso fecha no Ok', (tester) async {
    final context = await pumpHost(tester);
    var done = false;
    showArenaNotice(context, title: 'Região com conteúdo').then((_) => done = true);
    await tester.pumpAndSettle();
    expect(find.text('Aviso'), findsOneWidget);
    expect(find.text('Cancelar'), findsNothing);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });
}
