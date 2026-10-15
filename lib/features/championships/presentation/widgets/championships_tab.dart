import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_hero_card.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_list_row.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_rules_launcher.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/shortcut_tile.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Aba de campeonatos da home: os campeonatos da temporada num carrossel de
/// destaque (com atalhos para grupos, artilharia e regulamento do que está na
/// tela) e os anteriores da região numa lista compacta. A home recria a aba (key) quando a região muda.
class ChampionshipsTab extends StatelessWidget {
  const ChampionshipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    return BlocProvider<ChampionshipsCubit>(
      create: (_) => ChampionshipsCubit(sl())..watch(region: region),
      child: const _ChampionshipsList(),
    );
  }
}

class _ChampionshipsList extends StatefulWidget {
  const _ChampionshipsList();

  @override
  State<_ChampionshipsList> createState() => _ChampionshipsListState();
}

class _ChampionshipsListState extends State<_ChampionshipsList> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDetails(ChampionshipDTO championship) => Navigator.pushNamed(
        context,
        AppRoutes.championshipDetailsPage,
        arguments: {'championship': championship},
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedSeason = BlocProvider.of<RegionCubit>(context).state.selectedSeason;

    return BlocBuilder<ChampionshipsCubit, ChampionshipsState>(
      builder: (context, state) {
        if (state is LoadingChampionshipsState && state.championships.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorChampionshipsState && state.championships.isEmpty) {
          return ArenaEmptyState.error(message: l10n.championshipsLoadError);
        }
        if (state.championships.isEmpty) {
          return ArenaEmptyState(message: l10n.championshipsEmpty, icon: Icons.emoji_events_outlined);
        }

        // Destaque: todos os da temporada escolhida (podem ser vários ao mesmo
        // tempo), num carrossel; sem nenhum, o mais recente. O resto em "Anteriores".
        final sorted = [...state.championships]..sort((a, b) => b.season.compareTo(a.season));
        final ofSeason = sorted.where((c) => c.season == selectedSeason).toList()
          ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
        final featured = ofSeason.isNotEmpty ? ofSeason : [sorted.first];
        final featuredIds = featured.map((c) => c.id).toSet();
        final previous = sorted.where((c) => !featuredIds.contains(c.id)).toList();
        final current = featured[_page.clamp(0, featured.length - 1)];

        return ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                // Mesma proporção do card (4:3).
                height: constraints.maxWidth * 3 / 4,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: featured.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: featured.length > 1 ? AppSizes.s4 : 0),
                    child: ChampionshipHeroCard(
                      championship: featured[index],
                      onTap: () => _openDetails(featured[index]),
                    ),
                  ),
                ),
              ),
            ),
            if (featured.length > 1) ...[
              const SizedBox(height: AppSizes.s10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < featured.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                      width: i == _page ? AppSizes.s20 : AppSizes.s8,
                      height: AppSizes.s8,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(AppSizes.s4),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSizes.s16),
            _Shortcuts(championship: current),
            if (previous.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s20),
              SectionHeader(title: l10n.championshipsPrevious),
              for (final championship in previous)
                ChampionshipListRow(championship: championship, onTap: () => _openDetails(championship)),
            ],
          ],
        );
      },
    );
  }
}

/// Grupos, artilharia e (se houver) o regulamento do campeonato em destaque.
class _Shortcuts extends StatelessWidget {
  final ChampionshipDTO championship;

  const _Shortcuts({required this.championship});

  String get _season => championship.season.isNotEmpty ? championship.season : SeasonCollection.currentSeason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShortcutTile(
          title: l10n.matchesGroups,
          icon: Icons.groups_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.groupsPage,
            arguments: {
              'region': championship.region,
              'season': _season,
              'championshipId': championship.championshipId
            },
          ),
        ),
        ShortcutTile(
          title: l10n.statsShortcut,
          icon: Icons.sports_soccer_rounded,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.statsRankingPage,
            arguments: {'type': StatsRankingType.goals, 'region': championship.region, 'season': _season},
          ),
        ),
        if (championship.rulesUrl.isNotEmpty)
          ShortcutTile(
            title: l10n.championshipTabRules,
            icon: Icons.picture_as_pdf_rounded,
            onTap: () => openChampionshipRules(context, championship),
          ),
      ],
    );
  }
}
