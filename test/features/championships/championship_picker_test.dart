import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

final _championships = [
  for (var i = 1; i <= 12; i++) ChampionshipDTO(id: 'c$i', championshipId: i, title: 'Copa $i'),
];

void main() {
  /// Abre a folha; o que ela devolver vai para [results].
  Future<void> open(WidgetTester tester, List<({int? id})?> results, {ChampionshipExtraOption? extra}) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(await showChampionshipPickerSheet(
              context,
              championships: _championships,
              noneLabel: 'Elenco geral',
              extraOption: extra,
            )),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('muitas competições: a busca filtra a lista', (tester) async {
    await open(tester, []);
    await tester.enterText(find.byType(TextField), 'copa 12');
    await tester.pumpAndSettle();
    expect(find.text('Copa 12'), findsOneWidget);
    expect(find.text('Copa 3'), findsNothing);
  });

  testWidgets('opção extra (Amistosos): aparece depois da nula e devolve o id', (tester) async {
    final results = <({int? id})?>[];
    await open(tester, results, extra: (id: -1, label: 'Amistosos', icon: Icons.handshake_outlined));
    expect(find.text('Elenco geral'), findsOneWidget);
    await tester.tap(find.text('Amistosos'));
    await tester.pumpAndSettle();
    expect(results.single?.id, -1);
  });

  testWidgets('campo: sem escolha mostra o rótulo da opção nula; escolhido, o título', (tester) async {
    Future<void> pump(ChampionshipDTO? selected) => tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: ChampionshipSelectTile(label: 'Competição', championship: selected, noneLabel: 'Geral', onTap: () {}),
          ),
        ));
    await pump(null);
    expect(find.text('Geral'), findsOneWidget);
    await pump(_championships[4]);
    expect(find.text('Copa 5'), findsOneWidget);
  });
}
