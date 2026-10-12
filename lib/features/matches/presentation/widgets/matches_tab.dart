import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_list.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_day_switch.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba de tabelas da home: encontra o campeonato da região selecionada e
/// mostra as partidas de ontem, hoje ou amanhã, com atalhos para todos os jogos, grupos,
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
          create: (_) => MatchesCubit(sl(), sl(), sl(), sl(), sl())
            ..watch(
              championshipId: championshipId,
              filter: MatchesFilter.today,
              region: region.selectedRegion,
              season: region.selectedSeason,
            ),
          child: _DayMatches(championshipId: championshipId, region: region.selectedRegion, season: region.selectedSeason),
        );
      },
    );
  }
}

/// Atalhos, seletor de dia (ontem/hoje/amanhã) e as partidas do dia escolhido.
class _DayMatches extends StatefulWidget {
  final int championshipId;
  final String region;
  final String season;

  const _DayMatches({required this.championshipId, required this.region, required this.season});

  @override
  State<_DayMatches> createState() => _DayMatchesState();
}

class _DayMatchesState extends State<_DayMatches> {
  MatchesFilter _day = MatchesFilter.today;

  void _selectDay(MatchesFilter day) {
    setState(() => _day = day);
    BlocProvider.of<MatchesCubit>(context).selectDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, empty) = switch (_day) {
      MatchesFilter.yesterday => (l10n.matchesYesterdayTitle, l10n.matchesNoGamesYesterday),
      MatchesFilter.tomorrow => (l10n.matchesTomorrowTitle, l10n.matchesNoGamesTomorrow),
      _ => (l10n.homeTodayMatches, l10n.matchesNoGamesToday),
    };

    return MatchesList(
      season: widget.season,
      emptyMessage: empty,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Shortcuts(championshipId: widget.championshipId, region: widget.region, season: widget.season),
          const SizedBox(height: AppSizes.s20),
          MatchDaySwitch(selected: _day, onChanged: _selectDay),
          const SizedBox(height: AppSizes.s16),
          BlocSelector<MatchesCubit, MatchesState, int>(
            selector: (state) => state is LoadingMatchesState ? -1 : state.visibleMatches.length,
            builder: (context, count) => SectionHeader(
              title: title,
              trailing: count > 0
                  ? Text(l10n.matchesDayCount(count), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Atalhos para outras telas do campeonato, em 4 blocos iguais.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShortcutTile(
          title: l10n.matchesAllGames,
          icon: Icons.calendar_month_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.matchesPage,
            arguments: {'championshipId': championshipId, 'region': region, 'season': season},
          ),
        ),
        _ShortcutTile(
          title: l10n.matchesGroups,
          icon: Icons.groups_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.groupsPage,
            arguments: {'region': region, 'season': season},
          ),
        ),
        _ShortcutTile(
          title: l10n.matchesTopScorers,
          icon: Icons.sports_soccer_rounded,
          onTap: () => _openStats(context, StatsRankingType.goals),
        ),
        _ShortcutTile(
          title: l10n.matchesAssists,
          icon: Icons.assistant_rounded,
          onTap: () => _openStats(context, StatsRankingType.assists),
        ),
      ],
    );
  }
}

/// Bloco de atalho: ícone num círculo verde-claro e o rótulo embaixo.
class _ShortcutTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: title,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s2),
            child: Column(
              children: [
                Container(
                  width: AppSizes.s48,
                  height: AppSizes.s48,
                  decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.s22),
                ),
                const SizedBox(height: AppSizes.s6),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12, height: 1.15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
