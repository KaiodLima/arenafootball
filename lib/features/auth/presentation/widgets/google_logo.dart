import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// "G" colorido do Google, desenhado (sem asset).
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = AppSizes.s20});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size, child: CustomPaint(painter: _GoogleLogoPainter()));
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double deg(double d) => d * math.pi / 180;

    // Arcos no sentido horário a partir das 3h: azul, verde, amarelo, vermelho.
    canvas.drawArc(rect, deg(0), deg(45), false, paint..color = AppColors.googleBlue);
    canvas.drawArc(rect, deg(45), deg(90), false, paint..color = AppColors.googleGreen);
    canvas.drawArc(rect, deg(135), deg(90), false, paint..color = AppColors.googleYellow);
    canvas.drawArc(rect, deg(225), deg(90), false, paint..color = AppColors.googleRed);

    // Barra horizontal do "G".
    final center = size.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(size.width / 2, center - stroke / 2, size.width, center + stroke / 2),
      Paint()..color = AppColors.googleBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
