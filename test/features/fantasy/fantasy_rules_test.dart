import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_rules.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_rules_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

/// Lê um número do `POINTS` das functions (`chave: valor`, no 1º nível ou
/// dentro de [group]).
num _points(String source, String key, {String? group}) {
  final block = RegExp(r'export const POINTS = \{([\s\S]*?)\} as const;').firstMatch(source)!.group(1)!;
  final scope = group == null ? block : RegExp('$group: \\{([^}]*)\\}').firstMatch(block)!.group(1)!;
  final match = RegExp('(?:^|[\\s,{])$key: (-?\\d+(?:\\.\\d+)?)').firstMatch(scope)!;
  return num.parse(match.group(1)!);
}

Widget _app(FantasyConfigDTO? config) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: FantasyRulesPage(config: config),
    );

void main() {
  test('tabela do app = POINTS das functions', () {
    final source = File('functions/src/fantasy_scoring.ts').readAsStringSync();
    expect(FantasyScoringRules.base, _points(source, 'base'));
    expect(FantasyScoringRules.goal, _points(source, 'goal'));
    expect(FantasyScoringRules.assist, _points(source, 'assist'));
    expect(FantasyScoringRules.win, _points(source, 'win'));
    expect(FantasyScoringRules.loss, _points(source, 'loss'));
    expect(FantasyScoringRules.draw, 0); // as functions somam 'empate' com 0
    expect(FantasyScoringRules.yellow, _points(source, 'yellow'));
    expect(FantasyScoringRules.red, _points(source, 'red'));
    for (final slot in [FantasySlot.goalkeeper, FantasySlot.defender, FantasySlot.midfielder, FantasySlot.forward]) {
      expect(FantasyScoringRules.conceded[slot], _points(source, slot.key, group: 'conceded'), reason: slot.key);
      expect(FantasyScoringRules.cleanSheet[slot], _points(source, slot.key, group: 'cleanSheet'), reason: slot.key);
      expect(FantasyScoringRules.teamGoalsFor(slot), _points(source, slot.key, group: 'teamGoal'), reason: slot.key);
    }
    expect(FantasyScoringRules.teamGoalsFor(FantasySlot.forward), 0.5);
  });

  test('sinal: +5, −3 (menos de verdade) e 0', () {
    expect(FantasyScoringRules.signed(5), '+5');
    expect(FantasyScoringRules.signed(-3), '−3');
    expect(FantasyScoringRules.signed(0), '0');
    expect(FantasyScoringRules.signed(0.5), '+0,5');
    expect(FantasyScoringRules.signed(-1.5, decimal: '.'), '−1.5');
  });

  testWidgets('com a config do campeonato: minutos e capitão dele', (tester) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final config = FantasyConfigDTO.fromMap('doc1', {
      'titulo': 'Copa Verde',
      'ativo': true,
      'minMinutos': 30,
      'minMinutosDefesa': 60,
      'capitao': 2.0,
    });
    await tester.pumpWidget(_app(config));
    expect(find.text('Regras e pontuação'), findsOneWidget);
    expect(find.text('Copa Verde'), findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-rules-defaults')), findsNothing);
    expect(find.textContaining('menos de 30 min'), findsOneWidget);
    expect(find.textContaining('60 min ou mais'), findsOneWidget);
    expect(find.textContaining('pontua 2×'), findsOneWidget);
    // Tabela: valores com sinal; gols da equipe +0,5 em todas as posições.
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('−5'), findsOneWidget);
    expect(find.text('+0,5'), findsNWidgets(4));
  });

  testWidgets('sem config: os padrões e o aviso', (tester) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(null));
    expect(find.byKey(const ValueKey('fantasy-rules-defaults')), findsOneWidget);
    expect(find.textContaining('menos de 20 min'), findsOneWidget);
    expect(find.textContaining('45 min ou mais'), findsOneWidget);
    expect(find.textContaining('pontua 1,5×'), findsOneWidget);
  });
}
