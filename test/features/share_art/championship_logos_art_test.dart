import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/player_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/player_match_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// As 2 logos do campeonato (`logosArte`) em destaque: todos os modelos das
// artes de jogos desenham sem estouro com as duas carregadas (imagem em memória).

final _now = DateTime.utc(2026, 11, 13, 15);
const _logos = ['memoria://logo1', 'memoria://logo2'];

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Associação Atlética Floresta do Vale Unidos',
  awayTeam: 'Esporte Clube Santo Inácio de Loyola',
  homeTeamId: 't1',
  awayTeamId: 't2',
  date: '15/11/2026',
  time: '18:00',
  venue: 'Estádio Municipal Professor Doutor Fulano de Tal',
  championshipId: 11,
);

ResultArtData _data() => ResultArtData.of(
      _match,
      homeTeam: const TeamDTO(id: 't1', name: 'Associação Atlética Floresta do Vale Unidos', primaryColor: '#D32F2F'),
      awayTeam: const TeamDTO(id: 't2', name: 'Esporte Clube Santo Inácio de Loyola', primaryColor: '#1E88E5'),
      championship: 'Campeonato Intermunicipal de Futebol Amador',
      championshipLogos: _logos,
      link: 'https://arenasoccerflutter.web.app/app',
      now: _now,
    );

const _player = PlayerDTO(
  id: 'p1',
  name: 'Maximiliano Bartolomeu Constantino',
  team: 'Esporte Clube Santo Inácio de Loyola',
  teamId: 't2',
  position: 'atacante',
  enrollments: [PlayerEnrollment(championshipId: 11, teamId: 't2', team: 'Esporte Clube Santo Inácio de Loyola')],
  hasEnrollmentField: true,
);

/// Logo de teste (quadrado colorido em PNG).
Future<MemoryImage> _logo() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawCircle(const Offset(32, 32), 30, Paint()..color = const Color(0xFF1B5E20));
  final image = await recorder.endRecording().toImage(64, 64);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(bytes!.buffer.asUint8List());
}

void main() {
  test('dados: as 2 logos chegam às artes do jogo e do atleta', () {
    expect(_data().championshipLogos, _logos);
    expect(_data().championshipLogoUrl, _logos.first);
    const championship = ChampionshipDTO(id: 'c', championshipId: 11, title: 'Copa', artLogos: _logos);
    final player = PlayerArtData.of(
        player: _player, team: const TeamDTO(id: 't2', name: 'X'), season: '2026', championship: championship);
    expect(player.championshipLogos, _logos);
    final playerMatch = PlayerMatchArtData.of(
        player: _player, match: _data(), side: MatchSide.away, championshipId: 11, season: '2026');
    expect(playerMatch.player.championshipLogos, _logos);
  });

  testWidgets('todos os modelos x formatos com as 2 logos carregadas, sem estouro', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final logo = (await tester.runAsync(_logo))!;
    final previous = ArtChampionshipLogo.providerFor;
    ArtChampionshipLogo.providerFor = (_) => logo;
    addTearDown(() => ArtChampionshipLogo.providerFor = previous);

    final data = _data();
    const championship = ChampionshipDTO(
        id: 'c', championshipId: 11, title: 'Campeonato Intermunicipal de Futebol Amador', artLogos: _logos);
    final playerData = PlayerArtData.of(
      player: _player,
      team: const TeamDTO(id: 't2', name: 'Esporte Clube Santo Inácio de Loyola', primaryColor: '#1E88E5'),
      season: '2026',
      championship: championship,
    );
    final playerMatch =
        PlayerMatchArtData.of(player: _player, match: data, side: MatchSide.away, championshipId: 11, season: '2026');
    final key = GlobalKey();
    final failures = <String>[];

    Future<void> check(String name, Widget art) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: Center(child: KeyedSubtree(key: key, child: art))),
      ));
      // A logo só aparece carregada: decodifica fora do relógio falso.
      await tester.runAsync(() => precacheImage(logo, key.currentContext!));
      await tester.pump();
      final error = tester.takeException();
      if (error != null) failures.add('$name: $error');
    }

    for (final format in ArtFormat.values) {
      for (final template in ResultArtTemplate.values) {
        await check('resultado ${template.name}/${format.name}',
            ResultArt(data: data, template: template, format: format, showQr: true));
      }
      for (final template in PreviewArtTemplate.values) {
        await check('divulgação ${template.name}/${format.name}',
            PreviewArt(data: data, template: template, format: format, showQr: true, now: _now));
      }
      for (final template in PlayerArtTemplate.values) {
        await check('atleta ${template.name}/${format.name}',
            PlayerArt(data: playerData, template: template, format: format, palette: ArtPalette.teams, showQr: true));
      }
      for (final template in PlayerMatchArtTemplate.values) {
        await check(
            'atleta na partida ${template.name}/${format.name}',
            PlayerMatchArt(
                data: playerMatch,
                template: template,
                format: format,
                palette: ArtPalette.teams,
                showQr: true,
                now: _now));
      }
    }
    expect(failures, isEmpty);
  });
}
