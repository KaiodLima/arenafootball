import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF14171A);
const _night = Color(0xFF0F1418);
const _slate = Color(0xFF1E2731);

/// Divulgação "Duelo" (escura): grafite com grão, os dois escudos grandes
/// frente a frente com um halo na cor de cada time, o raio dourado com o "VS",
/// os nomes em itálico, um bloco dourado com data e horário e o local.
class VersusArt extends StatelessWidget {
  final PreviewArtArgs args;

  const VersusArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = args.theme;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_slate, _night],
            ),
          ),
        ),
        // Halos nas cores dos times, atrás de cada escudo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: args.wide ? const Alignment(-0.55, 0.05) : const Alignment(-0.6, -0.05),
              radius: args.wide ? 0.75 : 0.62,
              colors: [theme.home.withValues(alpha: 0.6), theme.home.withValues(alpha: 0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: args.wide ? const Alignment(0.55, 0.05) : const Alignment(0.6, -0.05),
              radius: args.wide ? 0.75 : 0.62,
              colors: [theme.away.withValues(alpha: 0.6), theme.away.withValues(alpha: 0)],
            ),
          ),
        ),
        const ArtGrain(opacity: 0.07),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Raio dourado em zigue-zague com o "VS" por cima.
class _Bolt extends StatelessWidget {
  final double width;
  final double height;

  const _Bolt({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _BoltPainter())),
          Text(
            'VS',
            style: ArtFonts.displayStyle(width * 0.42, AppColors.white, spacing: 1).copyWith(
              shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.6), blurRadius: width * 0.08)],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w * 0.22, h * 0.52)
      ..lineTo(w * 0.48, h * 0.52)
      ..lineTo(w * 0.36, h)
      ..lineTo(w * 0.80, h * 0.42)
      ..lineTo(w * 0.54, h * 0.42)
      ..close();
    canvas.drawPath(
      path.shift(Offset(w * 0.04, h * 0.02)),
      Paint()..color = AppColors.black.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE082), AppColors.gold, Color(0xFFB8860B)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _BoltPainter oldDelegate) => false;
}

class _Team extends StatelessWidget {
  final PreviewArtArgs args;
  final ArtSide side;
  final double scale;

  const _Team({required this.args, required this.side, required this.scale});

  @override
  Widget build(BuildContext context) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    final color = args.theme.sideColor(side);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtTeamCrest(team: team, size: 92 * scale, color: color),
        SizedBox(height: 10 * scale),
        Text(
          team.name.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(17 * scale, AppColors.white, italic: true, height: 1),
        ),
        SizedBox(height: 6 * scale),
        // Time escuro demais some no fundo: a linha fica branca.
        Container(
          width: 30 * scale,
          height: 3 * scale,
          color: color.computeLuminance() < 0.04 ? AppColors.white.withValues(alpha: 0.7) : color,
        ),
      ],
    );
  }
}

/// Competição com a logo, centralizada.
class _Championship extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Championship({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (args.logoUrl.isNotEmpty) ...[
          ArtChampionshipLogo(url: args.logoUrl, height: 22 * scale),
          SizedBox(width: 8 * scale),
        ],
        Flexible(
          child: Text(
            args.texts.championship,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(11 * scale, AppColors.gold, spacing: 2.6),
          ),
        ),
      ],
    );
  }
}

/// Bloco dourado "SÁB · 15/11 | 18:00" e o local embaixo.
class _When extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _When({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final parts = [t.shortDate, t.time].where((p) => p.isNotEmpty).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (parts.isNotEmpty)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
              color: AppColors.gold,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < parts.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 2 * scale,
                        height: 20 * scale,
                        margin: EdgeInsets.symmetric(horizontal: 10 * scale),
                        color: _ink.withValues(alpha: 0.5),
                      ),
                    Text(parts[i], style: ArtFonts.displayStyle(24 * scale, _ink, spacing: 1, height: 1.2)),
                  ],
                ],
              ),
            ),
          ),
        SizedBox(height: 8 * scale),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_rounded, size: 13 * scale, color: AppColors.gold),
            SizedBox(width: 4 * scale),
            Flexible(
              child: Text(
                t.venue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(12 * scale, AppColors.white.withValues(alpha: 0.85), spacing: 1.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tall extends StatelessWidget {
  final PreviewArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, args.story ? 56 : 22, 20, args.story ? 40 : 14),
      child: Column(
        children: [
          _Championship(args: args, scale: s),
          SizedBox(height: 6 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              args.texts.headline,
              maxLines: 1,
              style: ArtFonts.displayStyle((args.square ? 40 : 50) * s, AppColors.white, spacing: 1),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 40,
                  child: Row(
                    children: [
                      Expanded(child: _Team(args: args, side: ArtSide.home, scale: s)),
                      _Bolt(width: 62 * s, height: 96 * s),
                      Expanded(child: _Team(args: args, side: ArtSide.away, scale: s)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _When(args: args, scale: s),
          SizedBox(height: 14 * s),
          ArtBranding(color: AppColors.white, scale: s, qrData: args.qr),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PreviewArtArgs args;

  const _Wide(this.args);

  @override
  Widget build(BuildContext context) {
    const s = 0.62;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: _Championship(args: args, scale: 0.75))),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(args.texts.headline, style: ArtFonts.displayStyle(22, AppColors.white, spacing: 1)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 300,
                  child: Row(
                    children: [
                      Expanded(child: _Team(args: args, side: ArtSide.home, scale: s)),
                      const _Bolt(width: 40, height: 62),
                      Expanded(child: _Team(args: args, side: ArtSide.away, scale: s)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: _When(args: args, scale: 0.62))),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: AppColors.white, scale: 0.7, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
