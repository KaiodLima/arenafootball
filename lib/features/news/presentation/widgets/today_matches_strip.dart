import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Atalhos rolagem lateral com os jogos de hoje: "Lava Jato x Volta · 16:45".
/// O jogo escolhido (mesmos times do placar) fica destacado.
class TodayMatchesStrip extends StatelessWidget {
  final List<MatchDTO> matches;
  final MatchDTO? selected;
  final ValueChanged<MatchDTO> onPick;

  const TodayMatchesStrip({super.key, required this.matches, required this.onPick, this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final match in matches) ...[
            _MatchChip(match: match, selected: match.id == selected?.id, onTap: () => onPick(match)),
            const SizedBox(width: AppSizes.s8),
          ],
        ],
      ),
    );
  }
}

class _MatchChip extends StatelessWidget {
  final MatchDTO match;
  final bool selected;
  final VoidCallback onTap;

  const _MatchChip({required this.match, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.textPrimary;
    final secondary = selected ? AppColors.whiteSoft : AppColors.textSecondary;

    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.s14),
        side: BorderSide(color: selected ? AppColors.primaryDark : AppColors.greyLight),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${match.homeTeam}  ${match.homeGoals} × ${match.awayGoals}  ${match.awayTeam}',
                style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s14),
              ),
              if (match.time.isNotEmpty || match.venue.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s2),
                Text(
                  [match.time, match.venue].where((p) => p.trim().isNotEmpty).join(' · '),
                  style: AppTypography.subtitle(color: secondary).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
