import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/tour/tour_layout.dart';
import 'package:arena_soccer/utils/components/tour/tour_overlay.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';

void main() {
  group('posição do cartão', () {
    const screen = Size(400, 800);

    test('alvo no alto: cartão embaixo; alvo embaixo: cartão em cima', () {
      expect(TourLayout.cardAbove(const Rect.fromLTWH(20, 40, 360, 44), screen), isFalse);
      expect(TourLayout.cardAbove(const Rect.fromLTWH(0, 720, 400, 80), screen), isTrue);
    });

    test('setinha presa dentro do cartão, o recorte dentro da tela', () {
      expect(TourLayout.arrowX(const Rect.fromLTWH(0, 0, 10, 10), cardLeft: 16, cardRight: 384), 44);
      expect(TourLayout.arrowX(const Rect.fromLTWH(380, 0, 20, 10), cardLeft: 16, cardRight: 384), 356);
      expect(TourLayout.hole(const Rect.fromLTWH(2, 2, 50, 50), screen, 8), const Rect.fromLTRB(0, 0, 60, 60));
    });

    test('alvo fora da tela ou sem tamanho não conta', () {
      expect(TourLayout.isVisible(const Rect.fromLTWH(0, 900, 100, 40), screen), isFalse);
      expect(TourLayout.isVisible(Rect.zero, screen), isFalse);
      expect(TourLayout.isVisible(const Rect.fromLTWH(10, 10, 100, 40), screen), isTrue);
    });
  });

  test('vistos: marca, não repete e "Rever tutoriais" zera', () async {
    SharedPreferences.setMockInitialValues({});
    final tours = TourService(PreferencesService());
    expect(await tours.isSeen(TourIds.home), isFalse);
    await tours.markSeen(TourIds.home);
    await tours.markSeen(TourIds.album);
    expect(await tours.isSeen(TourIds.home), isTrue);
    await tours.reset();
    expect(await tours.isSeen(TourIds.album), isFalse);
  });

  testWidgets('spotlight: passa os passos, pula alvo fora da tela e termina', (tester) async {
    final first = GlobalKey();
    final second = GlobalKey();
    final missing = GlobalKey(); // nunca montado: pulado
    bool? result;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              SizedBox(key: first, width: 100, height: 40),
              const SizedBox(height: 400),
              SizedBox(key: second, width: 100, height: 40),
              TextButton(
                onPressed: () async => result = await showTourOverlay(context, [
                  TourStep(target: first, icon: Icons.star, title: 'Primeiro', body: 'a'),
                  TourStep(target: missing, icon: Icons.star, title: 'Sumido', body: 'b'),
                  TourStep(target: second, icon: Icons.star, title: 'Segundo', body: 'c'),
                ]),
                child: const Text('abrir'),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Primeiro'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.text('Sumido'), findsNothing);
    await tester.tap(find.text('Entendi'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(result, isTrue);
  });

  testWidgets('spotlight: sem nenhum alvo na tela não mostra nada', (tester) async {
    bool? result = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showTourOverlay(context, [
            TourStep(target: GlobalKey(), icon: Icons.star, title: 'x', body: 'y'),
          ]),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump();
    expect(result, isNull);
  });
}
