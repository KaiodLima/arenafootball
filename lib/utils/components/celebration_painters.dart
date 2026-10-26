import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Efeitos de comemoração (tela do eleito, conquista desbloqueada).

/// Feixes dourados em volta do centro, mais fortes perto da foto.
class RaysPainter extends CustomPainter {
  const RaysPainter();

  static const int _count = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.gold.withValues(alpha: 0.45), AppColors.gold.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    const half = math.pi / _count / 2.2;
    for (var i = 0; i < _count; i++) {
      final angle = i * 2 * math.pi / _count;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + radius * math.cos(angle - half), center.dy + radius * math.sin(angle - half))
        ..lineTo(center.dx + radius * math.cos(angle + half), center.dy + radius * math.sin(angle + half))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RaysPainter oldDelegate) => false;
}

/// Uma explosão de confete (dourado, verde e branco) a partir do centro, com
/// gravidade, giro e sumindo no fim. Partículas fixas (semente constante).
class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter({required this.progress});

  static final List<_Particle> _particles = _Particle.burst(42);

  static const List<Color> _colors = [AppColors.gold, AppColors.primary, AppColors.primaryDark, AppColors.white];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final fade = progress < 0.7 ? 1.0 : (1 - progress) / 0.3;
    for (final p in _particles) {
      final t = progress;
      final dx = math.cos(p.angle) * p.speed * t;
      // Sobe rápido e cai pela gravidade.
      final dy = math.sin(p.angle) * p.speed * t + 260 * t * t;
      final paint = Paint()..color = _colors[p.color].withValues(alpha: fade);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * t * 2 * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), const Radius.circular(1)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final int color;

  const _Particle(this.angle, this.speed, this.size, this.spin, this.color);

  static List<_Particle> burst(int count) {
    final random = math.Random(7);
    return [
      for (var i = 0; i < count; i++)
        _Particle(
          // Leque para cima e para os lados (o confete não "afunda" no cartão).
          -math.pi * (1.1 - random.nextDouble() * 1.2),
          150 + random.nextDouble() * 170,
          6 + random.nextDouble() * 6,
          (random.nextDouble() - 0.5) * 4,
          random.nextInt(4),
        ),
    ];
  }
}
