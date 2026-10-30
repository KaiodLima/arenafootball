import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_picker_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Seletor de região da home (sobre o header escuro), ligado ao
/// [RegionCubit] global: um botão com a região atual que abre a folha com
/// busca, recentes e a lista toda (`showRegionPicker`). Com [showSeason], o
/// seletor de temporada fica ao lado.
class RegionChips extends StatelessWidget {
  final bool showSeason;

  const RegionChips({super.key, this.showSeason = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegionCubit, RegionState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<RegionCubit>(context);
        final regions = state.regions.isEmpty ? [state.selectedRegion] : state.regions;

        Future<void> pick() async {
          final region = await showRegionPicker(
            context,
            regions: regions,
            selected: state.selectedRegion,
            recent: state.recentRegions,
          );
          if (region != null && region != state.selectedRegion) await cubit.selectRegion(region);
        }

        return SizedBox(
          height: AppSizes.s44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _RegionButton(region: state.selectedRegion, onTap: pick)),
                if (showSeason) ...[
                  const SizedBox(width: AppSizes.s8),
                  // Mesma altura do botão da região (a Row estica os dois).
                  _SeasonChip(state: state, onSelected: cubit.selectSeason),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pílula com a região atual: 📍, o nome e "Trocar ▾".
class _RegionButton extends StatelessWidget {
  final String region;
  final VoidCallback onTap;

  const _RegionButton({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.regionPickerTitle,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.12),
        shape: StadiumBorder(side: BorderSide(color: AppColors.white.withValues(alpha: 0.3))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSizes.s12, right: AppSizes.s12),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.gold, size: AppSizes.s20),
                const SizedBox(width: AppSizes.s6),
                Expanded(
                  child: Text(
                    region,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
                  ),
                ),
                Text(
                  l10n.regionPickerChange,
                  style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.whiteSoft, size: AppSizes.s20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.white : AppColors.white.withValues(alpha: 0.12),
      shape: StadiumBorder(side: BorderSide(color: AppColors.white.withValues(alpha: selected ? 1 : 0.25))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(left: leading != null ? AppSizes.s12 : AppSizes.s16, right: AppSizes.s16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: AppSizes.s6)],
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

/// Temporada compacta (ícone + ano); o texto completo fica no tooltip e no menu.
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
          label: state.selectedSeason,
          selected: false,
          onTap: () {},
          leading: const Icon(Icons.calendar_month_rounded, color: AppColors.white, size: AppSizes.s16),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: AppSizes.s18),
        ),
      ),
    );
  }
}
