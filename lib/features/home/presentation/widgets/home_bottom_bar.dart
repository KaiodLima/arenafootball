import 'package:flutter/material.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Barra inferior em pílula com as quatro abas da home.
class HomeBottomBar extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  const HomeBottomBar({super.key, required this.selected, required this.onSelected});

  String _label(HomeTab tab, AppLocalizations l10n) {
    switch (tab) {
      case HomeTab.news:
        return l10n.homeTabHome;
      case HomeTab.championships:
        return l10n.homeTabChampionships;
      case HomeTab.teams:
        return l10n.homeTabTeams;
      case HomeTab.tables:
        return l10n.homeTabTables;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSizes.s14),
        height: AppSizes.bottomBarHeight,
        padding: const EdgeInsets.all(AppSizes.s10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.bottomBarRadius),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: HomeTab.values.map((tab) {
              final isSelected = tab == selected;
              return TextButton(
                onPressed: () => onSelected(tab),
                child: Row(
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.circle, color: AppColors.primaryDark, size: AppSizes.s10),
                      const SizedBox(width: AppSizes.s4),
                    ],
                    Text(
                      _label(tab, l10n),
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.whiteMuted,
                        fontSize: AppSizes.s14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
