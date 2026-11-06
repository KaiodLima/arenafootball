import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Altura da barra fixa do elenco.
const double squadToolbarHeight = AppSizes.s64;

/// Barra fixa do elenco (fica presa abaixo do cabeçalho ao rolar): as abas de
/// competição e, à direita, a busca e a ordenação. Com a busca aberta, o
/// campo ocupa a barra.
class SquadToolbar extends StatelessWidget {
  /// Abas de competição (chips), roláveis na horizontal.
  final Widget tabs;
  final bool searching;
  final String query;
  final ValueChanged<String> onSearch;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final PlayersSort sort;
  final ValueChanged<PlayersSort> onSort;
  final Color accent;

  const SquadToolbar({
    super.key,
    required this.tabs,
    required this.searching,
    required this.query,
    required this.onSearch,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.sort,
    required this.onSort,
    required this.accent,
  });

  String _sortLabel(AppLocalizations l10n, PlayersSort sort) => switch (sort) {
        PlayersSort.position => l10n.squadSortPosition,
        PlayersSort.goals => l10n.playersSortGoals,
        PlayersSort.assists => l10n.playersSortAssists,
        PlayersSort.name => l10n.playersSortName,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: squadToolbarHeight,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s8, AppSizes.s10),
      child: searching
          ? Row(
              children: [
                Expanded(
                  child: ArenaSearchField(
                    hint: l10n.squadSearch,
                    initialValue: query,
                    autofocus: true,
                    onChanged: onSearch,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onCloseSearch,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: tabs),
                IconButton(
                  tooltip: l10n.squadSearch,
                  onPressed: onOpenSearch,
                  icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
                ),
                PopupMenuButton<PlayersSort>(
                  tooltip: l10n.squadSortBy,
                  initialValue: sort,
                  onSelected: onSort,
                  icon: Icon(Icons.sort_rounded, color: accent),
                  itemBuilder: (_) => [
                    PopupMenuItem<PlayersSort>(enabled: false, child: Text(l10n.squadSortBy)),
                    for (final option in PlayersSort.values)
                      CheckedPopupMenuItem<PlayersSort>(
                        value: option,
                        checked: option == sort,
                        child: Text(_sortLabel(l10n, option)),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Delegate da barra fixa (altura constante).
class SquadToolbarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const SquadToolbarDelegate({required this.child});

  @override
  double get minExtent => squadToolbarHeight;

  @override
  double get maxExtent => squadToolbarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(
        color: AppColors.background,
        elevation: overlapsContent || shrinkOffset > 0 ? 2 : 0,
        shadowColor: AppColors.shadow,
        child: child,
      );

  @override
  bool shouldRebuild(covariant SquadToolbarDelegate oldDelegate) => true;
}
