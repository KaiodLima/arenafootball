import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_state.dart';
import 'package:arena_soccer/features/global_results/presentation/widgets/league_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/arena_segmented_pill.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Resultados de jogos pelo mundo (web scraping do soccerstats.com): seletor
/// de dia no topo escuro, busca + filtro "ao vivo" e os jogos em cards por
/// liga. Puxar para baixo recarrega o dia.
class GlobalResultsPage extends StatefulWidget {
  const GlobalResultsPage({super.key});

  @override
  State<GlobalResultsPage> createState() => _GlobalResultsPageState();
}

class _GlobalResultsPageState extends State<GlobalResultsPage> {
  late final GlobalResultsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<GlobalResultsCubit>(context);
    _cubit.load(ResultsDay.today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PageTitleBar(title: l10n.globalResultsTitle, subtitle: l10n.globalResultsSubtitle),
      body: BlocBuilder<GlobalResultsCubit, GlobalResultsState>(
        builder: (context, state) {
          final groups = state.groups;
          final showLive = state.day == ResultsDay.today && state.liveCount > 0;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _cubit.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _Header(day: state.day, onChanged: _cubit.load)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ArenaSearchField(hint: l10n.globalResultsSearchHint, onChanged: _cubit.setQuery),
                        ),
                        if (showLive) ...[
                          const SizedBox(width: AppSizes.s8),
                          _LiveChip(
                            label: l10n.globalResultsLiveFilter(state.liveCount),
                            selected: state.liveOnly,
                            onTap: _cubit.toggleLive,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state is LoadingGlobalResultsState)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (state is ErrorGlobalResultsState && state.matches.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ArenaEmptyState.error(message: state.errorMessage),
                        ArenaButton.outlined(
                          title: l10n.commonTryAgain,
                          width: AppSizes.s200,
                          function: () => _cubit.load(state.day),
                        ),
                      ],
                    ),
                  )
                else if (groups.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ArenaEmptyState(message: l10n.globalResultsNoMatches, icon: Icons.sports_soccer_outlined),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
                    sliver: SliverList.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) =>
                          LeagueCard(key: ValueKey(groups[index].league), group: groups[index]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Topo escuro: seletor Ontem | Hoje | Amanhã e a borda arredondada da folha
/// clara que vem embaixo.
class _Header extends StatelessWidget {
  final ResultsDay day;
  final ValueChanged<ResultsDay> onChanged;

  const _Header({required this.day, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s4, AppSizes.s16, AppSizes.s20),
            child: ArenaSegmentedPill(
              segments: [
                ArenaSegment(label: l10n.globalResultsYesterday),
                ArenaSegment(label: l10n.globalResultsToday),
                ArenaSegment(label: l10n.globalResultsTomorrow),
              ],
              selectedIndex: ResultsDay.values.indexOf(day),
              onChanged: (index) {
                final selected = ResultsDay.values[index];
                if (selected != day) onChanged(selected);
              },
            ),
          ),
          Container(
            height: AppSizes.sheetOverlap,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip "● Ao vivo (5)": liga/desliga o filtro de jogos em andamento.
class _LiveChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LiveChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.danger;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.danger : AppColors.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.danger : AppColors.greyLight)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.s8,
                  height: AppSizes.s8,
                  decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSizes.s6),
                Text(label, style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
