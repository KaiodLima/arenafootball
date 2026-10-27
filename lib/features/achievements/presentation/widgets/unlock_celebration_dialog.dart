import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/celebration_painters.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Comemoração de conquista desbloqueada: a medalha entra com mola e fica
/// balançando sobre raios dourados, com uma explosão de confete e vibração
/// (ao abrir e quando a medalha pousa). Devolve true
/// se o usuário tocou em "Ver conquistas".
Future<bool> showUnlockCelebration(BuildContext context, AchievementDTO achievement) async {
  final seeAll = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, __) => _UnlockCelebration(achievement: achievement),
  );
  return seeAll ?? false;
}

class _UnlockCelebration extends StatefulWidget {
  final AchievementDTO achievement;

  const _UnlockCelebration({required this.achievement});

  @override
  State<_UnlockCelebration> createState() => _UnlockCelebrationState();
}

class _UnlockCelebrationState extends State<_UnlockCelebration> with TickerProviderStateMixin {
  late final AnimationController _reveal =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  late final Animation<double> _medal =
      CurvedAnimation(parent: _reveal, curve: const Interval(0, 0.45, curve: Curves.elasticOut));
  late final Animation<double> _confetti = CurvedAnimation(parent: _reveal, curve: const Interval(0.2, 1));
  late final Animation<double> _texts = CurvedAnimation(parent: _reveal, curve: const Interval(0.35, 0.65));

  /// Vibração quando a medalha "pousa" (fim da entrada com mola).
  Timer? _landing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
    } else if (_reveal.value == 0 && !_reveal.isAnimating) {
      _reveal.forward();
      _loop.repeat();
      HapticFeedback.mediumImpact();
      _landing = Timer(const Duration(milliseconds: 900), HapticFeedback.heavyImpact);
    }
  }

  @override
  void dispose() {
    _landing?.cancel();
    _reveal.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievement = widget.achievement;
    final (_, dark) = medalColors(achievement.tier);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.s20),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s20, AppSizes.s24, AppSizes.s20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.achievementUnlockedTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.label(color: AppColors.primary).copyWith(
                      fontSize: AppSizes.s14,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    width: AppSizes.s250,
                    height: AppSizes.s250,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Raios girando devagar atrás da medalha.
                        AnimatedBuilder(
                          animation: _loop,
                          builder: (context, child) => Transform.rotate(angle: _loop.value * 2 * math.pi, child: child),
                          child: const CustomPaint(size: Size.square(AppSizes.s250), painter: RaysPainter()),
                        ),
                        // Medalha entrando com mola e balançando em 3D.
                        AnimatedBuilder(
                          animation: Listenable.merge([_medal, _loop]),
                          builder: (context, child) => Opacity(
                            opacity: _medal.value.clamp(0.0, 1.0),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..scaleByDouble(0.3 + 0.7 * _medal.value, 0.3 + 0.7 * _medal.value, 1, 1)
                                ..rotateY(math.sin(_loop.value * 4 * math.pi) * 0.35),
                              child: child,
                            ),
                          ),
                          child: MedalBadge(
                            tier: achievement.tier,
                            icon: achievement.icon,
                            unlocked: true,
                            size: AppSizes.s150,
                          ),
                        ),
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _confetti,
                            builder: (context, _) => CustomPaint(painter: ConfettiPainter(progress: _confetti.value)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeTransition(
                    opacity: _texts,
                    child: Column(
                      children: [
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.display().copyWith(fontSize: AppSizes.s28),
                        ),
                        if (achievement.description.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.s6),
                          Text(achievement.description, textAlign: TextAlign.center, style: AppTypography.subtitle()),
                        ],
                        const SizedBox(height: AppSizes.s14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Pill(text: achievementTierLabel(l10n, achievement.tier).toUpperCase(), color: dark),
                            const SizedBox(width: AppSizes.s8),
                            _Pill(text: l10n.achievementsPoints(achievement.points), color: AppColors.primaryDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.s20),
                  ArenaButton.primary(
                    title: l10n.achievementSeeAll,
                    function: () => Navigator.pop(context, true),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      l10n.achievementCelebrationClose,
                      style: AppTypography.label(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.s20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(text, style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12, letterSpacing: 1)),
      );
}
