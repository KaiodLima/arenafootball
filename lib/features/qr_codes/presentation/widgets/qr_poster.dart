import 'package:flutter/material.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Ícone e rótulo do tipo de QR.
(IconData, String) qrKindLabel(AppLocalizations l10n, QrKind kind) => switch (kind) {
      QrKind.vote => (Icons.how_to_vote_rounded, l10n.qrKindVote),
      QrKind.match => (Icons.sports_soccer_rounded, l10n.qrKindMatch),
      QrKind.pool => (Icons.emoji_events_rounded, l10n.qrKindPool),
      QrKind.album => (Icons.style_rounded, l10n.qrKindAlbum),
      QrKind.event => (Icons.campaign_rounded, l10n.qrKindEvent),
      QrKind.now => (Icons.bolt_rounded, l10n.qrKindNow),
    };

/// Cartaz do QR code, na superfície de tamanho fixo das artes (medidas pela
/// escala `s`): fundo da paleta, o selo do tipo, o título em Anton, os
/// escudos (partida), o QR grande num quadro branco, "Aponte a câmera…", o
/// link curto e a marca do app.
class QrPoster extends StatelessWidget {
  final QrTarget target;
  final ArtFormat format;
  final ArtColors colors;

  const QrPoster({super.key, required this.target, required this.format, required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = format.logicalSize;
    final wide = format == ArtFormat.landscape;
    final s = wide ? size.height / 230 : size.width / 360;
    final (icon, label) = qrKindLabel(l10n, target.kind);

    final seal = Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
      decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(20 * s)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13 * s, color: AppColors.black),
          SizedBox(width: 5 * s),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: ArtFonts.textStyle(12 * s, AppColors.black, weight: FontWeight.w800, spacing: 1.6 * s),
              ),
            ),
          ),
        ],
      ),
    );
    final title = Text(
      target.title.toUpperCase(),
      textAlign: wide ? TextAlign.start : TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: ArtFonts.displayStyle((wide ? 22 : 30) * s, AppColors.white, height: 1.05, spacing: 0.4).copyWith(
        shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.4), offset: Offset(0, 2 * s))],
      ),
    );
    final subtitle = target.subtitle.isEmpty
        ? null
        : Text(
            target.subtitle.toUpperCase(),
            textAlign: wide ? TextAlign.start : TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(13 * s, AppColors.white.withValues(alpha: 0.8), spacing: 1 * s),
          );
    final teams = !target.hasTeams
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArtCrest(team: target.home!, size: 54 * s, color: colors.base),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * s),
                child: Text('VS', style: ArtFonts.displayStyle(22 * s, colors.accent)),
              ),
              ArtCrest(team: target.away!, size: 54 * s, color: colors.base),
            ],
          );
    final qrSize = wide ? size.height - 60 * s : (format == ArtFormat.square ? 150 : 200) * s;
    // Largura do texto na paisagem: o que sobra ao lado do QR.
    final leftWidth = size.width - 44 * s - 18 * s - (qrSize + 16 * s + 8 * s);
    final qr = Container(
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18 * s),
        border: Border.all(color: colors.accent, width: 4 * s),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), blurRadius: 18 * s)],
      ),
      child: ArtQrCode(key: const ValueKey('qr-poster-code'), data: target.link, size: qrSize),
    );
    final cta = Text(
      l10n.qrScanCta.toUpperCase(),
      textAlign: wide ? TextAlign.start : TextAlign.center,
      style: ArtFonts.displayStyle(17 * s, colors.accent, spacing: 0.6 * s),
    );
    final link = Text(
      target.shortLink,
      textAlign: wide ? TextAlign.start : TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ArtFonts.textStyle(11 * s, AppColors.white.withValues(alpha: 0.75), spacing: 0.4 * s),
    );
    final branding = ArtBranding(
      color: AppColors.white,
      scale: s,
      alignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
    );

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: wide ? const Alignment(0.55, 0) : const Alignment(0, 0.15),
                  radius: 1.0,
                  colors: [colors.base, Color.lerp(colors.base, colors.deep, 0.6)!, colors.deep],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            const ArtGrain(opacity: 0.05),
            if (wide)
              Padding(
                padding: EdgeInsets.fromLTRB(22 * s, 18 * s, 22 * s, 16 * s),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // O bloco de cima encolhe inteiro para caber na altura baixa.
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: leftWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      seal,
                                      SizedBox(height: 8 * s),
                                      title,
                                      if (subtitle != null) ...[SizedBox(height: 4 * s), subtitle],
                                      if (teams != null) ...[SizedBox(height: 8 * s), teams],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6 * s),
                          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: cta),
                          SizedBox(height: 2 * s),
                          link,
                          SizedBox(height: 6 * s),
                          branding,
                        ],
                      ),
                    ),
                    SizedBox(width: 18 * s),
                    qr,
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.fromLTRB(
                  22 * s,
                  (format == ArtFormat.story ? 46 : 22) * s,
                  22 * s,
                  (format == ArtFormat.story ? 34 : 16) * s,
                ),
                child: Column(
                  children: [
                    seal,
                    SizedBox(height: 10 * s),
                    title,
                    if (subtitle != null) ...[SizedBox(height: 4 * s), subtitle],
                    // O miolo encolhe para caber no formato (o quadrado é baixo).
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (teams != null) ...[teams, SizedBox(height: 14 * s)],
                              qr,
                              SizedBox(height: 12 * s),
                              cta,
                            ],
                          ),
                        ),
                      ),
                    ),
                    link,
                    SizedBox(height: 6 * s),
                    branding,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tema neutro das paletas fixas (o QR não é de um time).
const ArtTheme qrArtTheme = ArtTheme(
  brandDark: AppColors.primaryDark,
  brand: AppColors.primary,
  accent: AppColors.gold,
  home: AppColors.primary,
  away: AppColors.primaryDark,
);

/// Paletas do cartaz (as fixas).
const List<ArtPalette> qrPalettes = [
  ArtPalette.arena,
  ArtPalette.night,
  ArtPalette.crimson,
  ArtPalette.ocean,
  ArtPalette.graphite,
];
