// Prévia visual das artes (fora da suíte normal): grava os PNGs em
// build/art_previews/ com as fontes de verdade. Rodar com:
//   ART_PREVIEW=1 flutter test test/features/share_art/art_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/art_exporter.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

/// Logo de teste: um brasão redondo (verde, aro dourado e estrela).
Future<Uint8List> _testLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const c = Offset(128, 128);
  canvas.drawCircle(c, 124, Paint()..color = const Color(0xFFC9A227));
  canvas.drawCircle(c, 108, Paint()..color = const Color(0xFF1B5E20));
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? 70.0 : 30.0;
    final a = -1.5708 + i * 3.14159 / 5;
    final p = c + Offset(r * _cos(a), r * _sin(a));
    i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(star..close(), Paint()..color = const Color(0xFFFFD54F));
  final image = await recorder.endRecording().toImage(256, 256);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

double _cos(double a) => Offset.fromDirection(a).dx;
double _sin(double a) => Offset.fromDirection(a).dy;

void main() {
  final enabled = Platform.environment['ART_PREVIEW'] == '1';

  testWidgets('prévias das artes de resultado', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-ExtraBoldItalic.ttf',
      ]);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    final logo = MemoryImage((await tester.runAsync(_testLogo))!);
    ArtChampionshipLogo.providerFor = (_) => logo;
    final data = ResultArtData.of(
      const MatchDTO(
        id: 'm1',
        homeTeam: 'Lava Jato FC',
        awayTeam: 'Volta Redonda',
        homeTeamId: 't1',
        awayTeamId: 't2',
        date: '10/12/2026',
        time: '16:00',
        venue: 'Arena Orlandão',
        championshipId: 11,
        manualStatus: MatchManualStatus.finished,
        goals: [
          MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'a', scorerName: 'Ronaldo Lima', minute: 12),
          MatchGoal(id: 'b', side: MatchSide.away, scorerId: 'b', scorerName: 'Dudu', minute: 34),
          MatchGoal(id: 'c', side: MatchSide.home, scorerId: 'c', scorerName: 'Caio Fernandes', minute: 78),
        ],
      ),
      homeTeam: const TeamDTO(id: 't1', name: 'Lava Jato FC', primaryColor: '#D32F2F', secondaryColor: '#FFFFFF'),
      awayTeam: const TeamDTO(id: 't2', name: 'Volta Redonda', primaryColor: '#1E88E5', secondaryColor: '#FFFFFF'),
      championship: 'Copa da Floresta 2026',
      championshipLogoUrl: 'memoria://logo',
      link: 'https://arenasoccerflutter.web.app/noticia/resultado_m1',
      now: DateTime(2026, 12, 11),
    );
    // Time branco + empate (contraste e placar sem vencedor).
    final draw = ResultArtData.of(
      const MatchDTO(
        id: 'm2',
        homeTeam: 'Santos do Vale',
        awayTeam: 'Floresta EC',
        date: '11/12/2026',
        time: '19:30',
        venue: 'Campo do Ipê',
        championshipId: 11,
        manualStatus: MatchManualStatus.finished,
        goals: [
          MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'a', scorerName: 'Neto', minute: 51),
          MatchGoal(id: 'b', side: MatchSide.away, scorerId: 'b', scorerName: 'Tiago Souza', minute: 88),
        ],
      ),
      homeTeam: const TeamDTO(id: 't3', name: 'Santos do Vale', primaryColor: '#FFFFFF', secondaryColor: '#111111'),
      awayTeam: const TeamDTO(id: 't4', name: 'Floresta EC', primaryColor: '#2E7D32', secondaryColor: '#FFFFFF'),
      championship: 'Copa da Floresta 2026',
      now: DateTime(2026, 12, 12),
    );
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Directory('build/art_previews').createSync(recursive: true);
    final formats = (Platform.environment['ART_FORMATS'] ?? 'feed,landscape').split(',');
    final cases = [
      for (final template in ResultArtTemplate.values) (template, data, ''),
      (ResultArtTemplate.vibrant, draw, '_draw'),
    ];
    for (final (template, data, suffix) in cases) {
      for (final format in ArtFormat.values.where((f) => formats.contains(f.name))) {
        final key = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: ResultArt(data: data, template: template, format: format, showQr: true),
              ),
            ),
          ),
        ));
        // A logo só aparece carregada: decodifica fora do relógio falso.
        final element = tester.element(find.byKey(key));
        await tester.runAsync(() => precacheImage(logo, element));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '${template.name}/${format.name}');
        final png = await tester.runAsync(() => ArtExporter.capture(key, format));
        File('build/art_previews/${template.name}_${format.name}$suffix.png').writeAsBytesSync(png!);
      }
    }
    // Divulgação (antes do jogo): sábado 15/11, vista na quinta 13/11.
    ResultArtData upcomingWith(String logo) => ResultArtData.of(
          const MatchDTO(
            id: 'm3',
            homeTeam: 'Mulekada',
            awayTeam: 'Açaí No Gralle',
            homeTeamId: 't1',
            awayTeamId: 't2',
            date: '15/11/2026',
            time: '18:00',
            venue: 'Campo do Ipê',
            championshipId: 11,
          ),
          homeTeam: const TeamDTO(id: 't1', name: 'Mulekada', primaryColor: '#111111', secondaryColor: '#FFFFFF'),
          awayTeam: const TeamDTO(id: 't2', name: 'Açaí No Gralle', primaryColor: '#6A1B9A', secondaryColor: '#FFFFFF'),
          championship: 'Copa Açaí de Futsal',
          championshipLogoUrl: logo,
          link: 'https://arenasoccerflutter.web.app/app',
          now: DateTime.utc(2026, 11, 13, 15),
        );
    final previewCases = [
      for (final template in PreviewArtTemplate.values) (template, upcomingWith('memoria://logo'), ''),
      // Os modelos que mais usam a logo, também sem ela.
      for (final template in [
        PreviewArtTemplate.championship,
        PreviewArtTemplate.ticket,
        PreviewArtTemplate.versus,
        PreviewArtTemplate.scoreboard
      ])
        (template, upcomingWith(''), '_semlogo'),
    ];
    // Paletas fixas em alguns modelos.
    final paletteCases = [
      (PreviewArtTemplate.championship, ArtPalette.night),
      (PreviewArtTemplate.ticket, ArtPalette.crimson),
      (PreviewArtTemplate.scoreboard, ArtPalette.ocean),
      (PreviewArtTemplate.matchday, ArtPalette.graphite),
      (PreviewArtTemplate.versus, ArtPalette.night),
    ];
    final allCases = [
      for (final (t, d, suffix) in previewCases) (t, d, suffix, ArtPalette.teams),
      for (final (t, p) in paletteCases) (t, upcomingWith('memoria://logo'), '_${p.name}', p),
    ];
    for (final (template, upcoming, suffix, palette) in allCases) {
      for (final format in ArtFormat.values.where((f) => formats.contains(f.name))) {
        final key = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: PreviewArt(
                  data: upcoming,
                  template: template,
                  format: format,
                  showQr: true,
                  palette: palette,
                  now: DateTime.utc(2026, 11, 13, 15),
                ),
              ),
            ),
          ),
        ));
        final element = tester.element(find.byKey(key));
        await tester.runAsync(() => precacheImage(logo, element));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'preview ${template.name}/${format.name}');
        final png = await tester.runAsync(() => ArtExporter.capture(key, format));
        File('build/art_previews/preview_${template.name}_${format.name}$suffix.png').writeAsBytesSync(png!);
      }
    }
  }, skip: !enabled);
}
