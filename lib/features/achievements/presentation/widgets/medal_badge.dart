import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_icons.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cores do metal de cada nível (clara e escura).
(Color, Color) medalColors(AchievementTier tier) => switch (tier) {
      AchievementTier.bronze => (AppColors.medalBronzeLight, AppColors.medalBronzeDark),
      AchievementTier.silver => (AppColors.medalSilverLight, AppColors.medalSilverDark),
      AchievementTier.gold => (AppColors.medalGoldLight, AppColors.medalGoldDark),
      AchievementTier.legend => (AppColors.medalLegendLight, AppColors.medalLegendDark),
    };

/// Medalha hexagonal com chanfro (estilo prêmios do Apple Fitness): aro
/// escuro, bisel claro, face metálica em degradê, faixa de luz e fitinha
/// embaixo. Cada nível tem um detalhe: prata com aro duplo, ouro com raios em
/// volta, lenda com aro em degradê e brilho. Bloqueada é uma silhueta
/// cinza-clara com cadeado e o progresso desenhado em volta do hexágono; [hidden]
/// (secreta bloqueada) mostra "?".
class MedalBadge extends StatelessWidget {
  final AchievementTier tier;
  final String icon;
  final bool unlocked;

  /// Progresso até a meta (0–1), em volta da bloqueada.
  final double progress;
  final bool hidden;
  final double size;

  const MedalBadge({
    super.key,
    required this.tier,
    required this.icon,
    required this.unlocked,
    this.progress = 0,
    this.hidden = false,
    this.size = AppSizes.s72,
  });

  @override
  Widget build(BuildContext context) {
    final (_, dark) = medalColors(tier);
    final glyphColor = unlocked ? AppColors.white : AppColors.medalLockedDark;
    final glyphShadow = [
      Shadow(color: dark.withValues(alpha: unlocked ? 0.7 : 0), blurRadius: 3, offset: const Offset(0, 1))
    ];

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedalPainter(tier: tier, unlocked: unlocked, progress: progress),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -size * 0.03),
              child: hidden
                  ? Text(
                      '?',
                      style: TextStyle(
                        fontSize: size * 0.34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.medalLockedDark,
                      ),
                    )
                  : Icon(achievementIcon(icon), size: size * 0.34, color: glyphColor, shadows: glyphShadow),
            ),
            if (!unlocked)
              Positioned(
                right: size * 0.16,
                bottom: size * 0.14,
                child: Container(
                  padding: EdgeInsets.all(size * 0.03),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: Icon(Icons.lock_rounded, size: size * 0.13, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  final AchievementTier tier;
  final bool unlocked;
  final double progress;

  _MedalPainter({required this.tier, required this.unlocked, required this.progress});

  /// Hexágono de ponta para cima, centrado em [center].
  static Path hexagon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height * 0.47);
    final radius = s * 0.4;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final (light, dark) = medalColors(tier);

    if (!unlocked) {
      _paintLocked(canvas, center, radius, s);
      return;
    }

    // Fitinha atrás da medalha (duas pontas saindo de baixo).
    final ribbon = Paint()..color = dark;
    for (final side in [-1.0, 1.0]) {
      final x = center.dx + side * radius * 0.32;
      canvas.drawPath(
        Path()
          ..moveTo(x - radius * 0.2, center.dy + radius * 0.5)
          ..lineTo(x + radius * 0.2, center.dy + radius * 0.5)
          ..lineTo(x + radius * 0.2, center.dy + radius * 1.22)
          ..lineTo(x, center.dy + radius * 1.08)
          ..lineTo(x - radius * 0.2, center.dy + radius * 1.22)
          ..close(),
        ribbon,
      );
    }

    // Ouro: raios curtos em volta. Lenda: brilho difuso.
    if (tier == AchievementTier.gold) {
      final ray = Paint()..color = light.withValues(alpha: 0.85);
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6 - math.pi / 2 + math.pi / 12;
        final dir = Offset(math.cos(angle), math.sin(angle));
        final normal = Offset(-dir.dy, dir.dx) * radius * 0.06;
        final base = center + dir * radius * 0.95;
        final tip = center + dir * radius * 1.2;
        canvas.drawPath(
          Path()
            ..moveTo(base.dx + normal.dx, base.dy + normal.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(base.dx - normal.dx, base.dy - normal.dy)
            ..close(),
          ray,
        );
      }
    }
    if (tier == AchievementTier.legend) {
      canvas.drawPath(
        hexagon(center, radius * 1.08),
        Paint()
          ..color = light.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.18),
      );
    }

    // Sombra no chão.
    canvas.drawPath(
      hexagon(center + Offset(0, radius * 0.08), radius),
      Paint()
        ..color = AppColors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.1),
    );

    // Aro externo.
    final rim = Paint();
    if (tier == AchievementTier.legend) {
      rim.shader = ui.Gradient.sweep(center, [light, dark, light, dark, light], [0, 0.25, 0.5, 0.75, 1]);
    } else {
      rim.color = Color.lerp(dark, AppColors.black, 0.25)!;
    }
    canvas.drawPath(hexagon(center, radius), rim);

    // Bisel: degradê claro em cima, escuro embaixo.
    canvas.drawPath(
      hexagon(center, radius * 0.9),
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [light, dark])
            .createShader(bounds),
    );

    // Face: degradê invertido, dá o efeito de chanfro.
    final face = hexagon(center, radius * 0.76);
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(dark, light, 0.35)!, Color.lerp(light, AppColors.white, 0.15)!, dark],
          stops: const [0, 0.45, 1],
        ).createShader(bounds),
    );

    // Prata: aro interno duplo.
    if (tier == AchievementTier.silver) {
      canvas.drawPath(
        hexagon(center, radius * 0.66),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.035
          ..color = AppColors.white.withValues(alpha: 0.7),
      );
    }

    // Faixa de luz diagonal sobre a face.
    canvas.save();
    canvas.clipPath(face);
    canvas.drawPath(
      Path()
        ..moveTo(bounds.left, bounds.top + bounds.height * 0.42)
        ..lineTo(bounds.left + bounds.width * 0.42, bounds.top)
        ..lineTo(bounds.left + bounds.width * 0.62, bounds.top)
        ..lineTo(bounds.left, bounds.top + bounds.height * 0.62)
        ..close(),
      Paint()..color = AppColors.white.withValues(alpha: 0.28),
    );
    canvas.restore();
  }

  void _paintLocked(Canvas canvas, Offset center, double radius, double s) {
    // Silhueta cinza-clara: aro, face e um filete claro.
    canvas.drawPath(hexagon(center, radius), Paint()..color = AppColors.medalLockedDark.withValues(alpha: 0.55));
    final face = hexagon(center, radius * 0.86);
    canvas.drawPath(face, Paint()..color = AppColors.medalLockedLight);
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.03
        ..color = AppColors.white.withValues(alpha: 0.7),
    );
    // Progresso: contorno do hexágono a partir da ponta de cima.
    final outline = hexagon(center, radius * 1.13);
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..color = AppColors.greyLight,
    );
    if (progress <= 0) return;
    final metric = outline.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _MedalPainter old) =>
      old.tier != tier || old.unlocked != unlocked || old.progress != progress;
}
