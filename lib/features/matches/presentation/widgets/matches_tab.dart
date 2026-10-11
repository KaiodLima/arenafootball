import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_list.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_shortcut_button.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Aba de tabelas da home: encontra o campeonato da região selecionada e
/// mostra as partidas do dia dele, com atalhos para todos os jogos, grupos,
/// artilharia e assistências. A home recria a aba (key) quando região/ano mudam.
class MatchesTab extends StatelessWidget {
  const MatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    return BlocProvider<ChampionshipsCubit>(
      create: (_) => ChampionshipsCubit(sl())..watch(region: region),
      child: const _ChampionshipMatches(),
    );
  }
}

class _ChampionshipMatches extends StatelessWidget {
  const _ChampionshipMatches();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = BlocProvider.of<RegionCubit>(context).state;

    return BlocBuilder<ChampionshipsCubit, ChampionshipsState>(
      builder: (context, state) {
        if (state is LoadingChampionshipsState && state.championships.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorChampionshipsState && state.championships.isEmpty) {
          return ArenaEmptyState.error(message: l10n.championshipsLoadError);
        }
        if (state.championships.isEmpty) {
          return ArenaEmptyState(message: l10n.matchesNoChampionship, icon: Icons.emoji_events_outlined);
        }

        ChampionshipDTO? championship;
        for (final item in state.championships) {
          if (item.region == region.selectedRegion) {
            championship = item;
            break;
          }
        }
        if (championship == null) {
          return ArenaEmptyState(message: l10n.matchesNoChampionship, icon: Icons.emoji_events_outlined);
        }

        final championshipId = championship.championshipId;
        return BlocProvider<MatchesCubit>(
          key: ValueKey(championshipId),
          create: (_) => MatchesCubit(sl(), sl(), sl(), sl())
            ..watch(championshipId: championshipId, filter: MatchesFilter.today, season: region.selectedSeason),
          child: MatchesList(
            season: region.selectedSeason,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Shortcuts(
                  championshipId: championshipId,
                  region: region.selectedRegion,
                  season: region.selectedSeason,
                ),
                const SizedBox(height: AppSizes.s16),
                SectionHeader(title: l10n.homeTodayMatches),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Shortcuts extends StatelessWidget {
  final int championshipId;
  final String region;
  final String season;

  const _Shortcuts({required this.championshipId, required this.region, required this.season});

  void _openStats(BuildContext context, StatsRankingType type) => Navigator.pushNamed(
        context,
        AppRoutes.statsRankingPage,
        arguments: {'type': type, 'region': region, 'season': season},
      );

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.only(right: AppSizes.s8), child: child);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _padded(MatchesShortcutButton(
            title: l10n.matchesAllGames,
            icon: Icons.calendar_month_rounded,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.matchesPage,
              arguments: {'championshipId': championshipId, 'region': region, 'season': season},
            ),
          )),
          _padded(MatchesShortcutButton(
            title: l10n.matchesGroups,
            icon: Icons.groups_rounded,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.groupsPage,
              arguments: {'region': region, 'season': season},
            ),
          )),
          _padded(MatchesShortcutButton(
            title: l10n.matchesTopScorers,
            icon: Icons.sports_soccer_rounded,
            onPressed: () => _openStats(context, StatsRankingType.goals),
          )),
          _padded(MatchesShortcutButton(
            title: l10n.matchesAssists,
            icon: Icons.assistant_rounded,
            onPressed: () => _openStats(context, StatsRankingType.assists),
          )),
        ],
      ),
    );
  }
}
