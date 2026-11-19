import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/athlete_invite_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/share_image_frame.dart';
import 'package:arena_soccer/features/players/domain/athlete_invite.dart';
import 'package:arena_soccer/l10n/app_localizations_pt.dart';

/// "Conheço esse jogador": o convite para o atleta sem conta entrar no app.
void main() {
  final l10n = AppLocalizationsPt();
  const link = 'https://arenasoccerflutter.web.app/atleta/2026/p1';

  test('com competição e números: time, competição, gols, assistências e o link', () {
    final text = athleteInviteText(
      l10n,
      name: 'Rafael Souza Lima',
      team: 'Leões',
      championship: 'Copa Verde',
      goals: 7,
      assists: 3,
      link: link,
    );
    expect(text, startsWith('⚽ Rafael, você já está no Arena Football!'));
    expect(text, contains('O atleta Rafael Souza Lima do Leões na Copa Verde parece ser você'));
    expect(text, contains('7 gols e 3 assistências'));
    expect(text, contains('🎴 sua figurinha no álbum'));
    expect(text.trim().split('\n').last, link);
  });

  test('sem competição: só o time; sem números: a página esperando', () {
    final text = athleteInviteText(l10n, name: 'Beto', team: 'Tigres', link: link);
    expect(text, contains('O atleta Beto do Tigres parece ser você'));
    expect(text, contains('sua página de atleta já está esperando por você'));
    expect(text, isNot(contains('já estão lá')));
    expect(text, contains(link));
  });

  testWidgets('arte do convite: logo do app, título, atleta, time · competição e números', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ShareImageFrame(
            date: DateTime(2026, 11, 19),
            card: const AthleteInviteCard(
              player: PlayerDTO(id: 'p1', name: 'Rafael Souza', team: 'Leões'),
              team: 'Leões',
              championship: 'Copa Verde',
              goals: 7,
              assists: 3,
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsWidgets);
    expect(find.text('VOCÊ ESTÁ NO ARENA FOOTBALL!'), findsOneWidget);
    expect(find.text('Rafael Souza'), findsOneWidget);
    expect(find.text('Leões · Copa Verde'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Crie sua conta e diga: "Sou eu!"'), findsOneWidget);
  });
}
