import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// O que o seletor troca: a região ou a temporada.
enum RegionSelectorMode { region, season }

/// Seletor (fundo escuro) de região ou temporada, ligado ao [RegionCubit]
/// global. Substitui o `ArenaDropdownButton` e o dropdown de ano da home.
class RegionSelector extends StatelessWidget {
  final RegionSelectorMode mode;

  const RegionSelector({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegionCubit, RegionState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<RegionCubit>(context);
        final isRegion = mode == RegionSelectorMode.region;
        final items = isRegion ? state.regions : state.seasons;
        final value = isRegion ? state.selectedRegion : state.selectedSeason;

        return Container(
          margin: const EdgeInsets.all(AppSizes.s4),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s2),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppSizes.s4),
          ),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : null,
            hint: Text(value, style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18)),
            icon: const Icon(Icons.change_circle_outlined, color: AppColors.white),
            isExpanded: true,
            borderRadius: BorderRadius.circular(AppSizes.s16),
            style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18),
            underline: const SizedBox.shrink(),
            alignment: AlignmentDirectional.center,
            dropdownColor: AppColors.primary,
            onChanged: (newValue) {
              if (newValue == null) return;
              isRegion ? cubit.selectRegion(newValue) : cubit.selectSeason(newValue);
            },
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          ),
        );
      },
    );
  }
}
