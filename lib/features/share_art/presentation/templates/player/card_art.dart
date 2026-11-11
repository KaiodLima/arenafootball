import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _night = Color(0xFF0B0E12);

/// Moldura metálica: dourada na paleta "Times"; senão, o destaque da paleta.
List<Color> _metal(PlayerArtArgs args) {
  if (args.teamColors) {
    return const [Color(0xFFF7E08A), Color(0xFFC9A227), Color(0xFF8A6A12), Color(0xFFE8C766)];
  }
  final a = args.colors.accent;
  return [
    Color.lerp(a, AppColors.white, 0.5)!,
    a,
    Color.lerp(a, AppColors.black, 0.45)!,
    Color.lerp(a, AppColors.white, 0.25)!,
  ];
}

/// Atleta "Carta" (carta colecionável): fundo escuro com raios na cor do
/// time; no centro, a carta levemente inclinada com moldura metálica, a foto
/// numa janela de topo em arco, a sigla da posição e o escudo no canto, o
/// nome na faixa e os números (ou "ESTREIA"). "{TIME} APRESENTA" no alto.
class CardArt extends StatelessWidget {
  final PlayerArtArgs args;

  const CardArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final glow = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: args.wide ? const Alignment(-0.45, 0) : const Alignment(0, -0.1),
              radius: 0.9,
              colors: [glow.withValues(alpha: 0.85), Color.lerp(glow, _night, 0.75)!, _night],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        CustomPaint(painter: _RaysPainter(center: args.wide ? const Alignment(-0.45, 0) : const Alignment(0, -0.1))),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
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
    final r = size.longestSide * 1.2;
    final paint = Paint()..color = AppColors.white.withValues(alpha: 0.045);
    const n = 18;
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

/// A carta: moldura metálica, janela em arco, sigla + escudo, nome e números.
class _Card extends StatelessWidget {
  final PlayerArtArgs args;
  final double width;

  const _Card({required this.args, required this.width});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final d = args.data;
    final w = width;
    final height = w * 1.42;
    final metal = _metal(args);
    final panel = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final ink = metal[2];
    final stats = [
      if (d.goals > 0) (d.goals, t.goalsLabel),
      if (d.assists > 0) (d.assists, t.assistsLabel),
    ];
    return Transform.rotate(
      angle: -0.035,
      child: Container(
        width: w,
        height: height,
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w * 0.07),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: metal),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withValues(alpha: 0.55), blurRadius: w * 0.12, offset: Offset(0, w * 0.04)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(w * 0.05),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(panel, AppColors.white, 0.12)!, Color.lerp(panel, AppColors.black, 0.55)!],
              ),
            ),
            child: Column(
              children: [
                // Janela da foto com o topo em arco; sigla e escudo no canto.
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: w * 0.16,
                        right: w * 0.06,
                        top: w * 0.06,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.4)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ArtPlayerPhoto(url: d.photoUrl, initials: d.initials, color: args.teamColor),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.6, 1],
                                    colors: [panel.withValues(alpha: 0), Color.lerp(panel, AppColors.black, 0.4)!],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: w * 0.05,
                        top: w * 0.07,
                        child: Column(
                          children: [
                            if (t.positionAbbr.isNotEmpty)
                              Text(
                                t.positionAbbr,
                                style: ArtFonts.displayStyle(w * 0.11, metal[0], height: 1.05).copyWith(
                                  shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 4)],
                                ),
                              ),
                            SizedBox(height: w * 0.02),
                            Container(
                              padding: EdgeInsets.all(w * 0.012),
                              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                              child: ArtTeamCrest(team: d.team, size: w * 0.1, color: args.teamColor, plain: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Faixa do nome.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.025),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: metal)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      d.highlightName.toUpperCase(),
                      maxLines: 1,
                      style: ArtFonts.displayStyle(w * 0.11, const Color(0xFF15120A), spacing: 0.6, height: 1.1),
                    ),
                  ),
                ),
                // Números (ou estreia).
                Padding(
                  padding: EdgeInsets.symmetric(vertical: w * 0.035),
                  child: stats.isEmpty
                      ? Text(t.debut, style: ArtFonts.displayStyle(w * 0.07, metal[0], spacing: 2, height: 1.1))
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < stats.length; i++) ...[
                                if (i > 0)
                                  Container(
                                    width: 1,
                                    height: w * 0.08,
                                    margin: EdgeInsets.symmetric(horizontal: w * 0.05),
                                    color: metal[0].withValues(alpha: 0.5),
                                  ),
                                Text('${stats[i].$1}',
                                    style: ArtFonts.displayStyle(w * 0.08, AppColors.white, height: 1.1)),
                                SizedBox(width: w * 0.02),
                                Text(stats[i].$2, style: ArtFonts.textStyle(w * 0.045, metal[0], spacing: 1.4)),
                              ],
                            ],
                          ),
                        ),
                ),
                Container(height: w * 0.012, color: ink.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "{TIME} APRESENTA" + o primeiro nome.
class _Presents extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;
  final CrossAxisAlignment align;

  const _Presents({required this.args, required this.scale, this.align = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          args.texts.presents,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(14 * scale, AppColors.white, spacing: 3.5),
        ),
        SizedBox(height: 4 * scale),
        Container(width: 36 * scale, height: 3 * scale, color: _metal(args)[1]),
      ],
    );
  }
}

/// Competição (logo + nome).
class _Competition extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Competition({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final d = args.data;
    if (args.texts.championship.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (d.championshipLogoUrl.isNotEmpty) ...[
          ArtChampionshipLogo(url: d.championshipLogoUrl, height: 22 * scale),
          SizedBox(width: 8 * scale),
        ],
        Flexible(
          child: Text(
            args.texts.championship,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(12 * scale, _metal(args)[0], spacing: 2),
          ),
        ),
      ],
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.78 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 56 : 18, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Presents(args: args, scale: s),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final w = math.min(c.maxWidth * (args.story ? 0.88 : 0.74), c.maxHeight * 0.92 / 1.42);
              return Center(child: _Card(args: args, width: w));
            }),
          ),
          Center(child: _Competition(args: args, scale: s)),
          SizedBox(height: 10 * s),
          ArtBranding(color: AppColors.white, scale: s * 0.85, qrData: args.qr),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PlayerArtArgs args;

  const _Wide(this.args);

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, c) {
            return Center(child: _Card(args: args, width: c.maxHeight * 0.92 / 1.42));
          }),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                _Presents(args: args, scale: 0.7, align: CrossAxisAlignment.start),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    args.data.name.toUpperCase(),
                    maxLines: 1,
                    style: ArtFonts.displayStyle(30, AppColors.white, height: 1.1),
                  ),
                ),
                if (t.position.isNotEmpty)
                  Text(t.position, style: ArtFonts.textStyle(10, AppColors.white.withValues(alpha: 0.8), spacing: 2.4)),
                const SizedBox(height: 8),
                _Competition(args: args, scale: 0.7),
                const Spacer(),
                Align(
                    alignment: Alignment.centerRight,
                    child: ArtBranding(color: AppColors.white, scale: 0.58, qrData: args.qr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
