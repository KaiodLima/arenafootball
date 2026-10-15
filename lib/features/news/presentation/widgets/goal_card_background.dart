import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Fundo do card de gol (formato 2,4:1), nas cores do time que marcou: base
/// clara com faixas diagonais suaves; à esquerda, uma mancha de pinceladas
/// rasgadas, retícula nos cantos e um escudo inteiro; à direita, uma bola
/// grande apagada saindo pela borda.
class GoalCardBackground extends StatelessWidget {
  final TeamPalette palette;
  final Widget child;

  const GoalCardBackground({super.key, required this.palette, required this.child});

  /// Onde fica o escudo num card de [size] (o widget põe a imagem do escudo
  /// do time dentro dele).
  static Rect shieldRect(Size size) {
    final height = size.height * 0.68;
    final width = height / 1.2;
    return Rect.fromLTWH(size.width * 0.035, size.height * 0.14, width, height);
  }

  /// Centro do "miolo" do escudo (um pouco acima do meio, por causa da ponta).
  static Offset shieldCenter(Size size) {
    final rect = shieldRect(size);
    return Offset(rect.center.dx, rect.top + rect.height * 0.44);
  }

  /// Onde começa o conteúdo: depois do escudo, com folga.
  static double contentStart(Size size) => shieldRect(size).right + size.height * 0.12;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _GoalCardPainter(palette), child: child),
    );
  }
}

class _GoalCardPainter extends CustomPainter {
  final TeamPalette palette;

  _GoalCardPainter(this.palette);

  /// Inclinação das pinceladas e faixas ("/", subindo para a direita).
  static const double _angle = -56 * math.pi / 180;

