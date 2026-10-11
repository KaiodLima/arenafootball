import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Chips de região (sobre o header escuro da home), ligados ao [RegionCubit]
/// global. Com [showSeason], o último chip escolhe a temporada.
class RegionChips extends StatelessWidget {
  final bool showSeason;

  const RegionChips({super.key, this.showSeason = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegionCubit, RegionState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<RegionCubit>(context);
        final regions = state.regions.isEmpty ? [state.selectedRegion] : state.regions;

        return SizedBox(
          height: AppSizes.s40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
            children: [
              for (final region in regions)
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.s8),
                  child: _Chip(
                    label: region,
                    selected: region == state.selectedRegion,
                    onTap: () => cubit.selectRegion(region),
                  ),
                ),
              if (showSeason) _SeasonChip(state: state, onSelected: cubit.selectSeason),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _Chip({required this.label, required this.selected, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.white : AppColors.white.withValues(alpha: 0.12),
      shape: StadiumBorder(side: BorderSide(color: AppColors.white.withValues(alpha: selected ? 1 : 0.25))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.label(color: selected ? AppColors.primaryDark : AppColors.white),
              ),
              if (trailing != null) ...[const SizedBox(width: AppSizes.s4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonChip extends StatelessWidget {
  final RegionState state;
  final ValueChanged<String> onSelected;

  const _SeasonChip({required this.state, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.homeSeasonChip(state.selectedSeason),
      onSelected: onSelected,
      itemBuilder: (_) => state.seasons
          .map((season) => CheckedPopupMenuItem<String>(
                value: season,
                checked: season == state.selectedSeason,
                child: Text(l10n.homeSeasonChip(season)),
              ))
          .toList(),
      child: IgnorePointer(
        child: _Chip(
          label: l10n.homeSeasonChip(state.selectedSeason),
          selected: false,
          onTap: () {},
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: AppSizes.s18),
        ),
      ),
    );
  }
}
