import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Anel de progresso (0 a 1) com o [child] no centro; enche animado.
class AlbumProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  const AlbumProgressRing({
    super.key,
    required this.value,
    required this.size,
    this.stroke = AppSizes.s8,
    this.color = AppColors.googleYellow,
    this.track = AppColors.whiteMuted,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => CustomPaint(
          painter: _RingPainter(value: v, stroke: stroke, color: color, track: track),
          child: Center(child: child),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color color;
  final Color track;

  _RingPainter({required this.value, required this.stroke, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(arc, 0, math.pi * 2, false, base);
    if (value <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color.withValues(alpha: 0.7), color],
      ).createShader(rect);
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color || old.track != track;
}

/// Listras (gramado ou textura diagonal) por cima de um fundo.
class StripesPainter extends CustomPainter {
  final Color color;
  final double width;

  /// Diagonal (capa) ou horizontal (gramado das páginas).
  final bool diagonal;

  const StripesPainter({required this.color, this.width = 22, this.diagonal = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    if (diagonal) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(-math.pi / 5);
      final extent = size.longestSide * 1.5;
      for (var x = -extent; x < extent; x += width * 2) {
        canvas.drawRect(Rect.fromLTWH(x, -extent, width, extent * 2), paint);
      }
      canvas.restore();
      return;
    }
    for (var y = 0.0; y < size.height; y += width * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, width), paint);
    }
  }

  @override
  bool shouldRepaint(StripesPainter old) => old.color != color || old.width != width || old.diagonal != diagonal;
}

/// Brilho que atravessa o [child] em loop (figurinha "foil" e o pacote).
/// [holographic]: arco-íris (foil); senão, uma faixa branca.
class Shimmer extends StatefulWidget {
  final Widget child;
  final bool holographic;
  final Duration period;

  const Shimmer(
      {super.key, required this.child, this.holographic = false, this.period = const Duration(milliseconds: 2400)});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations && !_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.holographic
        ? [
            AppColors.transparent,
            AppColors.teamPink.withValues(alpha: 0.35),
            AppColors.googleYellow.withValues(alpha: 0.4),
            AppColors.primary.withValues(alpha: 0.35),
            AppColors.teamBlue.withValues(alpha: 0.35),
            AppColors.transparent,
          ]
        : [AppColors.transparent, AppColors.white.withValues(alpha: 0.55), AppColors.transparent];
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 3 - 1;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + t * 2, -1),
                      end: Alignment(1 + t * 2, 1),
                      colors: colors,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Cor mais escura (fundos das páginas, leitura do texto branco).
Color darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// Raios saindo do centro (fundo da figurinha brilhante do escudo).
class RaysPainter extends CustomPainter {
  final Color color;
  final int rays;

  const RaysPainter({required this.color, this.rays = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.longestSide;
    final paint = Paint()..color = color;
    final step = math.pi * 2 / rays;
    for (var i = 0; i < rays; i++) {
      final a = i * step;
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a))
          ..lineTo(center.dx + radius * math.cos(a + step / 2), center.dy + radius * math.sin(a + step / 2))
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RaysPainter old) => old.color != color || old.rays != rays;
}

/// Recorte serrilhado em cima e embaixo (pacote laminado).
class ZigzagClipper extends CustomClipper<Path> {
  final double tooth;

  const ZigzagClipper({this.tooth = 8});

  @override
  Path getClip(Size size) {
    final teeth = math.max(1, (size.width / tooth).round());
    final step = size.width / teeth;
    final half = tooth / 2;
    final path = Path()..moveTo(0, half);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(step * i + step / 2, 0)
        ..lineTo(step * (i + 1), half);
    }
    path.lineTo(size.width, size.height - half);
    for (var i = teeth; i > 0; i--) {
      path
        ..lineTo(step * i - step / 2, size.height)
        ..lineTo(step * (i - 1), size.height - half);
    }
    return path..close();
  }

  @override
  bool shouldReclip(ZigzagClipper old) => old.tooth != tooth;
}