  /// Cor secundária para riscos sobre o fundo claro: a do time, ou (se for
  /// clara demais) o tom escuro da principal.
  Color get _secondary => palette.background.computeLuminance() > 0.8 ? palette.accentDark : palette.background;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, Color(0xFFEFF1EF)],
        ).createShader(rect),
    );
    _beams(canvas, size);
    _ball(canvas, Offset(size.width * 0.94, size.height * 0.86), size.height * 0.42);
    _halftone(canvas, size, corner: Offset.zero, color: palette.accent, reach: size.height * 0.62);
    _halftone(canvas, size, corner: Offset(0, size.height), color: _secondary, reach: size.height * 0.48);
    _brushes(canvas, size);
    _shield(canvas, GoalCardBackground.shieldRect(size));
    canvas.restore();
  }

  /// Faixas largas e suaves cruzando o card na diagonal.
  void _beams(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * 0.62, size.height / 2);
    canvas.rotate(_angle);
    final length = size.longestSide * 2;
    final unit = size.height;
    for (final (offset, height, color) in [
      (-unit * 0.55, unit * 0.22, AppColors.black.withValues(alpha: 0.025)),
      (-unit * 0.1, unit * 0.3, AppColors.white.withValues(alpha: 0.75)),
      (unit * 0.35, unit * 0.14, AppColors.black.withValues(alpha: 0.03)),
      (unit * 0.75, unit * 0.26, AppColors.white.withValues(alpha: 0.6)),
    ]) {
      canvas.drawRect(
          Rect.fromCenter(center: Offset(0, offset), width: length, height: height), Paint()..color = color);
    }
    canvas.restore();
  }

  /// Bola apagada (círculo e gomos).
  void _ball(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = AppColors.black.withValues(alpha: 0.03));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.black.withValues(alpha: 0.06),
    );
    final patch = Paint()..color = AppColors.black.withValues(alpha: 0.05);
    canvas.drawPath(_polygon(center, radius * 0.36, 5, -math.pi / 2), patch);
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final at = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.86;
      canvas.drawPath(_polygon(at, radius * 0.2, 5, angle + math.pi / 2), patch);
    }
  }

  Path _polygon(Offset center, double radius, int sides, double rotation) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = rotation + i * 2 * math.pi / sides;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  /// Retícula de pontos: maiores e mais fortes junto ao [corner].
  void _halftone(Canvas canvas, Size size, {required Offset corner, required Color color, required double reach}) {
    final spacing = size.height * 0.04;
    final maxDot = spacing * 0.38;
    final paint = Paint();
    for (var x = 0.0; x <= reach; x += spacing) {
      for (var y = 0.0; y <= size.height; y += spacing) {
        final distance = (Offset(x, y) - corner).distance;
        if (distance > reach) continue;
        final strength = 1 - distance / reach;
        paint.color = color.withValues(alpha: 0.7 * strength * strength);
        canvas.drawCircle(Offset(x, y), maxDot * (0.25 + 0.75 * strength), paint);
      }
    }
  }

  /// Mancha de pinceladas atrás do escudo, na diagonal: tiras com as pontas
  /// rasgadas (semente fixa: o desenho sai sempre igual).
  void _brushes(Canvas canvas, Size size) {
    final center = GoalCardBackground.shieldCenter(size);
    final unit = size.height;
    final random = math.Random(19);
    canvas.save();
    canvas.translate(center.dx + unit * 0.06, center.dy);
    canvas.rotate(_angle);
    final accent = palette.accent;
    for (final (offset, start, end, thickness, color) in [
      (-unit * 0.2, -unit * 0.55, unit * 0.3, unit * 0.1, accent),
      (-unit * 0.06, -unit * 0.62, unit * 0.372, unit * 0.13, accent.withValues(alpha: 0.9)),
      (unit * 0.1, -unit * 0.5, unit * 0.288, unit * 0.09, accent),
      (unit * 0.22, -unit * 0.42, unit * 0.216, unit * 0.05, _secondary),
      (-unit * 0.3, -unit * 0.3, unit * 0.204, unit * 0.04, _secondary.withValues(alpha: 0.85)),
      (unit * 0.3, -unit * 0.3, unit * 0.132, unit * 0.025, accent.withValues(alpha: 0.6)),
      (-unit * 0.37, -unit * 0.2, unit * 0.12, unit * 0.02, accent.withValues(alpha: 0.5)),
      (unit * 0.02, -unit * 0.7, unit * 0.432, unit * 0.012, _secondary),
      (-unit * 0.13, -unit * 0.62, unit * 0.396, unit * 0.01, accent.withValues(alpha: 0.7)),
      (unit * 0.37, -unit * 0.25, unit * 0.072, unit * 0.012, _secondary.withValues(alpha: 0.6)),
    ]) {
      canvas.drawPath(_brush(random, offset, start, end, thickness), Paint()..color = color);
    }
    canvas.restore();
  }

  Path _brush(math.Random random, double offset, double start, double end, double thickness) {
    const spikes = 6;
    final top = offset - thickness / 2;
    final path = Path()..moveTo(start, top);
    path.lineTo(end, top);
    for (var i = 1; i <= spikes; i++) {
      final y = top + thickness * i / spikes;
      final reach = thickness * (0.6 + random.nextDouble() * 2.4) + 2;
      path.lineTo(end + reach, y - thickness / spikes / 2);
      path.lineTo(end + reach * 0.15, y);
    }
    path.lineTo(start, top + thickness);
    for (var i = spikes - 1; i >= 0; i--) {
      final y = top + thickness * i / spikes;
      final reach = thickness * (0.4 + random.nextDouble() * 1.6) + 2;
      path.lineTo(start - reach, y + thickness / spikes / 2);
      path.lineTo(start - reach * 0.15, y);
    }
    return path..close();
  }

  /// Escudo inteiro: topo com cantos chanfrados e base em ogiva; degradê na
  /// principal, listras diagonais, filete branco e contorno.
  void _shield(Canvas canvas, Rect bounds) {
    final path = _shieldPath(bounds);
    canvas.drawShadow(path, AppColors.black, 8, false);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.accent, palette.accentDark],
        ).createShader(bounds),
    );
    canvas.translate(bounds.center.dx, bounds.center.dy);
    canvas.rotate(_angle);
    final stripe = bounds.width * 0.13;
    final stripes = Paint()..color = palette.accentDark.withValues(alpha: 0.4);
    for (var x = -bounds.height; x < bounds.height; x += stripe * 2) {
      canvas.drawRect(Rect.fromLTWH(-bounds.height, x, bounds.height * 2, stripe), stripes);
    }
    canvas.restore();

    canvas.drawPath(
      _shieldPath(bounds.deflate(bounds.width * 0.07)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bounds.width * 0.04
        ..color = palette.background.computeLuminance() > 0.8 ? AppColors.white : palette.background,
    );
  }

  Path _shieldPath(Rect r) {
    final notch = r.width * 0.1;
    return Path()
      ..moveTo(r.left + notch, r.top)
      ..lineTo(r.right - notch, r.top)
      ..lineTo(r.right, r.top + notch)
      ..lineTo(r.right, r.top + r.height * 0.46)
      ..quadraticBezierTo(r.right, r.top + r.height * 0.82, r.center.dx, r.bottom)
      ..quadraticBezierTo(r.left, r.top + r.height * 0.82, r.left, r.top + r.height * 0.46)
      ..lineTo(r.left, r.top + notch)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _GoalCardPainter oldDelegate) =>
      oldDelegate.palette.accent != palette.accent || oldDelegate.palette.background != palette.background;
}
