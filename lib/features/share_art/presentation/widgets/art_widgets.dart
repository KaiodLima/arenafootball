import 'package:barcode/barcode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Escudo na arte: num círculo branco; sem imagem (ou se ela falhar), um
/// escudo substituto com as iniciais na cor do time — a arte nunca sai
/// quebrada.
class ArtCrest extends StatelessWidget {
  final ArtTeam team;
  final double size;
  final Color color;

  const ArtCrest({super.key, required this.team, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final fallback = _CrestFallback(team: team, size: size, color: color);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: size * 0.12)],
      ),
      child: team.crestUrl.isEmpty
          ? fallback
          : ClipOval(
              child: Image(
                image: CachedNetworkImageProvider(team.crestUrl),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback,
              ),
            ),
    );
  }
}

class _CrestFallback extends StatelessWidget {
  final ArtTeam team;
  final double size;
  final Color color;

  const _CrestFallback({required this.team, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.shield_rounded, size: size * 0.78, color: color),
        Padding(
          padding: EdgeInsets.only(bottom: size * 0.06),
          child: Text(
            team.initials,
            style: TextStyle(
              color: readableOn(color),
              fontWeight: FontWeight.w900,
              fontSize: size * 0.22,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Marca discreta no rodapé da arte: logo + "Confira mais no Arena
/// Football" e, opcionalmente, o QR do conteúdo.
class ArtBranding extends StatelessWidget {
  final Color color;
  final double scale;
  final String? qrData;
  final MainAxisAlignment alignment;

  const ArtBranding({
    super.key,
    required this.color,
    this.scale = 1,
    this.qrData,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qr = qrData;
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppImages.logo, height: 18 * scale, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        SizedBox(width: 6 * scale),
        // Coluna estreita: a frase encolhe inteira em vez de cortar.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.shareArtCallToAction,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                color: color.withValues(alpha: 0.85),
                fontSize: 10 * scale,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        if (qr != null && qr.isNotEmpty) ...[
          SizedBox(width: 8 * scale),
          ArtQrCode(data: qr, size: 30 * scale),
        ],
      ],
    );
  }
}

/// QR Code desenhado (pacote `barcode`, sem imagem de rede) num quadro branco.
class ArtQrCode extends StatelessWidget {
  final String data;
  final double size;

  const ArtQrCode({super.key, required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(size * 0.1)),
      child: CustomPaint(painter: _QrPainter(data)),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;

  _QrPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.black;
    try {
      for (final element in Barcode.qrCode().make(data, width: size.width, height: size.height, drawText: false)) {
        if (element is BarcodeBar && element.black) {
          canvas.drawRect(Rect.fromLTWH(element.left, element.top, element.width, element.height), paint);
        }
      }
    } catch (_) {
      // Dado inválido para QR: fica o quadro em branco (a arte segue).
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.data != data;
}

/// Selo da situação ("FIM DE JOGO", "AO VIVO"...).
class ArtStatusChip extends StatelessWidget {
  final ArtMatchStatus status;
  final double scale;

  const ArtStatusChip({super.key, required this.status, this.scale = 1});

  static String labelOf(AppLocalizations l10n, ArtMatchStatus status) => switch (status) {
        ArtMatchStatus.finished => l10n.liveFullTime,
        ArtMatchStatus.live => l10n.liveLabel,
        ArtMatchStatus.halfTime => l10n.reportHalfTime,
        ArtMatchStatus.notStarted => l10n.reportNotStarted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = switch (status) {
      ArtMatchStatus.live => AppColors.danger,
      ArtMatchStatus.halfTime => AppColors.gold,
      _ => AppColors.white,
    };
    final foreground = status == ArtMatchStatus.finished || status == ArtMatchStatus.notStarted
        ? AppColors.primaryDark
        : (status == ArtMatchStatus.halfTime ? AppColors.textPrimary : AppColors.white);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20 * scale)),
      child: Text(
        labelOf(l10n, status).toUpperCase(),
        style: TextStyle(color: foreground, fontSize: 9 * scale, fontWeight: FontWeight.w900, letterSpacing: 1.2),
      ),
    );
  }
}

/// "12' Ana · 40' Bia": gols de um lado, um por linha.
class ArtGoalList extends StatelessWidget {
  final List<ArtGoal> goals;
  final Color color;
  final double scale;
  final TextAlign align;
  final int maxLines;

  const ArtGoalList({
    super.key,
    required this.goals,
    required this.color,
    this.scale = 1,
    this.align = TextAlign.left,
    this.maxLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = goals.take(maxLines).toList();
    final more = goals.length - shown.length;
    final style = TextStyle(color: color, fontSize: 9.5 * scale, fontWeight: FontWeight.w600, height: 1.35);
    return Column(
      crossAxisAlignment: align == TextAlign.right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        for (final g in shown)
          Text(
            '${g.minute == null ? '' : "${g.minute}'  "}${g.scorer.isEmpty ? l10n.reportGoalNoScorer : g.scorer}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: style,
          ),
        if (more > 0) Text('+$more', textAlign: align, style: style),
      ],
    );
  }
}
