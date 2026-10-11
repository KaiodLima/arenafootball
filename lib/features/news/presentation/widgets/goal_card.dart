import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de gol do feed: filete verde, selo "GOL" e o placar em destaque.
class GoalCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;

  const GoalCard({super.key, required this.news, this.trailing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teamStyle = AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16);

    return ArenaCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: AppSizes.s6, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s12, AppSizes.s8, AppSizes.s14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSizes.s8),
                      ),
                      child: Text(
                        '⚽ ${l10n.newsGoalLabel}',
                        style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s10),
                    Row(
                      children: [
                        Flexible(
                          child: Text(news.homeTeam, maxLines: 1, overflow: TextOverflow.ellipsis, style: teamStyle),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                          child: Text(
                            '${news.homeGoals} × ${news.awayGoals}',
                            style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
                          ),
                        ),
                        Flexible(
                          child: Text(news.awayTeam, maxLines: 1, overflow: TextOverflow.ellipsis, style: teamStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.topCenter, child: trailing!)
            else
              Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: Image.asset(AppImages.ballInNet, width: AppSizes.s48, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}
