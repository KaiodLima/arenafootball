import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/domain/match_time.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/calendar_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/championship_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/matchday_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/scoreboard_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/ticket_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/versus_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Artes de divulgação (antes do jogo). Mesma superfície de tamanho fixo das
// de resultado: medidas proporcionais ao formato, fontes das artes.

/// Modelos da arte de divulgação.
enum PreviewArtTemplate { matchday, versus, calendar, championship, ticket, scoreboard }

/// A arte de divulgação no [template] e no [format] pedidos.
class PreviewArt extends StatelessWidget {
  final ResultArtData data;
  final PreviewArtTemplate template;
  final ArtFormat format;
  final bool showQr;

  /// Paleta escolhida (padrão: as cores dos times).
  final ArtPalette palette;

  /// Agora (só para teste): decide "É HOJE!" / "AMANHÃ" / dia da semana.
  final DateTime? now;

  const PreviewArt({
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
    final theme = ArtTheme.of(data.home, data.away);
    final args = PreviewArtArgs(
      data: data,
      format: format,
      theme: theme,
      palette: palette,
      colors: palette.resolve(theme),
      qr: showQr && data.link.isNotEmpty ? data.link : null,
      texts: PreviewArtTexts.of(AppLocalizations.of(context), data, now ?? DateTime.now()),
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: switch (template) {
          PreviewArtTemplate.matchday => MatchdayArt(args),
          PreviewArtTemplate.versus => VersusArt(args),
          PreviewArtTemplate.calendar => CalendarArt(args),
          PreviewArtTemplate.championship => ChampionshipArt(args),
          PreviewArtTemplate.ticket => TicketArt(args),
          PreviewArtTemplate.scoreboard => ScoreboardArt(args),
        },
      ),
    );
  }
}

/// O que os modelos de divulgação recebem.
class PreviewArtArgs {
  final ResultArtData data;
  final ArtFormat format;
  final ArtTheme theme;
  final String? qr;
  final PreviewArtTexts texts;

  /// Paleta escolhida e as cores resolvidas dela.
  final ArtPalette palette;
  final ArtColors colors;

  const PreviewArtArgs({
    required this.data,
    required this.format,
    required this.theme,
    this.palette = ArtPalette.teams,
    this.colors = const ArtColors(
      base: Color(0xFF1B5E20),
      deep: Color(0xFF0A1F0C),
      accent: Color(0xFFFFC107),
      accent2: Color(0xFF46E86A),
    ),
    required this.qr,
    required this.texts,
  });

  Size get size => format.logicalSize;
  bool get story => format == ArtFormat.story;
  bool get square => format == ArtFormat.square;
  bool get wide => format == ArtFormat.landscape;
  String get logoUrl => data.championshipLogoUrl;

  /// Paleta das cores dos times (os modelos de metades usam as cores deles).
  bool get teamColors => palette == ArtPalette.teams;
}

/// Textos prontos da divulgação (idioma do app, datas de Brasília).
class PreviewArtTexts {
  /// "É HOJE!" / "AMANHÃ" / "SÁBADO" (até 6 dias) / "PRÓXIMO JOGO".
  final String headline;

  /// "SÁB · 15/11" (vazio sem data).
  final String shortDate;

  /// Folha de calendário: "SÁBADO", "15", "NOV" (vazios sem data).
  final String weekday;
  final String day;
  final String month;

  /// "18:00" (vazio sem horário).
  final String time;

  /// Local ou "LOCAL A DEFINIR".
  final String venue;

  /// "COPA SOL" / "AMISTOSO".
  final String championship;
  final String callToAction;

  /// "PRÓXIMO JOGO" (título quando o dia da semana já aparece na arte).
  final String nextMatch;

  /// Contagem regressiva: "HOJE", "AMANHÃ", "FALTAM 5 DIAS" (até 30 dias);
  /// vazio sem data, longe demais ou no passado.
  final String countdown;

  /// Rótulos do ingresso: "INGRESSO", "DATA", "HORÁRIO", "LOCAL".
  final String ticketLabel;
  final String dateLabel;
  final String timeLabel;
  final String venueLabel;

  /// Data "15/11/2026" (vazio sem data).
  final String fullDate;

  const PreviewArtTexts({
    required this.headline,
    required this.shortDate,
    required this.weekday,
    required this.day,
    required this.month,
    required this.time,
    required this.venue,
    required this.championship,
    required this.callToAction,
    required this.nextMatch,
    this.countdown = '',
    this.ticketLabel = '',
    this.dateLabel = '',
    this.timeLabel = '',
    this.venueLabel = '',
    this.fullDate = '',
  });

  factory PreviewArtTexts.of(AppLocalizations l10n, ResultArtData data, DateTime now) {
    final day = data.matchDay;
    final today = MatchTime.today(now);
    final diff = day == null
        ? null
        : DateTime.utc(day.year, day.month, day.day)
            .difference(DateTime.utc(today.year, today.month, today.day))
            .inDays;
    final weekday = day == null ? '' : l10n.shareArtWeekday('${day.weekday}');
    final headline = switch (diff) {
      0 => l10n.shareArtToday,
      1 => l10n.matchCardTomorrow,
      final d? when d > 1 && d < 7 => weekday,
      _ => l10n.shareArtNextMatch,
    };
    String two(int v) => v.toString().padLeft(2, '0');
    return PreviewArtTexts(
      headline: headline.toUpperCase(),
      shortDate: day == null
          ? ''
          : '${l10n.shareArtWeekdayShort('${day.weekday}')}  ·  ${two(day.day)}/${two(day.month)}'.toUpperCase(),
      weekday: weekday.toUpperCase(),
      day: day == null ? '' : two(day.day),
      month: day == null ? '' : l10n.shareArtMonth('${day.month}').toUpperCase(),
      time: data.time.trim(),
      venue: (data.venue.isEmpty ? l10n.shareArtVenueTbd : data.venue).toUpperCase(),
      championship: (data.championship.isEmpty ? l10n.resultCardFriendly : data.championship).toUpperCase(),
      callToAction: l10n.shareArtCallToAction,
      nextMatch: l10n.shareArtNextMatch.toUpperCase(),
      countdown: switch (diff) {
        0 => l10n.shareArtToday2,
        1 => l10n.matchCardTomorrow,
        final d? when d > 1 && d <= 30 => l10n.shareArtDaysLeft(d),
        _ => '',
      }
          .toUpperCase(),
      ticketLabel: l10n.shareArtTicketLabel.toUpperCase(),
      dateLabel: l10n.shareArtDateLabel.toUpperCase(),
      timeLabel: l10n.shareArtTimeLabel.toUpperCase(),
      venueLabel: l10n.shareArtVenueLabel.toUpperCase(),
      fullDate: day == null ? '' : '${two(day.day)}/${two(day.month)}/${day.year}',
    );
  }
}
