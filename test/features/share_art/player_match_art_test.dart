import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/player_match_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/lineup_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/match_art_sheet.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/l10n/app_localizations_pt.dart';

final _now = DateTime.utc(2026, 11, 13, 15);

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato FC',
  awayTeam: 'Volta Redonda',
  homeTeamId: 't1',
  awayTeamId: 't2',
  date: '15/11/2026',
  time: '18:00',
  venue: 'Campo do Ipê',
  championshipId: 11,
);

const _enrolled = PlayerDTO(
  id: 'p1',
  name: 'Ronaldo Nazário',
  team: 'Volta Redonda',
  teamId: 't2',
  goals: 9,
  enrollments: [PlayerEnrollment(championshipId: 11, teamId: 't2', team: 'Volta Redonda', goals: 4, assists: 1)],
  hasEnrollmentField: true,
);

ResultArtData _prepared({String time = '18:00', String venue = 'Campo do Ipê'}) => ResultArtData.of(
      _match.copyWith(time: time, venue: venue),
      homeTeam: const TeamDTO(id: 't1', name: 'Lava Jato FC', primaryColor: '#D32F2F'),
      awayTeam: const TeamDTO(id: 't2', name: 'Volta Redonda', primaryColor: '#1E88E5'),
      championship: 'Copa da Floresta',
      now: _now,
    );

void main() {
  test('lado do atleta: inscrição na competição, outro time, amistoso e antigo', () {
    expect(playerArtSideOf(_match, _enrolled), MatchSide.away);
    expect(playerArtSideOf(_match, null), isNull);
    // Inscrito por outro time nesta competição: não joga.
    const other = PlayerDTO(
      name: 'X',
      team: 'Lava Jato FC',
      teamId: 't1',
      enrollments: [PlayerEnrollment(championshipId: 11, teamId: 't9', team: 'Outro', goals: 0)],
      hasEnrollmentField: true,
    );
    expect(playerArtSideOf(_match, other), isNull);
    // Amistoso: o elenco geral (time principal).
    expect(playerArtSideOf(_match.copyWith(championshipId: 0), other), MatchSide.home);
    // Atleta antigo (sem inscrições): o time principal vale em toda competição.
    expect(playerArtSideOf(_match, const PlayerDTO(name: 'Y', team: 'Lava Jato FC', teamId: 't1')), MatchSide.home);
  });

  test('dados: adversário e números da competição da partida', () {
    final data = PlayerMatchArtData.of(
      player: _enrolled,
      match: _prepared(),
      side: MatchSide.away,
      championshipId: 11,
      season: '2026',
    );
    expect((data.team.name, data.opponent.name), ('Volta Redonda', 'Lava Jato FC'));
    expect((data.player.goals, data.player.assists), (4, 1));
    expect(data.player.championship, 'Copa da Floresta');
    expect(data.player.link, athleteLink('2026', 'p1'));
  });

  test('contagem: hoje, amanhã, dias, longe e sem data', () {
    final l10n = AppLocalizationsPt();
    PlayerMatchArtTexts texts(String date) => PlayerMatchArtTexts.of(
          l10n,
          PlayerMatchArtData.of(
            player: _enrolled,
            match: ResultArtData.of(_match.copyWith(date: date), now: _now),
            side: MatchSide.away,
            championshipId: 11,
            season: '2026',
          ),
          _now,
        );
    (String, String, bool) count(String date) {
      final t = texts(date);
      return (t.countdownNumber, t.countdownLabel, t.countdownIsNumber);
    }

    expect(count('13/11/2026'), ('HOJE', 'DIA DE JOGO', false));
    expect(count('14/11/2026'), ('1', 'DIA PARA O JOGO', true));
    expect(count('15/11/2026'), ('2', 'DIAS PARA O JOGO', true));
    expect(count('31/12/2026'), ('PRÓXIMO JOGO', 'DIA DE JOGO', false));
    expect(count(''), ('PRÓXIMO JOGO', 'DIA DE JOGO', false));
  });

  test('escalação: goleiro perto do próprio gol, atacante perto do ataque', () {
    expect(lineupDepth('goleiro'), greaterThan(lineupDepth('zagueiro')));
    expect(lineupDepth('zagueiro'), greaterThan(lineupDepth('meia')));
    expect(lineupDepth('meia'), greaterThan(lineupDepth('atacante')));
    expect(lineupDepth(''), inInclusiveRange(0.3, 0.6));
  });

  testWidgets('modelos x 4 formatos x paletas sem estouro', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cases = [
      PlayerMatchArtData.of(player: _enrolled, match: _prepared(), side: MatchSide.away, championshipId: 11, season: '2026'),
      PlayerMatchArtData.of(
        player: const PlayerDTO(name: 'Maximiliano Bartolomeu Constantino Fernandes de Albuquerque', team: ''),
        match: ResultArtData.of(
          const MatchDTO(
            id: 'm2',
            homeTeam: 'Associação Atlética Floresta do Vale Unidos',
            awayTeam: 'Esporte Clube Santo Inácio de Loyola',
          ),
          now: _now,
        ),
        side: MatchSide.home,
        championshipId: 0,
        season: '2026',
      ),
    ];
    for (final data in cases) {
      for (final template in PlayerMatchArtTemplate.values) {
        for (final format in ArtFormat.values) {
          for (final palette in [ArtPalette.teams, ArtPalette.ocean]) {
            await tester.pumpWidget(MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('pt'),
              home: Scaffold(
                body: Center(
                  child: PlayerMatchArt(
                      data: data, template: template, format: format, palette: palette, showQr: true, now: _now),
                ),
              ),
            ));
            expect(tester.takeException(), isNull, reason: '${data.player.name}/${template.name}/${format.name}');
          }
        }
      }
    }
  });

  Future<List<String>> tapMegaphone(WidgetTester tester, {required bool isAdmin, PlayerDTO? myPlayer}) async {
    final pushed = <String>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      onGenerateRoute: (settings) {
        pushed.add(settings.name!);
        return MaterialPageRoute(builder: (_) => const SizedBox());
      },
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => openMatchArt(context, match: _match, season: '2026', isAdmin: isAdmin, myPlayer: myPlayer),
          child: const Text('go'),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    return pushed;
  }

  testWidgets('megafone: usuário comum vai direto à divulgação', (tester) async {
    final pushed = await tapMegaphone(tester, isAdmin: false);
    expect(pushed, [AppRoutes.shareArtPage]);
  });

  testWidgets('megafone: atleta da partida escolhe e vai à arte dele', (tester) async {
    final pushed = await tapMegaphone(tester, isAdmin: false, myPlayer: _enrolled);
    expect(pushed, isEmpty);
    expect(find.text('Arte do atleta'), findsOneWidget);
    expect(find.text('Divulgar partida'), findsOneWidget);
    await tester.tap(find.text('Arte do atleta'));
    await tester.pumpAndSettle();
    expect(pushed, [AppRoutes.playerMatchArtPage]);
  });

  testWidgets('megafone: admin vê as duas opções', (tester) async {
    final pushed = await tapMegaphone(tester, isAdmin: true);
    expect(pushed, isEmpty);
    expect(find.text('Arte do atleta'), findsOneWidget);
    await tester.tap(find.text('Divulgar partida'));
    await tester.pumpAndSettle();
    expect(pushed, [AppRoutes.shareArtPage]);
  });
}
