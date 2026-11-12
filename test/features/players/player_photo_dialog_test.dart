import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_photo_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

void main() {
  Future<List<File?>> open(WidgetTester tester) async {
    final results = <File?>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => results.add(
            await PlayerPhotoDialog.show(context, player: const PlayerDTO(name: 'Ronaldo Lima', team: 'Lava Jato')),
          ),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('abre no modal padrão: título, prévia e Tirar foto / Galeria', (tester) async {
    await open(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Trocar foto'), findsOneWidget);
    expect(find.text('Foto do atleta'), findsOneWidget);
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Galeria'), findsOneWidget);
  });

  testWidgets('Cancelar, o ✕ e Salvar sem escolher devolvem nulo', (tester) async {
    final results = await open(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(results, [null, null, null]);
  });
}
