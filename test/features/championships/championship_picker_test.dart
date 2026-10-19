import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _championships = [
  ChampionshipDTO(id: 'a', championshipId: 5, title: 'Copa Verde', region: 'Floresta'),
  ChampionshipDTO(
      id: 'b', championshipId: 7, title: 'Taça Piauí', region: 'Floresta', scope: ChampionshipScope.intermunicipal),
];

void main() {
  ({int? id})? picked;
  var closed = false;

  Future<void> open(WidgetTester tester, {int? selectedId = 5}) async {
    picked = null;
    closed = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              picked =
                  await showChampionshipPickerSheet(context, championships: _championships, selectedId: selectedId);
              closed = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('lista o amistoso e os campeonatos; tocar devolve o id', (tester) async {
    await open(tester);
    expect(find.text('Sem campeonato (amistoso)'), findsOneWidget);
    expect(find.text('Copa Verde'), findsOneWidget);
    expect(find.text('Intermunicipal · Floresta'), findsOneWidget);
    await tester.tap(find.text('Taça Piauí'));
    await tester.pumpAndSettle();
    expect(picked?.id, 7);
  });

  testWidgets('busca ignora acento; sem resultado avisa', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'taca');
    await tester.pumpAndSettle();
    expect(find.text('Copa Verde'), findsNothing);
    expect(find.text('Taça Piauí'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum campeonato com esse nome'), findsOneWidget);
  });

  testWidgets('amistoso devolve (id: null); diferente de fechar sem escolher', (tester) async {
    await open(tester);
    await tester.tap(find.text('Sem campeonato (amistoso)'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(picked, isNotNull);
    expect(picked!.id, isNull);
  });
}
