import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Fundo de confronto entre dois times: centro claro com feixes diagonais e,
/// de cada lado, o escudo do time cortado pela borda (mandante à esquerda no
/// alto, visitante à direita embaixo), com pinceladas rasgadas, faixas,
/// retícula de pontos nas cores de cada um e bolas em marca d'água.
class MatchupBackground extends StatelessWidget {
  final TeamPalette home;
  final TeamPalette away;
  final Widget child;

  const MatchupBackground({super.key, required this.home, required this.away, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _MatchupPainter(home, away), child: child),
    );
  }
}

class _MatchupPainter extends CustomPainter {
  final TeamPalette home;
  final TeamPalette away;

  _MatchupPainter(this.home, this.away);

  /// Inclinação das pinceladas e faixas ("/", subindo para a direita).
  static const double _angle = -52 * math.pi / 180;

  /// Centro vertical do escudo do mandante (o do visitante é o espelho).
  static const double _shieldCenterY = 0.24;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, Color(0xFFF1F2F1)],
        ).createShader(rect),
    );
    _lightBeams(canvas, size);
    _watermarkBall(canvas, size, Offset(size.width / 2, size.height * 0.035));
    _watermarkBall(canvas, size, Offset(size.width / 2, size.height * 0.965));

    // Decoração do mandante; a do visitante é a mesma girada 180°, o que
    // mantém as diagonais no mesmo sentido.
    _decorations(canvas, size, home, seed: 7);
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    _decorations(canvas, size, away, seed: 11);
    canvas.restore();

    // Escudos sempre "em pé": o do visitante só espelha a posição.
    final shield = _shieldSize(size);
    _shield(canvas, Offset(-shield.width * 0.5, size.height * _shieldCenterY - shield.height / 2), shield, home);
    _shield(
      canvas,
      Offset(size.width - shield.width * 0.5, size.height * (1 - _shieldCenterY) - shield.height / 2),
      shield,
      away,
    );
    canvas.restore();
  }

  Size _shieldSize(Size size) {
    final width = size.width * 0.4;
    return Size(width, width * 1.22);
  }

  /// Cor secundária para riscos sobre o fundo claro: a do time, ou (se for
  /// branca/clara demais) o tom escuro da principal.
  Color _secondary(TeamPalette palette) =>
      palette.background.computeLuminance() > 0.8 ? palette.accentDark : palette.background;

  /// Faixas largas, brancas e cinza-claras cruzando o centro na diagonal.
  void _lightBeams(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(_angle);
    final length = size.longestSide * 2;
    final unit = size.shortestSide;
    for (final (offset, height, color) in [
      (-unit * 0.42, unit * 0.16, AppColors.black.withValues(alpha: 0.025)),
      (-unit * 0.12, unit * 0.22, AppColors.white.withValues(alpha: 0.7)),
      (unit * 0.2, unit * 0.1, AppColors.black.withValues(alpha: 0.03)),
      (unit * 0.42, unit * 0.2, AppColors.white.withValues(alpha: 0.6)),
    ]) {
      canvas.drawRect(Rect.fromCenter(center: Offset(0, offset), width: length, height: height), Paint()..color = color);
    }
    canvas.restore();
  }

  /// Bola apagada (círculo e gomos) com uma linha fina atravessando.
  void _watermarkBall(Canvas canvas, Size size, Offset center) {
    final radius = size.width * 0.09;
    final line = Paint()
      ..color = AppColors.black.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width * 0.28, center.dy), Offset(center.dx - radius * 1.1, center.dy), line);
    canvas.drawLine(Offset(center.dx + radius * 1.1, center.dy), Offset(size.width * 0.72, center.dy), line);
    canvas.drawCircle(center, radius, Paint()..color = AppColors.black.withValues(alpha: 0.035));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.black.withValues(alpha: 0.06),
    );
    final patch = Paint()..color = AppColors.black.withValues(alpha: 0.06);
    canvas.drawPath(_polygon(center, radius * 0.38, 5, -math.pi / 2), patch);
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

  /// Retícula, faixas sólidas e pinceladas de um time (no lado do mandante).
  void _decorations(Canvas canvas, Size size, TeamPalette palette, {required int seed}) {
    final shield = _shieldSize(size);
    final shieldCenter = Offset(0, size.height * _shieldCenterY);
    final secondary = _secondary(palette);

    _halftone(canvas, size, corner: Offset(0, size.height * 0.02), color: palette.accent, reach: 0.42);
    _halftone(canvas, size, corner: Offset(0, size.height * 0.66), color: secondary, reach: 0.3);

    // Daqui em diante, eixo x ao longo da diagonal, com origem ao lado do escudo.
    canvas.save();
    canvas.translate(shieldCenter.dx + shield.width * 0.38, shieldCenter.dy + shield.height * 0.1);
    canvas.rotate(_angle);
    final unit = size.shortestSide;
    final random = math.Random(seed);

    // Faixas sólidas grossas, abaixo do escudo (na borda).
    for (final (offset, height, color) in [
      (unit * 0.42, unit * 0.06, palette.accent),
      (unit * 0.5, unit * 0.035, secondary),
    ]) {
      canvas.drawRect(Rect.fromLTWH(-unit * 1.5, offset, unit * 1.0, height), Paint()..color = color);
    }

    // Pinceladas: tiras finas com as duas pontas rasgadas.
    for (final (offset, start, end, thickness, color) in [
      (-unit * 0.1, -unit * 0.55, unit * 0.62, unit * 0.05, palette.accent),
      (-unit * 0.02, -unit * 0.4, unit * 0.5, unit * 0.025, palette.accent.withValues(alpha: 0.75)),
      (unit * 0.05, -unit * 0.7, unit * 0.36, unit * 0.04, secondary),
      (unit * 0.12, -unit * 0.5, unit * 0.22, unit * 0.018, palette.accent.withValues(alpha: 0.55)),
      (-unit * 0.17, -unit * 0.3, unit * 0.44, unit * 0.018, secondary.withValues(alpha: 0.7)),
      (unit * 0.19, -unit * 0.6, unit * 0.12, unit * 0.03, palette.accent.withValues(alpha: 0.35)),
      (-unit * 0.24, -unit * 0.1, unit * 0.3, unit * 0.012, palette.accent.withValues(alpha: 0.5)),
      (unit * 0.0, -unit * 0.2, unit * 0.56, unit * 0.008, palette.accent),
      (unit * 0.09, -unit * 0.3, unit * 0.42, unit * 0.007, secondary),
      (-unit * 0.06, -unit * 0.35, unit * 0.7, unit * 0.006, palette.accent.withValues(alpha: 0.6)),
      (unit * 0.16, -unit * 0.2, unit * 0.3, unit * 0.01, palette.accent.withValues(alpha: 0.8)),
    ]) {
      canvas.drawPath(_brush(random, offset, start, end, thickness), Paint()..color = color);
    }
    canvas.restore();
  }

  /// Tira de [start] a [end] (eixo da diagonal), centrada em [offset], com
  /// pontas em farpas de comprimentos variados (aleatório com semente fixa:
  /// a imagem sai sempre igual).
  Path _brush(math.Random random, double offset, double start, double end, double thickness) {
    const spikes = 5;
    final top = offset - thickness / 2;
    final path = Path()..moveTo(start, top);
    path.lineTo(end, top);
    // Ponta da frente: farpas para fora.
    for (var i = 1; i <= spikes; i++) {
      final y = top + thickness * i / spikes;
      final reach = thickness * (2 + random.nextDouble() * 9) + 4;
      path.lineTo(end + reach, y - thickness / spikes / 2);
      path.lineTo(end + reach * 0.15, y);
    }
    path.lineTo(start, top + thickness);
    // Ponta de trás.
    for (var i = spikes - 1; i >= 0; i--) {
      final y = top + thickness * i / spikes;
      final reach = thickness * (1 + random.nextDouble() * 5) + 2;
      path.lineTo(start - reach, y + thickness / spikes / 2);
      path.lineTo(start - reach * 0.15, y);
    }
    return path..close();
  }

  /// Retícula de pontos: maiores e mais fortes junto ao [corner].
  void _halftone(Canvas canvas, Size size, {required Offset corner, required Color color, double reach = 0.55}) {
    final spacing = size.shortestSide * 0.03;
    final radius = size.shortestSide * reach;
    final maxDot = spacing * 0.36;
    final paint = Paint();
    for (var x = 0.0; x <= size.width; x += spacing) {
      for (var y = 0.0; y <= size.height; y += spacing) {
        final distance = (Offset(x, y) - corner).distance;
        if (distance > radius) continue;
        final strength = 1 - distance / radius;
        paint.color = color.withValues(alpha: 0.6 * strength * strength);
        canvas.drawCircle(Offset(x, y), maxDot * (0.25 + 0.75 * strength), paint);
      }
    }
  }

  /// Escudo: topo reto, base em ogiva; listras diagonais em dois tons da
  /// principal, filete branco por dentro e contorno na secundária.
  void _shield(Canvas canvas, Offset topLeft, Size size, TeamPalette palette) {
    final path = _shieldPath(topLeft & size);
    final bounds = topLeft & size;

    canvas.drawShadow(path, AppColors.black, 6, false);
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
    // Listras diagonais.
    canvas.translate(bounds.center.dx, bounds.center.dy);
    canvas.rotate(_angle);
    final stripe = size.width * 0.12;
    final stripes = Paint()..color = palette.accentDark.withValues(alpha: 0.45);
    for (var x = -size.height; x < size.height; x += stripe * 2) {
      canvas.drawRect(Rect.fromLTWH(-size.height, x, size.height * 2, stripe), stripes);
    }
    canvas.restore();

    canvas.drawPath(
      _shieldPath(bounds.deflate(size.width * 0.06)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.035
        // Contorno na secundária de verdade (branca inclusive, como no anexo).
        ..color = palette.background.computeLuminance() > 0.8 ? AppColors.white : palette.background,
    );
  }

  Path _shieldPath(Rect r) {
    final notch = r.width * 0.08;
    return Path()
      ..moveTo(r.left + notch, r.top)
      ..lineTo(r.right - notch, r.top)
      ..lineTo(r.right, r.top + notch)
      ..lineTo(r.right, r.top + r.height * 0.45)
      ..quadraticBezierTo(r.right, r.top + r.height * 0.82, r.center.dx, r.bottom)
      ..quadraticBezierTo(r.left, r.top + r.height * 0.82, r.left, r.top + r.height * 0.45)
      ..lineTo(r.left, r.top + notch)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _MatchupPainter oldDelegate) =>
      oldDelegate.home.accent != home.accent ||
      oldDelegate.home.background != home.background ||
      oldDelegate.away.accent != away.accent ||
      oldDelegate.away.background != away.background;
}
