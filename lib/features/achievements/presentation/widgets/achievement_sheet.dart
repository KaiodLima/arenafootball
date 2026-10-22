import 'package:flutter/material.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Detalhes de uma conquista: medalha grande, descrição, progresso, nível,
/// pontos e a data em que foi conquistada.
Future<void> showAchievementSheet(BuildContext context, AchievementEntry entry) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AchievementSheet(entry: entry),
    );

class _AchievementSheet extends StatelessWidget {
  final AchievementEntry entry;

  const _AchievementSheet({required this.entry});

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final achievement = entry.achievement;
    final (_, tierColor) = medalColors(achievement.tier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s24, 0, AppSizes.s24, AppSizes.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MedalBadge(
              tier: achievement.tier,
              icon: achievement.icon,
              unlocked: entry.unlocked,
              progress: entry.progress,
              hidden: entry.hidden,
              size: AppSizes.s100,
            ),
            const SizedBox(height: AppSizes.s16),
            Text(
              entry.hidden ? l10n.achievementsSecret : achievement.title,
              textAlign: TextAlign.center,
              style: AppTypography.title().copyWith(fontSize: AppSizes.s22),
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              entry.hidden ? l10n.achievementsSecretHint : achievement.description,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(),
            ),
            const SizedBox(height: AppSizes.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Pill(
                  text: achievementTierLabel(l10n, achievement.tier),
                  color: entry.unlocked ? tierColor : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.s8),
                _Pill(text: l10n.achievementsPoints(achievement.points), color: AppColors.primaryDark),
              ],
            ),
            const SizedBox(height: AppSizes.s20),
            if (entry.unlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: AppSizes.s20),
                  const SizedBox(width: AppSizes.s6),
                  Text(
                    entry.unlockedAt != null
                        ? l10n.achievementsUnlockedOn(_date(entry.unlockedAt!))
                        : l10n.achievementsUnlocked,
                    style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
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
                  backgroundColor: AppColors.greyLight,
                ),
              ),
              const SizedBox(height: AppSizes.s6),
              Text(
                l10n.achievementsProgress(entry.current.clamp(0, achievement.goal), achievement.goal),
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.s20),
        ),
        child: Text(text, style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s12)),
      );
}
