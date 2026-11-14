import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Chip dourado de cartão (contatos desenhados), para a carteirinha.
class FanCardChip extends StatelessWidget {
  final double width;

  const FanCardChip({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.76,
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark, AppColors.medalGoldLight],
          stops: [0, 0.4, 0.75, 1],
        ).createShader(rect),
    );
    final line = Paint()
      ..color = AppColors.medalGoldDark.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, size.width * 0.03);
    final w = size.width;
    final h = size.height;
    // Contatos: duas colunas laterais e o bloco do meio.
    for (final y in [h * 0.33, h * 0.66]) {
      canvas.drawLine(Offset(0, y), Offset(w * 0.32, y), line);
      canvas.drawLine(Offset(w * 0.68, y), Offset(w, y), line);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.32, h * 0.18, w * 0.68, h * 0.82), Radius.circular(w * 0.06)),
      line,
    );
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h * 0.18), line);
    canvas.drawLine(Offset(w * 0.5, h * 0.82), Offset(w * 0.5, h), line);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(0.5), radius), line..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Guilhoché: ondas finas cruzadas, a textura de segurança dos cartões.
class FanCardGuilloche extends StatelessWidget {
  final Color color;

  const FanCardGuilloche({super.key, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GuillochePainter(color), size: Size.infinite);
}

class _GuillochePainter extends CustomPainter {
  final Color color;

  _GuillochePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final amplitude = size.height * 0.07;
    final wave = size.width / 3.2;
    for (var i = 0; i < 14; i++) {
      final baseY = size.height * (i / 13);
      final phase = i * 0.45;
      for (final flip in [1.0, -1.0]) {
        final path = Path();
        for (var x = 0.0; x <= size.width; x += 4) {
          final y = baseY + flip * amplitude * math.sin(x / wave * math.pi * 2 + phase);
          x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GuillochePainter oldDelegate) => oldDelegate.color != color;
}

/// Faixa diagonal da frente (cor secundária do time, translúcida).
class FanCardBand extends StatelessWidget {
  final Color color;

  const FanCardBand({super.key, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BandPainter(color), size: Size.infinite);
}

class _BandPainter extends CustomPainter {
  final Color color;

  _BandPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.56, 0)
        ..lineTo(w * 0.70, 0)
        ..lineTo(w * 0.46, h)
        ..lineTo(w * 0.32, h)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.16),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.73, 0)
        ..lineTo(w * 0.76, 0)
        ..lineTo(w * 0.52, h)
        ..lineTo(w * 0.49, h)
        ..close(),
      Paint()..color = color.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _BandPainter oldDelegate) => oldDelegate.color != color;
}
