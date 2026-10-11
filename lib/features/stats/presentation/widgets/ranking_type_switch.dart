import 'package:flutter/material.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Seletor em pílula Gols | Assistências, para fundo escuro.
class RankingTypeSwitch extends StatelessWidget {
  final StatsRankingType selected;
  final ValueChanged<StatsRankingType> onChanged;

  const RankingTypeSwitch({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.whiteMuted, borderRadius: BorderRadius.circular(AppSizes.s24)),
      child: Row(
        children: [
          _Segment(
            icon: Icons.sports_soccer_rounded,
            label: l10n.matchesTopScorers,
            selected: selected == StatsRankingType.goals,
            onTap: () => onChanged(StatsRankingType.goals),
          ),
          _Segment(
            icon: Icons.assistant_rounded,
            label: l10n.matchesAssists,
            selected: selected == StatsRankingType.assists,
            onTap: () => onChanged(StatsRankingType.assists),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.white;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: AppSizes.s40,
            decoration: BoxDecoration(
              color: selected ? AppColors.white : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.s20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.s18, color: color),
                const SizedBox(width: AppSizes.s6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
