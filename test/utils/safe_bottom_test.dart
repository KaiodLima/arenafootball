import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';

// Barra de navegação do sistema simulada (Android de ponta a ponta).
const _navBar = 48.0;
const _height = 800.0;

void main() {
  late BuildContext appContext;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, _height);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: _navBar);
    tester.view.viewPadding = const FakeViewPadding(bottom: _navBar);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Builder(builder: (context) {
        appContext = context;
        return const Scaffold();
      }),
    ));
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.fling(find.byType(Scrollable).last, const Offset(0, -3000), 3000);
    await tester.pumpAndSettle();
  }

  testWidgets('safeBottom soma o espaço da barra do sistema', (tester) async {
    await pumpApp(tester);
    expect(safeBottom(appContext), _navBar);
    expect(safeBottom(appContext, 16), 16 + _navBar);
  });

  testWidgets('folha de times: último time acima da barra do sistema', (tester) async {
    await pumpApp(tester);
    showTeamPickerSheet(
      appContext,
      title: 'Time',
      teams: [for (var i = 0; i < 30; i++) TeamDTO(id: 't$i', name: 'Time ${i.toString().padLeft(2, '0')}')],
    );
    await tester.pumpAndSettle();
    await scrollToEnd(tester);
    expect(tester.getRect(find.text('Time 29')).bottom, lessThanOrEqualTo(_height - _navBar));
  });

  testWidgets('folha de competições: última competição acima da barra do sistema', (tester) async {
    await pumpApp(tester);
    showChampionshipPickerSheet(
      appContext,
      championships: [
        for (var i = 0; i < 20; i++)
          ChampionshipDTO(id: 'c$i', championshipId: i, title: 'Copa ${i.toString().padLeft(2, '0')}'),
      ],
    );
    await tester.pumpAndSettle();
    await scrollToEnd(tester);
    expect(tester.getRect(find.text('Copa 19')).bottom, lessThanOrEqualTo(_height - _navBar));
  });
}
