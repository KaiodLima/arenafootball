import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_claim_selector.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// 12 atletas: mais de uma página (3x3) e com busca.
final _players = [
  for (final name in ['Ana', 'Bruno', 'Caio', 'Dudu', 'Édson', 'Fábio', 'Gabi', 'Hugo', 'Ícaro', 'João', 'Kauã', 'Léo'])
    PlayerDTO(id: name, name: name, team: 'Lava Jato', goals: name.length),
];

void main() {
  PlayerDTO? selected;
  var changes = 0;

  Future<void> pump(WidgetTester tester, {PlayerDTO? current}) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PlayerClaimSelector(
              players: _players,
              selected: current,
              onSelected: (player) {
                selected = player;
                changes++;
              },
            ),
          ),
        ),
      ),
    ));
  }

  setUp(() {
    selected = null;
    changes = 0;
  });

  testWidgets('fechado não mostra atletas; aberto, a 1ª página (9) e a busca', (tester) async {
    await pump(tester);
    expect(find.text('Ana'), findsNothing);
    await tester.tap(find.text('Sou um destes atletas (opcional)'));
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Ícaro'), findsOneWidget);
    expect(find.text('João'), findsNothing); // 10º: próxima página
    expect(find.text('Buscar pelo nome'), findsOneWidget);
  });

  testWidgets('busca ignora acento; tocar escolhe e fecha', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Sou um destes atletas (opcional)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'edson');
    await tester.pumpAndSettle();
    expect(find.text('Ana'), findsNothing);
    await tester.tap(find.text('Édson'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'Édson');
    expect(find.text('Buscar pelo nome'), findsNothing);
  });

  testWidgets('busca sem resultado avisa', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Sou um destes atletas (opcional)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum atleta com esse nome'), findsOneWidget);
  });

  testWidgets('com escolha: campo mostra o atleta e o ✕ desmarca', (tester) async {
    await pump(tester, current: _players[3]);
    expect(find.text('Dudu'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(changes, 1);
    expect(selected, isNull);
  });
}
