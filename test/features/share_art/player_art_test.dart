import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/player_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/bloc/player_art_cubit.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/l10n/app_localizations_pt.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

const _team = TeamDTO(id: 't1', name: 'Lava Jato FC', primaryColor: '#D32F2F', secondaryColor: '#FFFFFF');

const _player = PlayerDTO(
  id: 'p1',
  name: 'Ronaldo Nazário Lima',
  team: 'Lava Jato FC',
  teamId: 't1',
  goals: 7,
  assists: 0,
  position: 'atacante',
  enrollments: [PlayerEnrollment(championshipId: 11, teamId: 't1', team: 'Lava Jato FC', goals: 3, assists: 2)],
  hasEnrollmentField: true,
);

const _championship = ChampionshipDTO(id: 'c', championshipId: 11, title: 'Copa da Floresta', imageUrl: ' ');

void main() {
  test('nome dividido, números do geral e link do atleta', () {
    final data = PlayerArtData.of(player: _player, team: _team, season: '2026');
    expect(data.firstName, 'Ronaldo');
    expect(data.highlightName, 'Nazário Lima');
    expect(data.initials, isNotEmpty);
    expect((data.goals, data.assists), (7, 0));
    expect(data.championship, '');
    expect(data.link, athleteLink('2026', 'p1'));
    expect(data.team.name, 'Lava Jato FC');
  });

  test('com a competição: os números da inscrição, sem logo em branco', () {
    final data = PlayerArtData.of(player: _player, team: _team, season: '2026', championship: _championship);
    expect((data.goals, data.assists), (3, 2));
    expect(data.championship, 'Copa da Floresta');
    expect(data.championshipLogoUrl, '');
  });

  test('nome só e sem id: destaque = nome inteiro, link do app', () {
    final data = PlayerArtData.of(player: const PlayerDTO(name: 'Dudu', team: ''), team: _team, season: '2026');
    expect(data.firstName, '');
    expect(data.highlightName, 'Dudu');
    expect(data.link, appLink);
  });

  test('siglas das posições e textos dos modelos novos', () {
    final l10n = AppLocalizationsPt();
    expect(PlayerPosition.values.map((p) => playerPositionAbbr(l10n, p)), ['GOL', 'ZAG', 'LAT', 'VOL', 'MEI', 'ATA']);
    final texts = PlayerArtTexts.of(l10n, PlayerArtData.of(player: _player, team: _team, season: '2026'));
    expect((texts.positionAbbr, texts.presents, texts.newSigning, texts.closed),
        ('ATA', 'LAVA JATO FC APRESENTA', 'NOVO REFORÇO', 'FECHADO!'));
  });

  test('cubit: escolhas da arte', () {
    final cubit = PlayerArtCubit(PlayerArtData.of(player: _player, team: _team, season: '2026'));
    expect(cubit.state.template, PlayerArtTemplate.signing);
    cubit
      ..selectTemplate(PlayerArtTemplate.poster)
      ..selectPalette(ArtPalette.night)
      ..selectFormat(ArtFormat.story)
      ..toggleQr(false);
    expect(
      (cubit.state.template, cubit.state.palette, cubit.state.format, cubit.state.showQr),
      (PlayerArtTemplate.poster, ArtPalette.night, ArtFormat.story, false),
    );
    cubit.close();
  });

  testWidgets('3 modelos x 4 formatos x paletas sem estouro (nome longo, sem foto/escudo)', (tester) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cases = [
      PlayerArtData.of(player: _player, team: _team, season: '2026', championship: _championship),
      PlayerArtData.of(
        player: const PlayerDTO(
          id: 'p2',
          name: 'Maximiliano Bartolomeu Constantino Fernandes de Albuquerque',
          team: '',
          goals: 120,
          assists: 98,
        ),
        team: const TeamDTO(id: 't2', name: 'Associação Atlética Floresta do Vale Unidos', primaryColor: '#FFFFFF'),
        season: '2026',
        championship: const ChampionshipDTO(id: 'c2', championshipId: 3, title: 'Campeonato Intermunicipal de Futebol Amador'),
      ),
      PlayerArtData.of(player: const PlayerDTO(name: 'Dudu', team: ''), team: const TeamDTO(id: '', name: 'X'), season: '2026'),
    ];
    for (final data in cases) {
      for (final template in PlayerArtTemplate.values) {
        for (final format in ArtFormat.values) {
          for (final palette in [ArtPalette.teams, ArtPalette.night]) {
            await tester.pumpWidget(MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('pt'),
              home: Scaffold(
                body: Center(
                  child: PlayerArt(data: data, template: template, format: format, palette: palette, showQr: true),
                ),
              ),
            ));
            expect(tester.takeException(), isNull, reason: '${data.name}/${template.name}/${format.name}/${palette.name}');
          }
        }
      }
    }
  });
}
