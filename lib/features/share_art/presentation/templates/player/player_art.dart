import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/player_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/card_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/deal_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/impact_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_poster_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/signing_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Artes de anúncio do atleta pela equipe. Mesma superfície de tamanho fixo
// das de partida: medidas proporcionais ao formato, fontes das artes.

/// Modelos da arte do atleta.
enum PlayerArtTemplate { signing, deal, impact, card, poster }

/// A arte do atleta no [template] e no [format] pedidos.
class PlayerArt extends StatelessWidget {
  final PlayerArtData data;
  final PlayerArtTemplate template;
  final ArtFormat format;
  final bool showQr;
  final ArtPalette palette;

  const PlayerArt({
    super.key,
    required this.data,
    required this.template,
    required this.format,
    this.showQr = false,
    this.palette = ArtPalette.teams,
  });

  @override
  Widget build(BuildContext context) {
    final size = format.logicalSize;
    // O tema de duas cores do time: a principal e a secundária.
    final theme = ArtTheme.of(data.team, data.team);
    final args = PlayerArtArgs(
      data: data,
      format: format,
      theme: theme,
      palette: palette,
      colors: palette.resolve(theme),
      qr: showQr && data.link.isNotEmpty ? data.link : null,
      texts: PlayerArtTexts.of(AppLocalizations.of(context), data),
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: switch (template) {
          PlayerArtTemplate.signing => SigningArt(args),
          PlayerArtTemplate.deal => DealArt(args),
          PlayerArtTemplate.impact => ImpactArt(args),
          PlayerArtTemplate.card => CardArt(args),
          PlayerArtTemplate.poster => PlayerPosterArt(args),
        },
      ),
    );
  }
}

/// O que os modelos do atleta recebem.
class PlayerArtArgs {
  final PlayerArtData data;
  final ArtFormat format;
  final ArtTheme theme;
  final ArtPalette palette;
  final ArtColors colors;
  final String? qr;
  final PlayerArtTexts texts;

  const PlayerArtArgs({
    required this.data,
    required this.format,
    required this.theme,
    required this.palette,
    required this.colors,
    required this.qr,
    required this.texts,
  });

  Size get size => format.logicalSize;
  bool get story => format == ArtFormat.story;
  bool get square => format == ArtFormat.square;
  bool get wide => format == ArtFormat.landscape;
  bool get teamColors => palette == ArtPalette.teams;

  /// Cor do time (escudo, faixas).
  Color get teamColor => theme.home;
}

/// Textos prontos da arte do atleta (idioma do app).
class PlayerArtTexts {
  /// "REFORÇO".
  final String headline;

  /// "BEM-VINDO AO LAVA JATO".
  final String welcome;

  /// "É DO LAVA JATO!".
  final String deal;

  /// "ANÚNCIO OFICIAL".
  final String official;

  /// "ATACANTE" (vazio sem posição).
  final String position;

  /// "COPA SOL" (vazio = geral).
  final String championship;
  final String team;
  final String goalsLabel;
  final String assistsLabel;

  /// "LAVA JATO FC APRESENTA".
  final String presents;

  /// "NOVO REFORÇO".
  final String newSigning;

  /// "FECHADO!" (carimbo).
  final String closed;

  /// "ESTREIA" (carta sem números).
  final String debut;

  /// Sigla da posição ("ATA"; vazio sem posição).
  final String positionAbbr;

  const PlayerArtTexts({
    required this.headline,
    required this.welcome,
    required this.deal,
    required this.official,
    required this.position,
    required this.championship,
    required this.team,
    required this.goalsLabel,
    required this.assistsLabel,
    this.presents = '',
    this.newSigning = '',
    this.debut = '',
    this.closed = '',
    this.positionAbbr = '',
  });

  factory PlayerArtTexts.of(AppLocalizations l10n, PlayerArtData data) {
    final position = PlayerPosition.fromKey(data.positionKey);
    final team = data.team.name.trim();
    return PlayerArtTexts(
      headline: l10n.playerArtHeadline.toUpperCase(),
      welcome: l10n.playerArtWelcome(team).toUpperCase(),
      deal: l10n.playerArtDeal(team).toUpperCase(),
      official: l10n.playerArtOfficial.toUpperCase(),
      position: position == null ? '' : playerPositionLabel(l10n, position).toUpperCase(),
      championship: data.championship.toUpperCase(),
      team: team.toUpperCase(),
      goalsLabel: l10n.playersSummaryGoals.toUpperCase(),
      assistsLabel: l10n.playersSummaryAssists.toUpperCase(),
      presents: l10n.playerArtPresents(team).toUpperCase(),
      newSigning: l10n.playerArtNewSigning.toUpperCase(),
      debut: l10n.playerArtDebut.toUpperCase(),
      closed: l10n.playerArtTemplateDeal.toUpperCase(),
      positionAbbr: position == null ? '' : playerPositionAbbr(l10n, position),
    );
  }
}

/// Sigla da posição (carta do atleta).
String playerPositionAbbr(AppLocalizations l10n, PlayerPosition position) => switch (position) {
      PlayerPosition.goalkeeper => l10n.playerArtAbbrGoalkeeper,
      PlayerPosition.defender => l10n.playerArtAbbrDefender,
      PlayerPosition.fullBack => l10n.playerArtAbbrFullBack,
      PlayerPosition.defensiveMidfielder => l10n.playerArtAbbrDefensiveMidfielder,
      PlayerPosition.midfielder => l10n.playerArtAbbrMidfielder,
      PlayerPosition.forward => l10n.playerArtAbbrForward,
    };
