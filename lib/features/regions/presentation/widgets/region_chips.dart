import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Chips de região (sobre o header escuro da home), ligados ao [RegionCubit]
/// global. As regiões rolam na horizontal (a escolhida sempre fica à vista);
/// com [showSeason], o seletor de temporada fica fixo à direita, fora da
/// rolagem, para não sumir quando houver muitas regiões.
class RegionChips extends StatefulWidget {
  final bool showSeason;

  const RegionChips({super.key, this.showSeason = false});

  @override
  State<RegionChips> createState() => _RegionChipsState();
}

class _RegionChipsState extends State<RegionChips> {
  final _selectedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  /// Rola até a região escolhida (depois do frame, quando o chip já existe).
  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chip = _selectedKey.currentContext;
      if (!mounted || chip == null) return;
      Scrollable.ensureVisible(
        chip,
        alignment: 0.5,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegionCubit, RegionState>(
      listenWhen: (previous, current) =>
          previous.selectedRegion != current.selectedRegion || previous.regions != current.regions,
      listener: (_, __) => _revealSelected(),
      builder: (context, state) {
        final cubit = BlocProvider.of<RegionCubit>(context);
        final regions = state.regions.isEmpty ? [state.selectedRegion] : state.regions;

        final list = ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: AppSizes.s20, right: widget.showSeason ? AppSizes.s24 : AppSizes.s20),
          children: [
            for (final region in regions)
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.s8),
                child: _Chip(
                  key: region == state.selectedRegion ? _selectedKey : null,
                  label: region,
                  selected: region == state.selectedRegion,
                  onTap: () => cubit.selectRegion(region),
                ),
              ),
          ],
        );

        return SizedBox(
          height: AppSizes.s40,
          child: widget.showSeason
              ? Row(
                  // Mesma altura dos chips de região (na lista, eles já ocupam os 40).
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Degradê na borda direita: indica que há mais regiões.
                    Expanded(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [AppColors.black, AppColors.black, AppColors.transparent],
                          stops: [0, 0.88, 1],
                        ).createShader(bounds),
                        child: list,
                      ),
                    ),
                    Center(
                      child: Container(width: 1, height: AppSizes.s24, color: AppColors.white.withValues(alpha: 0.25)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSizes.s8, right: AppSizes.s20),
                      child: _SeasonChip(state: state, onSelected: cubit.selectSeason),
                    ),
                  ],
                )
              : list,
        );
      },
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
    super.key,
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
