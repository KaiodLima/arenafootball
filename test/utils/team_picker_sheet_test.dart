import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';

void main() {
  const teams = [
    TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta'),
    TeamDTO(id: '2', name: 'Invasão', region: 'Colônia'),
    TeamDTO(id: '3', name: 'Sem Casa', region: ''),
    TeamDTO(id: '4', name: 'Puças', region: 'Colônia'),
    TeamDTO(id: '5', name: 'Atlético', region: 'Santo Inácio'),
    TeamDTO(id: '6', name: 'Águia', region: 'Floresta'),
  ];

  test('agrupa por região: a primeira, as demais em ordem e sem região no fim', () {
    final groups = groupTeamsByRegion(teams, firstRegion: 'Floresta');
    expect(groups.map((g) => g.region), ['Floresta', 'Colônia', 'Santo Inácio', '']);
    expect(groups.first.teams.map((t) => t.name), ['Águia', 'Lava Jato']);
    expect(groups[1].teams.map((t) => t.name), ['Invasão', 'Puças']);
    expect(groupTeamsByRegion(teams).first.region, 'Colônia');
  });

  testWidgets('folha mostra os cabeçalhos e a busca pela região', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTeamPickerSheet(context, title: 'Mandante', teams: teams, firstRegion: 'Colônia'),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Colônia'), findsOneWidget);
    expect(find.text('Floresta'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'colonia');
    await tester.pumpAndSettle();
    expect(find.text('Colônia'), findsOneWidget);
    expect(find.text('Floresta'), findsNothing);
    expect(find.text('Puças'), findsOneWidget);
  });
}
