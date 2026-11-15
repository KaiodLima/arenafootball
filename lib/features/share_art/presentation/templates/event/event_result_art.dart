import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/champion_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/podium_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/ranking_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Artes do resultado do evento de votação. Mesma superfície de tamanho fixo
// das outras artes: medidas proporcionais ao formato ([EventArtArgs.s]),
// fontes das artes (Anton + Barlow Condensed) e as cores da paleta.

/// Modelos da arte do resultado.
enum EventResultArtTemplate { champion, podium, ranking }

/// Paletas do evento: as fixas ("Times" não se aplica, não é de um time).
const List<ArtPalette> eventArtPalettes = [
  ArtPalette.arena,
  ArtPalette.night,
  ArtPalette.crimson,
  ArtPalette.ocean,
  ArtPalette.graphite,
];

/// Ouro, prata e bronze das posições.
const List<Color> eventMedalColors = [AppColors.gold, Color(0xFFCFD8DC), Color(0xFFCD8A4E)];

/// A arte do resultado no [template] e no [format] pedidos.
class EventResultArt extends StatelessWidget {
  final EventResultArtData data;
  final EventResultArtTemplate template;
  final ArtFormat format;
  final ArtColors colors;
  final bool showQr;

  const EventResultArt({
    super.key,
    required this.data,
    required this.template,
    required this.format,
    required this.colors,
    this.showQr = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = format.logicalSize;
    final args = EventArtArgs(
      data: data,
      format: format,
      colors: colors,
      qr: showQr && data.link.isNotEmpty ? data.link : null,
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            EventArtBackground(args),
            switch (template) {
              EventResultArtTemplate.champion => ChampionArt(args),
              EventResultArtTemplate.podium => PodiumArt(args),
              EventResultArtTemplate.ranking => RankingArt(args),
            },
          ],
        ),
      ),
    );
  }
}

/// O que os modelos recebem.
class EventArtArgs {
  final EventResultArtData data;
  final ArtFormat format;
  final ArtColors colors;
  final String? qr;

  const EventArtArgs({required this.data, required this.format, required this.colors, this.qr});

  Size get size => format.logicalSize;
  bool get wide => format == ArtFormat.landscape;
  bool get story => format == ArtFormat.story;
  bool get square => format == ArtFormat.square;

  /// Escala das medidas (360 de largura nos formatos em pé; altura na paisagem).
  double get s => wide ? size.height / 230 : size.width / 360;
}

/// Fundo: degradê radial da paleta, raios suaves e grão.
class EventArtBackground extends StatelessWidget {
  final EventArtArgs args;

  const EventArtBackground(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = args.colors;
    final center = args.wide ? const Alignment(-0.5, -0.1) : const Alignment(0, -0.35);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: center,
              radius: 1.05,
              colors: [c.base, Color.lerp(c.base, c.deep, 0.6)!, c.deep],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        CustomPaint(painter: _RaysPainter(center: center)),
        const ArtGrain(opacity: 0.05),
      ],
    );
  }
}

class _RaysPainter extends CustomPainter {
  final Alignment center;

  const _RaysPainter({required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final c = center.alongSize(size);
    final r = size.longestSide * 1.3;
    final paint = Paint()..color = AppColors.white.withValues(alpha: 0.04);
    const n = 20;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + r * math.cos(a), c.dy + r * math.sin(a))
          ..lineTo(c.dx + r * math.cos(a + math.pi / n), c.dy + r * math.sin(a + math.pi / n))
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) => oldDelegate.center != center;
}

/// Selo "🏆 RESULTADO" no destaque da paleta.
class EventArtSeal extends StatelessWidget {
  final EventArtArgs args;

  const EventArtSeal(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 3 * s),
      decoration: BoxDecoration(color: args.colors.accent, borderRadius: BorderRadius.circular(20 * s)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 11 * s, color: AppColors.black),
          SizedBox(width: 4 * s),
          Text(
            l10n.eventArtResultSeal,
            style: ArtFonts.textStyle(10 * s, AppColors.black, weight: FontWeight.w800, spacing: 1.6 * s),
          ),
        ],
      ),
    );
  }
}

/// Título do evento em Anton (encolhe para caber em [lines] linhas).
class EventArtTitle extends StatelessWidget {
  final EventArtArgs args;
  final double size;
  final TextAlign align;
  final int lines;

  const EventArtTitle(this.args, {super.key, required this.size, this.align = TextAlign.center, this.lines = 2});

  @override
  Widget build(BuildContext context) {
    return Text(
      args.data.title.toUpperCase(),
      textAlign: align,
      maxLines: lines,
      overflow: TextOverflow.ellipsis,
      style: ArtFonts.displayStyle(size * args.s, AppColors.white, height: 1.05, spacing: 0.4).copyWith(
        shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.4), offset: Offset(0, 2 * args.s))],
      ),
    );
  }
}

/// Rodapé: "10 votos · encerrado em 17/11" e a marca (com o QR).
class EventArtFooter extends StatelessWidget {
  final EventArtArgs args;
  final MainAxisAlignment alignment;

  const EventArtFooter(this.args, {super.key, this.alignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    final closedAt = args.data.closedAt;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final info = [
      l10n.eventPollVotesCount(args.data.total),
      if (closedAt != null) l10n.eventArtClosedOn(DateFormat('dd/MM', locale).format(closedAt)),
    ].join('  ·  ').toUpperCase();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == MainAxisAlignment.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Encolhe em vez de cortar (coluna estreita da paisagem).
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(info,
              maxLines: 1,
              style: ArtFonts.textStyle(10.5 * s, AppColors.white.withValues(alpha: 0.75), spacing: 1.2 * s)),
        ),
        SizedBox(height: 6 * s),
        ArtBranding(color: AppColors.white, scale: s, qrData: args.qr, alignment: alignment),
      ],
    );
  }
}

/// Foto da opção num quadrado arredondado com aro (sem foto, o número dela).
class EventArtPhoto extends StatelessWidget {
  final EventResultEntry entry;
  final double size;
  final Color ring;
  final double ringWidth;
  final ArtColors colors;

  const EventArtPhoto({
    super.key,
    required this.entry,
    required this.size,
    required this.ring,
    required this.colors,
    this.ringWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.2);
    final url = entry.option.imageUrl;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.base, colors.deep],
        ),
      ),
      child: Center(
        child: Text('${entry.number}', style: ArtFonts.displayStyle(size * 0.46, colors.accent)),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: ring,
        borderRadius: radius,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), blurRadius: size * 0.12)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(0, size * 0.2 - ringWidth)),
        child: url.isEmpty
            ? fallback
            : Image(
                image: EventArtPhoto.providerFor(url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }

  /// Trocável no teste (sem rede).
  static ImageProvider Function(String url) providerFor = (url) => CachedNetworkImageProvider(url);
}
