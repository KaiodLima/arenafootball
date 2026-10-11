import 'package:flutter/material.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Barra de navegação inferior (Material 3) com as quatro abas da home.
class HomeBottomBar extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  const HomeBottomBar({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s20, offset: Offset(0, -AppSizes.s2))],
      ),
      child: NavigationBar(
        selectedIndex: HomeTab.values.indexOf(selected),
        onDestinationSelected: (index) => onSelected(HomeTab.values[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.homeTabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events_rounded),
            label: l10n.homeTabChampionships,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shield_outlined),
            selectedIcon: const Icon(Icons.shield_rounded),
            label: l10n.homeTabTeams,
          ),
          NavigationDestination(
            icon: const Icon(Icons.leaderboard_outlined),
            selectedIcon: const Icon(Icons.leaderboard_rounded),
            label: l10n.homeTabTables,
          ),
        ],
      ),
    );
  }
}
