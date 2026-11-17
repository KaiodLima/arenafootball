import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_podium.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

const _display = 'Anton';

/// Campeão da competição encerrada (Visão geral do detalhe): degradê nas
/// cores do time, troféu dourado, escudo grande e o vice embaixo.
class ChampionBanner extends StatelessWidget {
  final ChampionshipPodiumTeam champion;
  final ChampionshipPodiumTeam? runnerUp;

  const ChampionBanner({super.key, required this.champion, this.runnerUp});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = TeamPalette.orDefault(champion.primaryColor, champion.secondaryColor);
    final onAccent = palette.onAccent;
    return Container(
      key: const ValueKey('champion-banner'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.accent, palette.accentDark],
        ),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -AppSizes.s24,
            bottom: -AppSizes.s24,
            child: Icon(Icons.emoji_events_rounded, size: AppSizes.s120, color: AppColors.gold.withValues(alpha: 0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.s16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.s4),
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: TeamCrest(imageUrl: champion.imageUrl, size: AppSizes.s72),
                ),
                const SizedBox(width: AppSizes.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s18),
                          const SizedBox(width: AppSizes.s4),
                          Text(
                            l10n.championshipChampionTitle,
                            style: const TextStyle(
                              fontFamily: _display,
                              color: AppColors.gold,
                              fontSize: AppSizes.s16,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.s2),
                      Text(
                        champion.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: _display, color: onAccent, fontSize: AppSizes.s24, height: 1.1),
                      ),
                      if (runnerUp != null) ...[
                        const SizedBox(height: AppSizes.s6),
                        Text(
                          l10n.championshipRunnerUp(runnerUp!.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: onAccent.withValues(alpha: 0.85))
                              .copyWith(fontSize: AppSizes.s12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
