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
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/shortcut_tile.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba de tabelas da home: campeonatos da região na temporada (chips quando
/// há mais de um ao mesmo tempo) e as partidas de ontem, hoje ou amanhã do
/// escolhido, com atalhos para todos os jogos, grupos, artilharia e
/// assistências. A home recria a aba (key) quando região/ano mudam.
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

class _ChampionshipMatches extends StatefulWidget {
  const _ChampionshipMatches();

  @override
  State<_ChampionshipMatches> createState() => _ChampionshipMatchesState();
}

class _ChampionshipMatchesState extends State<_ChampionshipMatches> {
  /// Campeonato escolhido por região/temporada, lembrado enquanto o app está
  /// aberto (a home recria a aba ao trocar de região).
  static final Map<String, int> _remembered = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = BlocProvider.of<RegionCubit>(context).state;
    final key = '${region.selectedRegion}|${region.selectedSeason}';

    return BlocBuilder<ChampionshipsCubit, ChampionshipsState>(
      builder: (context, state) {
        if (state is LoadingChampionshipsState && state.championships.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorChampionshipsState && state.championships.isEmpty) {
          return ArenaEmptyState.error(message: l10n.championshipsLoadError);
        }

        // Os da temporada selecionada (podem ser vários ao mesmo tempo); sem
        // nenhum, o primeiro da região (dados antigos sem `ano`).
        final inRegion = state.championships.where((c) => c.region == region.selectedRegion).toList();
        final ofSeason = inRegion.where((c) => c.season == region.selectedSeason).toList()
          ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
        final options = ofSeason.isNotEmpty ? ofSeason : [if (inRegion.isNotEmpty) inRegion.first];
        if (options.isEmpty) {
          return ArenaEmptyState(message: l10n.matchesNoChampionship, icon: Icons.emoji_events_outlined);
        }
        final ChampionshipDTO championship =
            options.where((c) => c.championshipId == _remembered[key]).firstOrNull ?? options.first;

        final championshipId = championship.championshipId;
        return Column(
          children: [
            if (options.length > 1)
              SizedBox(
                height: AppSizes.s56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, 0),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ArenaChoiceChip(
                      label: option.title,
                      icon: Icons.emoji_events_outlined,
                      selected: option.championshipId == championshipId,
                      onTap: () => setState(() => _remembered[key] = option.championshipId),
                    );
                  },
                ),
              ),
            Expanded(
              child: BlocProvider<MatchesCubit>(
                key: ValueKey(championshipId),
                create: (_) => MatchesCubit(sl(), sl(), sl(), sl(), sl())
                  ..watch(
                    championshipId: championshipId,
                    filter: MatchesFilter.today,
                    region: region.selectedRegion,
                    season: region.selectedSeason,
                  ),
                child: _DayMatches(
                  championshipId: championshipId,
                  region: region.selectedRegion,
                  season: region.selectedSeason,
                ),
              ),
            ),
          ],
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

/// Atalhos para outras telas do campeonato, em 3 blocos iguais (artilharia e
/// assistências são a mesma tela, com o seletor lá dentro).
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
        ShortcutTile(
          title: l10n.matchesAllGames,
          icon: Icons.calendar_month_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.matchesPage,
            arguments: {'championshipId': championshipId, 'region': region, 'season': season},
          ),
        ),
        ShortcutTile(
          title: l10n.matchesGroups,
          icon: Icons.groups_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.groupsPage,
            arguments: {'region': region, 'season': season, 'championshipId': championshipId},
          ),
        ),
        ShortcutTile(
          title: l10n.statsShortcut,
          icon: Icons.sports_soccer_rounded,
          onTap: () => _openStats(context, StatsRankingType.goals),
        ),
      ],
    );
  }
}
