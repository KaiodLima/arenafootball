import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/domain/fantasy_round_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_mvp_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_podium_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Artes dos "Craques da rodada" do Arena Fantasy (link no QR leva ao Fantasy
// do campeonato). Mesma superfície de tamanho fixo das outras artes: medidas
// proporcionais ([FantasyArtArgs.s]), fontes Anton + Barlow Condensed, fundo e
// paletas da arte do evento.

/// Modelos da arte dos craques da rodada.
enum FantasyRoundArtTemplate { podium, mvp }

/// Paletas fixas (as mesmas do evento: não é de um time só).
const List<ArtPalette> fantasyArtPalettes = eventArtPalettes;

/// A arte no [template] e no [format] pedidos.
class FantasyRoundArt extends StatelessWidget {
  final FantasyRoundArtData data;
  final FantasyRoundArtTemplate template;
  final ArtFormat format;
  final ArtColors colors;
  final bool showQr;

  const FantasyRoundArt({
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
    final args = FantasyArtArgs(
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
            // O fundo da arte do evento (degradê, raios e grão): só usa as cores e o formato.
            EventArtBackground(EventArtArgs(
              data: const EventResultArtData(eventId: '', title: ''),
              format: format,
              colors: colors,
            )),
            switch (template) {
              FantasyRoundArtTemplate.podium => FantasyPodiumArt(args),
              FantasyRoundArtTemplate.mvp => FantasyMvpArt(args),
            },
          ],
        ),
      ),
    );
  }
}

/// O que os modelos recebem.
class FantasyArtArgs {
  final FantasyRoundArtData data;
  final ArtFormat format;
  final ArtColors colors;
  final String? qr;

  const FantasyArtArgs({required this.data, required this.format, required this.colors, this.qr});

  Size get size => format.logicalSize;
  bool get wide => format == ArtFormat.landscape;
  bool get story => format == ArtFormat.story;
  bool get square => format == ArtFormat.square;

  /// Escala das medidas (360 de largura em pé; altura na paisagem).
  double get s => wide ? size.height / 230 : size.width / 360;

  /// Ouro, prata e bronze pela colocação.
  Color medalOf(FantasyNewsAthlete athlete) => eventMedalColors[(athlete.rank - 1).clamp(0, 2)];
}

/// Selo "ARENA FANTASY · RODADA N".
class FantasyArtSeal extends StatelessWidget {
  final FantasyArtArgs args;

  const FantasyArtSeal(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    // Encolhe em vez de estourar (coluna estreita da paisagem).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9 * s, vertical: 3 * s),
        decoration: BoxDecoration(color: args.colors.accent, borderRadius: BorderRadius.circular(20 * s)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer_rounded, size: 11 * s, color: AppColors.black),
            SizedBox(width: 4 * s),
            Text(
              l10n.fantasyCardBadge(args.data.round).toUpperCase(),
              style: ArtFonts.textStyle(10 * s, AppColors.black, weight: FontWeight.w800, spacing: 1.4 * s),
            ),
          ],
        ),
      ),
    );
  }
}

/// "CRAQUES DA RODADA" em Anton e o campeonato embaixo.
class FantasyArtTitle extends StatelessWidget {
  final FantasyArtArgs args;
  final double size;
  final TextAlign align;

  const FantasyArtTitle(this.args, {super.key, required this.size, this.align = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    final start = align == TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: start ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.fantasyCardTitle.toUpperCase(),
          textAlign: align,
          maxLines: 2,
          style: ArtFonts.displayStyle(size * s, AppColors.white, height: 1.02, spacing: 0.4).copyWith(
            shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.4), offset: Offset(0, 2 * s))],
          ),
        ),
        if (args.data.championship.isNotEmpty) ...[
          SizedBox(height: 2 * s),
          Text(
            args.data.championship.toUpperCase(),
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(12 * s, args.colors.accent, weight: FontWeight.w800, spacing: 1.2 * s),
          ),
        ],
      ],
    );
  }
}

/// Rodapé: a chamada "Monte seu time grátis" e a marca (com o QR do Fantasy).
class FantasyArtFooter extends StatelessWidget {
  final FantasyArtArgs args;
  final MainAxisAlignment alignment;

  const FantasyArtFooter(this.args, {super.key, this.alignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == MainAxisAlignment.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.fantasyArtCta.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.textStyle(11 * s, AppColors.white, weight: FontWeight.w800, spacing: 1.2 * s),
          ),
        ),
        SizedBox(height: 6 * s),
        ArtBranding(color: AppColors.white, scale: s, qrData: args.qr, alignment: alignment),
      ],
    );
  }
}

/// Foto do atleta num círculo com o aro da medalha (sem foto, as iniciais).
class FantasyArtPhoto extends StatelessWidget {
  final FantasyNewsAthlete athlete;
  final double size;
  final Color ring;
  final double ringWidth;
  final ArtColors colors;

  const FantasyArtPhoto({
    super.key,
    required this.athlete,
    required this.size,
    required this.ring,
    required this.colors,
    this.ringWidth = 3,
  });

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.base, colors.deep],
        ),
      ),
      child: Center(
        child: Text(initialsOf(athlete.name), style: ArtFonts.displayStyle(size * 0.36, colors.accent)),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: ring,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), blurRadius: size * 0.12)],
      ),
      child: ClipOval(
        child: athlete.photoUrl.isEmpty
            ? fallback
            : Image(
                image: EventArtPhoto.providerFor(athlete.photoUrl),
                fit: BoxFit.cover,
                width: math.max(0, size - 2 * ringWidth),
                height: math.max(0, size - 2 * ringWidth),
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// "ATA · Leões" (posição do Fantasy e o time).
String fantasyArtSubtitle(AppLocalizations l10n, FantasyNewsAthlete athlete) =>
    [fantasyPositionLabelOfKey(l10n, athlete.position), athlete.team].where((t) => t.isNotEmpty).join(' · ');

/// "25 PTS".
String fantasyArtPoints(AppLocalizations l10n, FantasyNewsAthlete athlete) =>
    l10n.fantasyArtPoints(FantasyRoundArtData.pointsText(athlete.points));
