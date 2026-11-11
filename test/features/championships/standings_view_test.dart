import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/presentation/page/standings_page.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_table.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Prévia em PNG fora do CI: STANDINGS_PREVIEW=1 flutter test test/features/championships/standings_view_test.dart
// → build/standings_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _played = [
  StandingDTO(id: 't2', teamName: 'Açaí No Gralle', wins: 2, draws: 1, goalsFor: 7, goalsAgainst: 2, points: 7),
  StandingDTO(id: 't1', teamName: 'Mulekada', wins: 1, draws: 1, losses: 1, goalsFor: 4, goalsAgainst: 4, points: 4),
  StandingDTO(id: 't3', teamName: 'Lava Jato FC', wins: 1, losses: 2, goalsFor: 3, goalsAgainst: 5, points: 3),
  StandingDTO(id: 't4', teamName: 'Volta Redonda', draws: 1, losses: 1, goalsFor: 1, goalsAgainst: 4, points: 1),
];

const _unplayed = [
  StandingDTO(id: 't2', teamName: 'Açaí No Gralle'),
  StandingDTO(id: 't1', teamName: 'Mulekada'),
];

void main() {
  test('cor da posição: 1º dourado, classificados verdes, demais cinza', () {
    expect(standingsPositionColor(1, GroupZone.qualified), AppColors.gold);
    expect(standingsPositionColor(2, GroupZone.qualified), AppColors.primary);
    expect(standingsPositionColor(3, GroupZone.playoff), AppColors.warning);
    expect(standingsPositionColor(4, GroupZone.eliminated), AppColors.danger);
    expect(standingsPositionColor(3, GroupZone.none), AppColors.background);
  });

  Future<void> pump(
    WidgetTester tester,
    List<StandingDTO> standings, {
    GlobalKey? key,
    String? legend,
    GroupRules rules = GroupRules.standard,
  }) async {
    tester.view.physicalSize = const Size(392, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: AppColors.background,
            child: StandingsBody(
              group: 'A',
              standings: standings,
              rules: rules,
              isFavorite: (s) => s.id == 't3',
              automaticLegend: legend,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('com jogos: líder, números do grupo e a linha que expande', (tester) async {
    await pump(tester, _played, legend: 'Atualizada sozinha.');
    expect(find.text('LÍDER'), findsOneWidget);
    expect(find.text('AÇAÍ NO GRALLE'), findsOneWidget);
    expect(find.text('7 PTS'), findsOneWidget);
    expect(find.text('2V 1E 0D'), findsOneWidget);
    expect(find.text('4 TIMES'), findsOneWidget);
    expect(find.text('5 JOGOS'), findsOneWidget);
    expect(find.text('15 GOLS'), findsOneWidget);
    expect(find.text('Atualizada sozinha.'), findsOneWidget);
    await tester.tap(find.text('Mulekada'));
    await tester.pumpAndSettle();
    expect(find.text('Aproveitamento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('regras do grupo: faixas, corte no total e padrão sem o campo', () {
    expect(GroupRules.fromMap(null), GroupRules.standard);
    expect(GroupRules.fromMap(null).qualified, 2);
    const rules = GroupRules(qualified: 2, playoff: 1, eliminated: 1);
    expect([for (var p = 1; p <= 5; p++) rules.zoneOf(p, 5)],
        [GroupZone.qualified, GroupZone.qualified, GroupZone.playoff, GroupZone.none, GroupZone.eliminated]);
    expect(const GroupRules(qualified: 4, eliminated: 2).zoneOf(3, 4), GroupZone.qualified, reason: 'verde vence');
    expect(const GroupRules(qualified: 3, playoff: 2).exceeds(4), isTrue);
    expect(const GroupRules(qualified: 0).hasAny, isFalse);
    final map = const GroupRules(qualified: 1, nextPhase: 'Final', homeAndAway: true).toMap();
    expect(GroupRules.fromMap(map), const GroupRules(qualified: 1, nextPhase: 'Final', homeAndAway: true));
  });

  testWidgets('regras ativas aparecem na legenda; desligadas não', (tester) async {
    await pump(tester, _played,
        rules: const GroupRules(qualified: 2, nextPhase: 'Semifinal', eliminated: 1, homeAndAway: true));
    expect(find.text('Classificados para a Semifinal'), findsOneWidget);
    expect(find.text('Eliminados'), findsOneWidget);
    expect(find.text('Repescagem'), findsNothing);
    expect(find.text('IDA E VOLTA'), findsOneWidget);
    await pump(tester, _played, rules: const GroupRules(qualified: 0));
    expect(find.textContaining('Classificados'), findsNothing);
    expect(find.text('IDA E VOLTA'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem jogos: sem líder, com a frase', (tester) async {
    await pump(tester, _unplayed);
    expect(find.text('LÍDER'), findsNothing);
    expect(find.text('A bola ainda não rolou neste grupo'), findsOneWidget);
    expect(find.text('0 JOGOS'), findsOneWidget, reason: 'zero não vira "1 jogo" (plural do pt)');
    expect(find.text('0 GOLS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prévias da classificação', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/standings_previews').createSync(recursive: true);
    const legend = 'Atualizada sozinha ao fim de cada partida. Desempate: vitórias, saldo de gols, gols pró.';
    final cases = {
      'com_jogos': _played,
      'sem_jogos': _unplayed,
      'nomes_longos': const [
        StandingDTO(
            id: 't9', teamName: 'Associação Atlética Floresta do Vale Unidos', wins: 3, goalsFor: 12, points: 9),
        ..._played,
      ],
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      await pump(tester, entry.value, key: key, legend: legend);
      expect(tester.takeException(), isNull, reason: entry.key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/standings_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: Platform.environment['STANDINGS_PREVIEW'] != '1');
}
