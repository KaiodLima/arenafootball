import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';
import 'package:arena_soccer/features/stats/presentation/widgets/ranking_list.dart';
import 'package:arena_soccer/features/stats/presentation/widgets/ranking_podium.dart';
import 'package:arena_soccer/features/stats/presentation/widgets/ranking_type_switch.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Ranking de artilharia ou de assistências: pódio dos 3 primeiros no topo
/// escuro e os demais num card. [type] é o quesito inicial; o seletor troca
/// na própria tela. Sem [region]/[season], usa a região e a temporada
/// selecionadas no [RegionCubit].
class StatsRankingPage extends StatefulWidget {
  final StatsRankingType type;
  final String? region;
  final String? season;

  const StatsRankingPage({super.key, required this.type, this.region, this.season});

  @override
  State<StatsRankingPage> createState() => _StatsRankingPageState();
}

class _StatsRankingPageState extends State<StatsRankingPage> {
  late final String _region;
  late final String _season;

  @override
  void initState() {
    super.initState();
    final selected = BlocProvider.of<RegionCubit>(context).state;
    _region = widget.region ?? selected.selectedRegion;
    _season = widget.season ?? selected.selectedSeason;
    BlocProvider.of<StatsRankingCubit>(context).load(type: widget.type, region: _region, season: _season);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorite = context.watch<SessionCubit>().state.user?.favoriteTeam;
    final favoriteKey = (favorite == null || favorite.trim().isEmpty) ? null : normalizeTeamName(favorite);
    bool isFavorite(RankingEntry entry) => favoriteKey != null && normalizeTeamName(entry.player.team) == favoriteKey;

    return BlocBuilder<StatsRankingCubit, StatsRankingState>(
      builder: (context, state) {
        final isGoals = state.type == StatsRankingType.goals;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PageTitleBar(
            title: isGoals ? l10n.matchesTopScorers : l10n.matchesAssists,
            subtitle: l10n.groupsSubtitle(_region, _season),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  state: state,
                  isFavorite: isFavorite,
                  onTypeChanged: BlocProvider.of<StatsRankingCubit>(context).setType,
                ),
              ),
              ..._body(state, l10n, isGoals, isFavorite),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _body(
    StatsRankingState state,
    AppLocalizations l10n,
    bool isGoals,
    bool Function(RankingEntry) isFavorite,
  ) {
    Widget fill(Widget child) => SliverFillRemaining(hasScrollBody: false, child: child);

    if (state is LoadingStatsRankingState && state.entries.isEmpty) {
      return [fill(const Center(child: CircularProgressIndicator(color: AppColors.primary)))];
    }
    if (state is ErrorStatsRankingState && state.entries.isEmpty) {
      return [fill(ArenaEmptyState.error(message: l10n.statsLoadError))];
    }
    if (state.entries.isEmpty) {
      return [
        fill(ArenaEmptyState(
          message: isGoals ? l10n.statsEmptyGoals : l10n.statsEmptyAssists,
          icon: isGoals ? Icons.sports_soccer_rounded : Icons.assistant_rounded,
        )),
      ];
    }
    final rest = state.rest;
    if (rest.isEmpty) return const [SliverToBoxAdapter(child: SizedBox(height: AppSizes.s24))];
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s4, AppSizes.s16, AppSizes.s24),
        sliver: SliverToBoxAdapter(
          child: RankingList(entries: rest, type: state.type, crestOf: state.crestOf, isFavorite: isFavorite),
        ),
      ),
    ];
  }
}

/// Topo escuro: seletor de quesito, pódio e a borda arredondada da folha
/// clara que vem embaixo.
class _Header extends StatelessWidget {
  final StatsRankingState state;
  final bool Function(RankingEntry) isFavorite;
  final ValueChanged<StatsRankingType> onTypeChanged;

  const _Header({required this.state, required this.isFavorite, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    final podium = state.podium;

    return ColoredBox(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s4, AppSizes.s16, AppSizes.s20),
            child: RankingTypeSwitch(selected: state.type, onChanged: onTypeChanged),
          ),
          if (podium.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
              child: RankingPodium(podium: podium, type: state.type, crestOf: state.crestOf, isFavorite: isFavorite),
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
