import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/domain/match_time.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/player_match_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/agenda_player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/countdown_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/cover_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/duel_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/lineup_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/spotlight_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Artes do atleta na partida que vai acontecer: o foco é o atleta, com o
// confronto, o dia e o horário. Mesma superfície de tamanho fixo das outras.

/// Modelos da arte do atleta na partida.
enum PlayerMatchArtTemplate { cover, countdown, agenda, duel, lineup, spotlight }

class PlayerMatchArt extends StatelessWidget {
  final PlayerMatchArtData data;
  final PlayerMatchArtTemplate template;
  final ArtFormat format;
  final bool showQr;
  final ArtPalette palette;

  /// "Agora" para os títulos pela data (testes).
  final DateTime? now;

  const PlayerMatchArt({
    super.key,
    required this.data,
    required this.template,
    required this.format,
    this.showQr = false,
    this.palette = ArtPalette.teams,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final size = format.logicalSize;
    final l10n = AppLocalizations.of(context);
    // Tema: o time do atleta como "casa", o adversário contrastando.
    final theme = ArtTheme.of(data.team, data.opponent);
    final args = PlayerMatchArtArgs(
      data: data,
      format: format,
      theme: theme,
      palette: palette,
      colors: palette.resolve(theme),
      qr: showQr && data.player.link.isNotEmpty ? data.player.link : null,
      texts: PlayerMatchArtTexts.of(l10n, data, now ?? DateTime.now()),
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: switch (template) {
          PlayerMatchArtTemplate.cover => CoverArt(args),
          PlayerMatchArtTemplate.countdown => CountdownArt(args),
          PlayerMatchArtTemplate.agenda => AgendaPlayerArt(args),
          PlayerMatchArtTemplate.duel => DuelArt(args),
          PlayerMatchArtTemplate.lineup => LineupArt(args),
          PlayerMatchArtTemplate.spotlight => SpotlightArt(args),
        },
      ),
    );
  }
}

/// O que os modelos do atleta na partida recebem.
class PlayerMatchArtArgs {
  final PlayerMatchArtData data;
  final ArtFormat format;
  final ArtTheme theme;
  final ArtPalette palette;
  final ArtColors colors;
  final String? qr;
  final PlayerMatchArtTexts texts;

  const PlayerMatchArtArgs({
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

  /// Cor do time do atleta e a do adversário.
  Color get teamColor => theme.home;
  Color get opponentColor => theme.away;
}

/// Textos prontos (idioma do app): os do atleta + os da partida.
class PlayerMatchArtTexts {
  final PlayerArtTexts player;
  final PreviewArtTexts match;

  /// "DIA DE JOGO".
  final String matchday;

  /// "NA ESCALAÇÃO!".
  final String lineup;

  /// Contagem: "2" + "DIAS PARA O JOGO"; no dia, "HOJE" + "É DIA DE JOGO";
  /// sem data ou longe demais, o título do dia + "DIA DE JOGO".
  final String countdownNumber;
  final String countdownLabel;

  /// O número é um dígito (fonte gigante) ou uma palavra ("HOJE")?
  final bool countdownIsNumber;

  /// "RONALDO TE ESPERA".
  final String waiting;

  /// "VEM PRO JOGO!".
  final String comeWatch;
  final String team;
  final String opponent;

  const PlayerMatchArtTexts({
    required this.player,
    required this.match,
    required this.matchday,
    this.lineup = '',
    required this.countdownNumber,
    required this.countdownLabel,
    this.countdownIsNumber = false,
    required this.waiting,
    required this.comeWatch,
    required this.team,
    required this.opponent,
  });

  /// "18:00  ·  CAMPO DO IPÊ" (o que houver).
  String get whenWhere => [if (match.time.isNotEmpty) match.time, match.venue].join('  ·  ');

  factory PlayerMatchArtTexts.of(AppLocalizations l10n, PlayerMatchArtData data, DateTime now) {
    final first = data.player.firstName.isNotEmpty ? data.player.firstName : data.player.name.trim();
    final match = PreviewArtTexts.of(l10n, data.match, now);
    final matchday = l10n.playerMatchArtMatchday.toUpperCase();
    final days = daysToGo(data.match.matchDay, now);
    final (number, label, isNumber) = switch (days) {
      0 => (l10n.shareArtToday2.toUpperCase(), matchday, false),
      final d? when d > 0 && d <= 30 => ('$d', l10n.playerMatchArtDaysToGo(d).toUpperCase(), true),
      _ => (match.headline, matchday, false),
    };
    return PlayerMatchArtTexts(
      player: PlayerArtTexts.of(l10n, data.player),
      match: match,
      matchday: matchday,
      lineup: l10n.playerMatchArtLineup.toUpperCase(),
      countdownNumber: number,
      countdownLabel: label,
      countdownIsNumber: isNumber,
      waiting: l10n.playerMatchArtWaiting(first).toUpperCase(),
      comeWatch: l10n.playerMatchArtComeWatch.toUpperCase(),
      team: data.team.name.trim().toUpperCase(),
      opponent: data.opponent.name.trim().toUpperCase(),
    );
  }

  /// Dias até a partida pelo dia de Brasília (nulo sem data; negativo = passou).
  static int? daysToGo(DateTime? day, DateTime now) {
    if (day == null) return null;
    final today = MatchTime.today(now);
    return DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(today.year, today.month, today.day))
        .inDays;
  }
}
