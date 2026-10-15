import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_hero_card.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_rules_launcher.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/prize_podium.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Detalhe do campeonato: hero escuro (banner, temporada, título e chips) que
/// recolhe ao rolar, e abas Visão geral · Times · Regulamento. O campeonato já
/// vem carregado da aba; só os times (escudos) são buscados aqui.
class ChampionshipDetailsPage extends StatefulWidget {
  final ChampionshipDTO championship;

  const ChampionshipDetailsPage({super.key, required this.championship});

  @override
  State<ChampionshipDetailsPage> createState() => _ChampionshipDetailsPageState();
}

class _ChampionshipDetailsPageState extends State<ChampionshipDetailsPage> {
  static const double _heroHeight = 300;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChampionshipDetailsCubit>(context).load(widget.championship);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final championship = widget.championship;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: _heroHeight,
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              // O título só aparece na barra quando o hero recolhe.
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  championship.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _Hero(championship: championship),
              ),
              bottom: TabBar(
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.whiteSoft,
                dividerColor: AppColors.transparent,
                labelStyle: AppTypography.label().copyWith(fontSize: AppSizes.s14),
                tabs: [
                  Tab(text: l10n.championshipTabOverview),
                  Tab(text: l10n.championshipTabTeams),
                  Tab(text: l10n.championshipTabRules),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(championship: championship),
              _TeamsTab(championship: championship),
              _RulesTab(championship: championship),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final ChampionshipDTO championship;

  const _Hero({required this.championship});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ChampionshipHeroBackdrop(imageUrl: championship.imageUrl),
        Positioned(
          left: AppSizes.s16,
          right: AppSizes.s16,
          // Acima da TabBar.
          bottom: kTextTabBarHeight + AppSizes.s16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ChampionshipSeasonBadge(season: championship.season),
              const SizedBox(height: AppSizes.s8),
              Text(
                championship.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
              ),
              const SizedBox(height: AppSizes.s10),
              Wrap(spacing: AppSizes.s6, runSpacing: AppSizes.s6, children: championshipInfoChips(l10n, championship)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cartão branco com borda leve, base das seções das abas.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(AppSizes.s16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s20, AppSizes.s4, AppSizes.s10),
      child: Text(text, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ChampionshipDTO championship;

  const _OverviewTab({required this.championship});

  String get _season => championship.season.isNotEmpty ? championship.season : SeasonCollection.currentSeason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = championship;
    final hasPodium = [c.firstPrize, c.secondPrize, c.thirdPrize].any((p) => p.trim().isNotEmpty);
    final individual = [
      (Icons.sports_soccer_rounded, l10n.championshipFormPrizeTopScorer, c.topScorerPrize),
      (Icons.sports_handball_rounded, l10n.championshipFormPrizeGoalkeeper, c.goalkeeperPrize),
    ].where((p) => p.$3.trim().isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
      children: [
        if (hasPodium || individual.isNotEmpty) ...[
          _SectionTitle(l10n.championshipFormSectionPrizes),
          if (hasPodium)
            _Card(
              padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s16, AppSizes.s12, 0),
              child: PrizePodium(
                first: c.firstPrize,
                second: c.secondPrize,
                third: c.thirdPrize,
                labels: [l10n.championshipFormPrize1, l10n.championshipFormPrize2, l10n.championshipFormPrize3],
              ),
            ),
          if (individual.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < individual.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizes.s10),
                  Expanded(
                    child: _Card(
                      padding: const EdgeInsets.all(AppSizes.s12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.s8),
                            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                            child: Icon(individual[i].$1, color: AppColors.primaryDark, size: AppSizes.s18),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  individual[i].$2,
                                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                ),
                                Text(
                                  individual[i].$3,
                                  style: AppTypography.body().copyWith(
                                    fontSize: AppSizes.s14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
        if (c.description.trim().isNotEmpty) ...[
          _SectionTitle(l10n.championshipAbout),
          _Card(child: Text(c.description, style: AppTypography.body().copyWith(fontSize: AppSizes.s14, height: 1.4))),
        ],
        const SizedBox(height: AppSizes.s20),
        _ActionCard(
          icon: Icons.table_chart_rounded,
          title: l10n.championshipGroupsAndStandings,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.groupsPage,
            arguments: {'region': c.region, 'season': _season, 'championshipId': c.championshipId},
          ),
        ),
        const SizedBox(height: AppSizes.s10),
        _ActionCard(
          icon: Icons.sports_soccer_rounded,
          title: l10n.statsShortcut,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.statsRankingPage,
            arguments: {'type': StatsRankingType.goals, 'region': c.region, 'season': _season},
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s14),
          child: Row(
            children: [
              Container(
                width: AppSizes.s40,
                height: AppSizes.s40,
                decoration:
                    BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s12)),
                child: Icon(icon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Text(title, style: AppTypography.body().copyWith(fontWeight: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamsTab extends StatelessWidget {
  final ChampionshipDTO championship;

  const _TeamsTab({required this.championship});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (championship.teams.isEmpty) {
      return ArenaEmptyState(message: l10n.championshipTeamsEmpty, icon: Icons.shield_outlined);
    }
    return BlocBuilder<ChampionshipDetailsCubit, List<TeamDTO>>(
      builder: (context, teams) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSizes.s10,
          crossAxisSpacing: AppSizes.s10,
          childAspectRatio: 0.85,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) => _TeamCard(team: teams[index]),
      ),
    );
  }
}

/// Escudo + nome; tocar abre o elenco (quando o time foi encontrado).
class _TeamCard extends StatelessWidget {
  final TeamDTO team;

  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final found = team.id.isNotEmpty;
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        borderRadius: radius,
        onTap: found ? () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s56),
              const SizedBox(height: AppSizes.s8),
              Text(
                team.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body().copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w600, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesTab extends StatelessWidget {
  final ChampionshipDTO championship;

  const _RulesTab({required this.championship});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPdf = championship.rulesUrl.isNotEmpty;
    final summary = championship.rules.trim();
    if (!hasPdf && summary.isEmpty) {
      return ArenaEmptyState(message: l10n.championshipRulesEmpty, icon: Icons.description_outlined);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
      children: [
        if (hasPdf)
          _Card(
            padding: const EdgeInsets.all(AppSizes.s20),
            child: Column(
              children: [
                Container(
                  width: AppSizes.s64,
                  height: AppSizes.s64,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.s20),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: AppSizes.s36),
                ),
                const SizedBox(height: AppSizes.s12),
                Text(l10n.championshipTabRules, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                if (championship.rulesFileName.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    championship.rulesFileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
                const SizedBox(height: AppSizes.s16),
                ArenaButton.primary(
                  title: l10n.championshipRulesOpen,
                  function: () => openChampionshipRules(context, championship),
                ),
              ],
            ),
          ),
        if (summary.isNotEmpty) ...[
          if (hasPdf) const SizedBox(height: AppSizes.s12),
          _Card(child: Text(summary, style: AppTypography.body().copyWith(fontSize: AppSizes.s14, height: 1.45))),
        ],
      ],
    );
  }
}
