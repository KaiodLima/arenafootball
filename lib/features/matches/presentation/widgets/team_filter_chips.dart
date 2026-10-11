import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Chips roláveis "Todos" + um por time (o do usuário primeiro, com ★).
class TeamFilterChips extends StatelessWidget {
  final List<String> teams;
  final String? selected;
  final String? favoriteTeam;
  final String? Function(String teamName) crestOf;
  final ValueChanged<String?> onSelected;

  const TeamFilterChips({
    super.key,
    required this.teams,
    required this.selected,
    required this.crestOf,
    required this.onSelected,
    this.favoriteTeam,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordered = [
      ...teams.where((t) => t == favoriteTeam),
      ...teams.where((t) => t != favoriteTeam),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _Chip(label: l10n.matchesFilterAll, selected: selected == null, onTap: () => onSelected(null)),
          for (final team in ordered)
            _Chip(
              label: team,
              selected: selected == team,
              leading: TeamCrest(imageUrl: crestOf(team), size: AppSizes.s22),
              isFavorite: team == favoriteTeam,
              onTap: () => onSelected(team),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Widget? leading;
  final bool isFavorite;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap, this.leading, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.primaryDark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.s8),
      child: Material(
        color: selected ? AppColors.primaryDark : AppColors.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primaryDark : AppColors.greyLight)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              leading == null ? AppSizes.s16 : AppSizes.s6,
              AppSizes.s6,
              AppSizes.s14,
              AppSizes.s6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: AppSizes.s6)],
                if (isFavorite) ...[
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s16),
                  const SizedBox(width: AppSizes.s2),
                ],
                Text(label, style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
