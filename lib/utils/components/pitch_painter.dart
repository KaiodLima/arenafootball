import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Linhas do campo (vertical): faixas do gramado, contorno, meio-campo,
/// círculo central e as duas áreas. Fundo por conta de quem usa (o degradê
/// verde do Fantasy e do campinho das escalações).
class PitchPainter extends CustomPainter {
  const PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stripe = Paint()..color = AppColors.white.withValues(alpha: 0.04);
    const stripes = 8;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, size.height * i / stripes, size.width, size.height / stripes), stripe);
    }
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const m = 10.0;
    final field = Rect.fromLTWH(m, m, size.width - 2 * m, size.height - 2 * m);
    canvas.drawRect(field, line);
    canvas.drawLine(Offset(field.left, field.center.dy), Offset(field.right, field.center.dy), line);
    canvas.drawCircle(field.center, size.width * 0.14, line);
    final areaWidth = field.width * 0.56;
    final areaHeight = field.height * 0.14;
    canvas.drawRect(Rect.fromLTWH(field.center.dx - areaWidth / 2, field.top, areaWidth, areaHeight), line);
    canvas.drawRect(
      Rect.fromLTWH(field.center.dx - areaWidth / 2, field.bottom - areaHeight, areaWidth, areaHeight),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
