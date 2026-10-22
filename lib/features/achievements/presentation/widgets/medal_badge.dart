import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_icons.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cores do metal de cada nível (clara em cima, escura embaixo).
(Color, Color) medalColors(AchievementTier tier) => switch (tier) {
      AchievementTier.bronze => (AppColors.medalBronzeLight, AppColors.medalBronzeDark),
      AchievementTier.silver => (AppColors.medalSilverLight, AppColors.medalSilverDark),
      AchievementTier.gold => (AppColors.medalGoldLight, AppColors.medalGoldDark),
      AchievementTier.legend => (AppColors.medalLegendLight, AppColors.medalLegendDark),
    };

/// Medalha redonda: metal do nível em degradê, aro claro, ícone no meio e um
/// reflexo diagonal. Bloqueada fica cinza com um anel do progresso em volta;
/// [hidden] (secreta bloqueada) mostra "?".
class MedalBadge extends StatelessWidget {
  final AchievementTier tier;
  final String icon;
  final bool unlocked;

  /// Progresso até a meta (0–1), desenhado em volta quando bloqueada.
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
    final (light, dark) = unlocked ? medalColors(tier) : (AppColors.medalLockedLight, AppColors.medalLockedDark);
    final ringGap = size * 0.08;
    final medal = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [light, dark]),
        boxShadow: unlocked
            ? [BoxShadow(color: dark.withValues(alpha: 0.45), blurRadius: size * 0.18, offset: Offset(0, size * 0.06))]
            : null,
      ),
      child: CustomPaint(
        painter: _MedalFacePainter(light: light, dark: dark, shine: unlocked),
        child: Center(
          child: hidden
              ? Text(
                  '?',
                  style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w900, color: AppColors.white),
                )
              : Icon(
                  achievementIcon(icon),
                  size: size * 0.44,
                  color: unlocked ? AppColors.white : AppColors.white.withValues(alpha: 0.9),
                  shadows: [Shadow(color: dark.withValues(alpha: 0.6), blurRadius: 4, offset: const Offset(0, 1))],
                ),
        ),
      ),
    );
    if (unlocked) return medal;
    // Bloqueada: anel do progresso em volta.
    return SizedBox(
      width: size + ringGap * 2,
      height: size + ringGap * 2,
      child: CustomPaint(
        painter: _ProgressRingPainter(progress: progress, width: size * 0.06),
        child: Center(child: medal),
      ),
    );
  }
}

class _MedalFacePainter extends CustomPainter {
  final Color light;
  final Color dark;
  final bool shine;

  _MedalFacePainter({required this.light, required this.dark, required this.shine});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    // Aro interno claro.
    canvas.drawCircle(
      center,
      radius * 0.8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.06
        ..color = AppColors.white.withValues(alpha: 0.45),
    );
    if (!shine) return;
    // Reflexo diagonal no alto.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    final band = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(0, size.height * 0.55)
      ..close();
    canvas.drawPath(band, Paint()..color = AppColors.white.withValues(alpha: 0.22));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MedalFacePainter old) => old.light != light || old.dark != dark || old.shine != shine;
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double width;

  _ProgressRingPainter({required this.progress, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(width / 2, width / 2, size.width - width, size.height - width);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = AppColors.greyLight;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      track
        ..color = AppColors.primary
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) => old.progress != progress || old.width != width;
}
