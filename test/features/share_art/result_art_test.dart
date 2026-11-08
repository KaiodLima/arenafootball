import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/art_exporter.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Associação Atlética dos Leões da Colônia',
  awayTeam: 'Tigres',
  homeTeamId: 't1',
  awayTeamId: 't2',
  date: '10/12/2026',
  time: '16:00',
  venue: 'Arena Orlandão',
  championshipId: 11,
  manualStatus: MatchManualStatus.finished,
  goals: [
    MatchGoal(id: 'g2', side: MatchSide.away, scorerId: 'z', scorerName: 'Zé', minute: 70),
    MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'a', scorerName: 'Ana', minute: 12),
    MatchGoal(id: 'g3', side: MatchSide.home, scorerId: 'b', scorerName: 'Bia', minute: 80),
  ],
);

ResultArtData _data({MatchDTO match = _match}) => ResultArtData.of(
      match,
      homeTeam: const TeamDTO(id: 't1', name: 'Leões', primaryColor: '#D32F2F'),
      awayTeam: const TeamDTO(id: 't2', name: 'Tigres', primaryColor: '#FFFFFF'),
      championship: 'Copa Sol',
      championshipLogoUrl: 'https://x/logo.png',
      link: 'https://arenasoccerflutter.web.app/noticia/resultado_m1',
      now: DateTime(2026, 12, 11),
    );

void main() {
  test('cor do visitante: troca pela secundária/marca quando parece a da casa', () {
    const red = Color(0xFFD32F2F);
    const darkRed = Color(0xFFC62828);
    const white = Color(0xFFFFFFFF);
    expect(ArtTheme.contrastingAway(red, const [darkRed, white]), white);
    expect(ArtTheme.contrastingAway(red, const [Color(0xFF1E88E5), white]), const Color(0xFF1E88E5));
    expect(ArtTheme.contrastingAway(red, const [darkRed]), darkRed, reason: 'sem opção, fica a principal');
  });

  test('formatos: tamanho final exato e tamanho lógico ×3', () {
    expect([for (final f in ArtFormat.values) '${f.width}x${f.height}'],
        ['1080x1350', '1080x1920', '1080x1080', '1200x630']);
    expect(ArtFormat.landscape.logicalSize, const Size(400, 210));
    expect(ArtFormat.story.shape, ArtShape.tall);
  });

  test('dados do resultado: placar pela lista, vencedor, gols ordenados e 1º tempo', () {
    final data = _data();
    expect((data.homeGoals, data.awayGoals), (2, 1));
    expect(data.winner, ArtSide.home);
    expect(data.goals.map((g) => g.minute), [12, 70, 80]);
    expect(data.goalsOf(ArtSide.home).map((g) => g.scorer), ['Ana', 'Bia']);
    expect(data.halfTimeScore, (1, 0));
    expect(data.status, ArtMatchStatus.finished);
    expect(data.championship, 'Copa Sol');
    expect(data.championshipLogoUrl, 'https://x/logo.png');
    // Sem escudos cadastrados: o aviso da prévia.
    expect(data.missing, [ArtMissing.homeCrest, ArtMissing.awayCrest]);
  });

  test('empate, gol sem minuto (sem 1º tempo), amistoso e jogo futuro', () {
    final draw = _data(
      match: _match.copyWith(goals: const [
        MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'a', scorerName: 'Ana'),
        MatchGoal(id: 'b', side: MatchSide.away, scorerId: 'z', scorerName: 'Zé', minute: 30),
      ]),
    );
    expect(draw.winner, isNull);
    expect(draw.halfTimeScore, isNull);

    final friendly = _data(match: _match.copyWith(championshipId: 0));
    expect(friendly.championship, '');
    expect(friendly.championshipLogoUrl, '', reason: 'amistoso não tem logo de campeonato');

    final future = ResultArtData.of(
      const MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '20/12/2026', time: '16:00'),
      now: DateTime(2026, 12, 11),
    );
    expect(future.status, ArtMatchStatus.notStarted);
    expect(future.winner, isNull);
    expect(future.missing, containsAll([ArtMissing.venue, ArtMissing.homeCrest]));
  });

  test('iniciais do escudo substituto', () {
    expect(const ArtTeam(name: 'Lava Jato').initials, 'LJ');
    expect(const ArtTeam(name: 'Associação de Moradores').initials, 'AM');
    expect(const ArtTeam(name: 'Tigres').initials, 'T');
  });

  Widget host(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: Center(child: child)),
      );

  for (final template in ResultArtTemplate.values) {
    for (final format in ArtFormat.values) {
      testWidgets('modelo ${template.name} em ${format.name} sem estourar (nome longo, sem escudo)', (tester) async {
        tester.view.physicalSize = const Size(1600, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(host(ResultArt(data: _data(), template: template, format: format, showQr: true)));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('exporta o PNG no tamanho exato de cada formato', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final format in ArtFormat.values) {
      final key = GlobalKey();
      await tester.pumpWidget(host(FittedBox(
        child: RepaintBoundary(
          key: key,
          child: ResultArt(data: _data(), template: ResultArtTemplate.poster, format: format),
        ),
      )));
      await tester.pump();
      final png = await tester.runAsync(() => ArtExporter.capture(key, format));
      expect(png, isNotNull);
      // Cabeçalho PNG (IHDR): largura e altura em big-endian.
      final header = ByteData.sublistView(png!, 16, 24);
      expect((header.getUint32(0), header.getUint32(4)), (format.width, format.height), reason: format.name);
    }
  });
}
