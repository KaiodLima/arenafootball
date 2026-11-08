import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _glassTop = Color(0xFF232A31);
const _glassBottom = Color(0xFF0D1115);

/// Divulgação "Placar": o jogo como a barra de placar da transmissão de TV,
/// sobre um estádio à noite (refletores desfocados e o gramado em
/// perspectiva). Cabeçalho com a competição e o dia; a barra em vidro escuro
/// com escudo + sigla de cada time e o horário no meio; embaixo, os nomes
/// completos, a contagem regressiva e a faixa de data · local.
class ScoreboardArt extends StatelessWidget {
  final PreviewArtArgs args;

  const ScoreboardArt(this.args, {super.key});

  /// Céu do estádio: azul-noite no "Times"; senão, as cores da paleta.
  static (Color, Color) sky(PreviewArtArgs args) => args.teamColors
      ? (const Color(0xFF071222), const Color(0xFF0F2A3D))
      : (Color.lerp(args.colors.deep, AppColors.black, 0.3)!, args.colors.base);

  @override
  Widget build(BuildContext context) {
    final (top, bottom) = sky(args);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
          ),
        ),
        CustomPaint(painter: _StadiumPainter(wide: args.wide)),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Refletores desfocados no alto e o gramado em perspectiva embaixo.
class _StadiumPainter extends CustomPainter {
  final bool wide;

  const _StadiumPainter({required this.wide});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Gramado: faixas alternadas que se abrem para baixo.
    final horizon = h * (wide ? 0.62 : 0.7);
    const stripes = 9;
    for (var i = 0; i < stripes; i++) {
      final t0 = i / stripes;
      final t1 = (i + 1) / stripes;
      double x(double t, double y) {
        final spread = (y - horizon) / (h - horizon);
        return w / 2 + (t - 0.5) * w * (0.9 + spread * 1.4);
      }

      final path = Path()
        ..moveTo(x(t0, horizon), horizon)
        ..lineTo(x(t1, horizon), horizon)
        ..lineTo(x(t1, h), h)
        ..lineTo(x(t0, h), h)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = (i.isEven ? const Color(0xFF1F6B33) : const Color(0xFF185A2A)).withValues(alpha: 0.55),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, w, h - horizon),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.black.withValues(alpha: 0.55), AppColors.black.withValues(alpha: 0.15)],
        ).createShader(Rect.fromLTWH(0, horizon, w, h - horizon)),
    );
    // Refletores: luzes desfocadas no alto.
    final light = Paint()
      ..color = AppColors.white.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final halo = Paint()
      ..color = const Color(0xFFBFD8FF).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    for (final fx in [0.12, 0.34, 0.66, 0.88]) {
      final c = Offset(w * fx, h * 0.07);
      canvas.drawCircle(c, w * 0.12, halo);
      canvas.drawCircle(c, w * 0.026, light);
    }
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter old) => old.wide != wide;
}

/// Cabeçalho: logo + nome do campeonato e a pílula do dia.
class _Header extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Header({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (args.logoUrl.isNotEmpty) ...[
              ArtChampionshipLogo(url: args.logoUrl, height: 38 * scale),
              SizedBox(width: 10 * scale),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  args.texts.championship,
                  maxLines: 1,
                  style: ArtFonts.displayStyle(22 * scale, AppColors.white, spacing: 1, height: 1.15),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * scale),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 3 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: accent, width: 1.5 * scale),
          ),
          child: Text(args.texts.headline, style: ArtFonts.textStyle(12 * scale, accent, spacing: 3)),
        ),
      ],
    );
  }
}

/// A barra de placar: escudo + sigla de cada lado (filete na cor do time) e
/// o horário num bloco no destaque, em vidro escuro.
class _ScoreBar extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _ScoreBar({required this.args, required this.scale});

  Widget _side(ArtSide side) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    final color = args.theme.sideColor(side);
    final code = team.abbreviation.isEmpty ? '---' : team.abbreviation;
    final crest = ArtTeamCrest(team: team, size: 54 * scale, color: color);
    final label = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(code, style: ArtFonts.displayStyle(38 * scale, AppColors.white, spacing: 1.5, height: 1.1)),
        SizedBox(height: 3 * scale),
        Container(width: 44 * scale, height: 4 * scale, color: artHalfColor(color)),
      ],
    );
    final home = side == ArtSide.home;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: home ? [crest, SizedBox(width: 12 * scale), label] : [label, SizedBox(width: 12 * scale), crest],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    final time = args.texts.time.isEmpty ? '--:--' : args.texts.time;
    return Container(
      height: 96 * scale,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_glassTop, _glassBottom],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.55), blurRadius: 24 * scale, offset: Offset(0, 10 * scale)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _side(ArtSide.home)),
              Container(
                width: 112 * scale,
                alignment: Alignment.center,
                color: accent,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(time,
                      style: ArtFonts.displayStyle(
                        36 * scale,
                        accent.computeLuminance() > 0.35 ? const Color(0xFF14171A) : AppColors.white,
                        spacing: 1,
                        height: 1.1,
                      )),
                ),
              ),
              Expanded(child: _side(ArtSide.away)),
            ],
          )),
          // Brilho no alto do vidro e a faixa no destaque embaixo.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 1.2 * scale, color: AppColors.white.withValues(alpha: 0.28)),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 3.5 * scale, color: accent)),
        ],
      ),
    );
  }
}

/// Nomes completos sob a barra e a contagem regressiva.
class _Names extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Names({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    Widget name(String text, TextAlign align) => Text(
          text.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: ArtFonts.textStyle(14 * scale, AppColors.white.withValues(alpha: 0.85), spacing: 1, height: 1.1),
        );
    final countdown = args.texts.countdown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: name(args.data.home.name, TextAlign.center)),
            SizedBox(width: 112 * scale),
            Expanded(child: name(args.data.away.name, TextAlign.center)),
          ],
        ),
        if (countdown.isNotEmpty) ...[
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(20 * scale)),
            child: Text(countdown, style: ArtFonts.textStyle(13 * scale, AppColors.white, spacing: 2.4)),
          ),
        ],
      ],
    );
  }
}

/// Faixa fina de data · local.
class _InfoStrip extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _InfoStrip({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final text = [args.texts.shortDate, args.texts.venue].where((p) => p.isNotEmpty).join('  ·  ');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 7 * scale),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_rounded, size: 14 * scale, color: args.colors.accent),
          SizedBox(width: 6 * scale),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, maxLines: 1, style: ArtFonts.textStyle(13 * scale, AppColors.white, spacing: 1.8)),
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.fromLTRB(18, args.story ? 64 : 24, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: s)),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ScoreBar(args: args, scale: s),
                      SizedBox(height: 12 * s),
                      _Names(args: args, scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(child: _InfoStrip(args: args, scale: s)),
          SizedBox(height: 12 * s),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: 0.56)),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 330,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ScoreBar(args: args, scale: 0.72),
                      const SizedBox(height: 8),
                      _Names(args: args, scale: 0.72),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: _InfoStrip(args: args, scale: 0.7))),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: AppColors.white, scale: 0.62, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
