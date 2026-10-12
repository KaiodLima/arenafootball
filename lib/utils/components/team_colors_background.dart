import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Fundo padrão com as cores do time: centro claro (cor secundária) e cantos
/// superior esquerdo e inferior direito recortados na diagonal na cor
/// principal, com filete, pílulas sólidas e translúcidas, retícula de pontos
/// nos outros cantos e feixes de luz suaves.
class TeamColorsBackground extends StatelessWidget {
  final TeamPalette palette;
  final Widget child;

  /// Faixa de baixo coberta por outro elemento (ex.: a folha arredondada do
  /// elenco): o desenho se centraliza na área que fica visível.
  final double bottomInset;

  const TeamColorsBackground({super.key, required this.palette, required this.child, this.bottomInset = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _TeamColorsPainter(palette, bottomInset), child: child),
    );
  }
}

class _TeamColorsPainter extends CustomPainter {
  final TeamPalette palette;
  final double bottomInset;

  _TeamColorsPainter(this.palette, this.bottomInset);

  /// Inclinação da diagonal (sobe da esquerda para a direita).
  static const double _angle = 37 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = palette.background);

    // Área visível (sem a faixa coberta embaixo).
    final visible = Size(size.width, size.height - bottomInset);
    _halftone(canvas, visible, corner: Offset(visible.width, 0));
    _halftone(canvas, visible, corner: Offset(0, visible.height));

    // Daqui em diante, eixo x ao longo da diagonal e y perpendicular a ela,
    // com origem no centro. O canto superior esquerdo fica em y negativo.
    canvas.save();
    canvas.clipRect(rect);
    canvas.translate(visible.width / 2, visible.height / 2);
    canvas.rotate(-_angle);

    // Distância do centro até os cantos na direção perpendicular à diagonal.
    final reach = (visible.width / 2) * math.sin(_angle) + (visible.height / 2) * math.cos(_angle);
    final length = size.longestSide * 2;

    _lightBeams(canvas, reach, length);
    _corner(canvas, reach, length);
    // Canto inferior direito: o mesmo desenho girado 180°.
    canvas.rotate(math.pi);
    _corner(canvas, reach, length);
    canvas.restore();
  }

  /// Feixes de luz largos e quase transparentes cruzando o centro.
  void _lightBeams(Canvas canvas, double reach, double length) {
    final paint = Paint()..color = palette.accent.withValues(alpha: 0.05);
    for (final (center, height) in [
      (-reach * 0.32, reach * 0.22),
      (reach * 0.12, reach * 0.3),
      (reach * 0.48, reach * 0.12),
    ]) {
      canvas.drawRect(Rect.fromCenter(center: Offset(0, center), width: length, height: height), paint);
    }
  }

  /// Um canto: pílulas translúcidas, a área sólida com degradê e filete, e a
  /// pílula sólida paralela ao recorte.
  void _corner(Canvas canvas, double reach, double length) {
    final cut = -reach * 0.55; // borda do recorte
    final pill = reach * 0.075;

    // Pílulas translúcidas (atrás).
    final soft = Paint();
    for (final (start, end, top, height, alpha) in [
      (-reach * 2.2, -reach * 0.4, cut + reach * 0.28, reach * 0.11, 0.18),
      (-reach * 2.2, -reach * 0.75, cut + reach * 0.47, reach * 0.12, 0.1),
    ]) {
      soft.color = palette.accent.withValues(alpha: alpha);
      canvas.drawRRect(RRect.fromLTRBR(start, top, end, top + height, Radius.circular(height / 2)), soft);
    }

    // Área sólida do canto, terminando arredondada.
    final area = RRect.fromLTRBR(-length, -length, reach * 0.35, cut, Radius.circular(reach * 0.14));
    canvas.drawRRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [palette.accent, palette.accentDark],
        ).createShader(Rect.fromLTRB(-reach, -reach, reach, cut)),
    );

    // Filete claro por dentro do recorte.
    canvas.drawRRect(
      area.deflate(reach * 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = palette.line.withValues(alpha: 0.85),
    );

    // Pílula sólida paralela ao recorte, um pouco afastada.
    final top = cut + reach * 0.09;
    canvas.drawRRect(
      RRect.fromLTRBR(-reach * 2.2, top, -reach * 0.25, top + pill, Radius.circular(pill / 2)),
      Paint()..color = palette.accent,
    );
  }

  /// Retícula de pontos: maiores e mais fortes junto ao [corner], somem em
  /// direção ao centro.
  void _halftone(Canvas canvas, Size size, {required Offset corner}) {
    final spacing = size.shortestSide * 0.035;
    final radius = size.shortestSide * 0.55;
    final maxDot = spacing * 0.32;
    final paint = Paint();
    for (var x = 0.0; x <= size.width; x += spacing) {
      for (var y = 0.0; y <= size.height; y += spacing) {
        final distance = (Offset(x, y) - corner).distance;
        if (distance > radius) continue;
        final strength = 1 - distance / radius;
        paint.color = palette.accent.withValues(alpha: 0.28 * strength);
        canvas.drawCircle(Offset(x, y), maxDot * (0.35 + 0.65 * strength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TeamColorsPainter oldDelegate) =>
      oldDelegate.palette.accent != palette.accent ||
      oldDelegate.palette.background != palette.background ||
      oldDelegate.bottomInset != bottomInset;
}
