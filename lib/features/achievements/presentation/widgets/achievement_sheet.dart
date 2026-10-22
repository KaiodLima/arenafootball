import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Detalhes de uma conquista em tela cheia escura: a medalha grande balançando
/// em 3D sobre um holofote, título, descrição, nível, pontos e o progresso
/// (ou a data em que foi conquistada). Toque fora ou ✕ fecha.
Future<void> showAchievementDetails(BuildContext context, AchievementEntry entry) => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale:
              Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
          child: child,
        ),
      ),
      pageBuilder: (context, _, __) => _AchievementDetails(entry: entry),
    );

class _AchievementDetails extends StatefulWidget {
  final AchievementEntry entry;

  const _AchievementDetails({required this.entry});

  @override
  State<_AchievementDetails> createState() => _AchievementDetailsState();
}

class _AchievementDetailsState extends State<_AchievementDetails> with SingleTickerProviderStateMixin {
  late final AnimationController _swing = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _swing.stop();
    } else if (!_swing.isAnimating) {
      _swing.repeat();
    }
  }

  @override
  void dispose() {
    _swing.dispose();
    super.dispose();
  }

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = widget.entry;
    final achievement = entry.achievement;
    final (light, _) = medalColors(achievement.tier);
    final accent = entry.unlocked ? light : AppColors.white.withValues(alpha: 0.6);

    return SafeArea(
      child: Material(
        color: AppColors.transparent,
        child: Stack(
          children: [
            Positioned(
              top: AppSizes.s8,
              right: AppSizes.s8,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.white),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.s32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Holofote + medalha balançando em 3D.
                    Container(
                      width: AppSizes.s250,
                      height: AppSizes.s250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (entry.unlocked ? light : AppColors.trophyGlow).withValues(alpha: 0.35),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _swing,
                        builder: (context, child) => Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(math.sin(_swing.value * 2 * math.pi) * 0.45),
                          child: child,
                        ),
                        child: MedalBadge(
                          tier: achievement.tier,
                          icon: achievement.icon,
                          unlocked: entry.unlocked,
                          progress: entry.progress,
                          hidden: entry.hidden,
                          size: AppSizes.s200,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    Text(
                      entry.hidden ? l10n.achievementsSecret : achievement.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s28),
                    ),
                    const SizedBox(height: AppSizes.s8),
                    Text(
                      entry.hidden ? l10n.achievementsSecretHint : achievement.description,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(color: AppColors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: AppSizes.s20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Pill(text: achievementTierLabel(l10n, achievement.tier).toUpperCase(), color: accent),
                        const SizedBox(width: AppSizes.s8),
                        _Pill(text: l10n.achievementsPoints(achievement.points), color: AppColors.gold),
                      ],
                    ),
                    const SizedBox(height: AppSizes.s24),
                    if (entry.unlocked)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.primary, size: AppSizes.s20),
                          const SizedBox(width: AppSizes.s6),
                          Text(
                            entry.unlockedAt != null
                                ? l10n.achievementsUnlockedOn(_date(entry.unlockedAt!))
                                : l10n.achievementsUnlocked,
                            style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                          ),
                        ],
                      )
                    else if (!entry.hidden) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.s8),
                        child: LinearProgressIndicator(
                          value: entry.progress,
                          minHeight: AppSizes.s10,
                          color: AppColors.primary,
                          backgroundColor: AppColors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s8),
                      Text(
                        l10n.achievementsProgress(entry.current.clamp(0, achievement.goal), achievement.goal),
                        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
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
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppSizes.s20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          text,
          style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
        ),
      );
}
