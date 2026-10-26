import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/unlock_celebration_dialog.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: home,
    );

const _jury = AchievementDTO(
  id: 'v10',
  title: 'Jurado',
  description: 'Vote em 10 partidas.',
  metric: AchievementMetric.votes,
  goal: 10,
  points: 40,
  tier: AchievementTier.silver,
  icon: 'whistle',
);

void main() {
  testWidgets('comemoração: título, nome, "+XP" e "Ver conquistas" devolve true', (tester) async {
    bool? seeAll;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => seeAll = await showUnlockCelebration(context, _jury),
          child: const Text('abrir'),
        ),
      ),
    )));
    await tester.tap(find.text('abrir'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('CONQUISTA DESBLOQUEADA!'), findsOneWidget);
    expect(find.text('Jurado'), findsOneWidget);
    expect(find.text('+40 XP'), findsOneWidget);
    await tester.tap(find.text('Ver conquistas'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(seeAll, isTrue);
  });

  FanCard card({String? level, List<({AchievementTier tier, String icon})> medals = const []}) => FanCard(
        name: 'Kaio Lima',
        photoUrl: '',
        favoriteTeam: '',
        team: null,
        region: 'Floresta',
        memberSince: 2026,
        number: '0001',
        level: level,
        medals: medals,
      );

  testWidgets('carteirinha: nível e até 3 medalhas; sem conquistas, nada', (tester) async {
    await tester.pumpWidget(_app(Scaffold(
      body: SizedBox(
        width: 400,
        child: card(level: 'ULTRA', medals: [
          (tier: AchievementTier.gold, icon: 'trophy'),
          (tier: AchievementTier.silver, icon: 'vote'),
          (tier: AchievementTier.bronze, icon: 'heart'),
          (tier: AchievementTier.bronze, icon: 'share'),
        ]),
      ),
    )));
    expect(find.text('ULTRA'), findsOneWidget);
    expect(find.byType(MedalBadge), findsNWidgets(3));

    await tester.pumpWidget(_app(Scaffold(body: SizedBox(width: 400, child: card()))));
    expect(find.byType(MedalBadge), findsNothing);
  });
}
