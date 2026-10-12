import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Sobre a competição: banner, regulamento (PDF + resumo), times
/// participantes, premiação e atalho para os grupos. O campeonato já vem
/// carregado da aba (stream); só os escudos dos times são buscados aqui.
class ChampionshipDetailsPage extends StatefulWidget {
  final ChampionshipDTO championship;

  const ChampionshipDetailsPage({super.key, required this.championship});

  @override
  State<ChampionshipDetailsPage> createState() => _ChampionshipDetailsPageState();
}

class _ChampionshipDetailsPageState extends State<ChampionshipDetailsPage> {
  ChampionshipDTO get _championship => widget.championship;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChampionshipDetailsCubit>(context).load(_championship);
  }

  void _openGroups() {
    // Como no app antigo: os grupos são os da temporada do campeonato (`ano`).
    final season = _championship.season.isNotEmpty ? _championship.season : SeasonCollection.currentSeason;
    Navigator.pushNamed(
      context,
      AppRoutes.groupsPage,
      arguments: {'region': _championship.region, 'season': season},
    );
  }

  Future<void> _openRules(AppLocalizations l10n) async {
    final uri = Uri.tryParse(_championship.rulesUrl);
    var opened = false;
    try {
      if (uri != null) opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.e('openRules', name: 'ChampionshipDetailsPage', error: e);
    }
    if (!opened && mounted) showSnackBar(context: context, message: l10n.championshipRulesOpenError, isSuccess: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final championship = _championship;
    final prizes = [
      (Icons.looks_one_rounded, l10n.championshipFormPrize1, championship.firstPrize),
      (Icons.looks_two_rounded, l10n.championshipFormPrize2, championship.secondPrize),
      (Icons.looks_3_rounded, l10n.championshipFormPrize3, championship.thirdPrize),
      (Icons.sports_soccer_rounded, l10n.championshipFormPrizeTopScorer, championship.topScorerPrize),
      (Icons.sports_handball_rounded, l10n.championshipFormPrizeGoalkeeper, championship.goalkeeperPrize),
    ].where((p) => p.$3.trim().isNotEmpty).toList();
    final hasRules = championship.rulesUrl.isNotEmpty || championship.rules.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.championshipsDetailsTitle),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSizes.s32),
        children: [
          if (championship.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: CachedNetworkImage(
                imageUrl: championship.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppColors.primarySoft),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(championship.title, style: AppTypography.title()),
                if (championship.region.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    l10n.championshipsSeasonLabel(championship.region, championship.season),
                    style: AppTypography.subtitle(),
                  ),
                ],
                if (championship.description.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s12),
                  Text(championship.description, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
                ],
              ],
            ),
          ),
          if (hasRules)
            _Section(
              title: l10n.championshipFormSectionRules,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (championship.rulesUrl.isNotEmpty)
                    Material(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
                        onTap: () => _openRules(l10n),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.s14),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: AppSizes.s32),
                              const SizedBox(width: AppSizes.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.championshipRulesOpen,
                                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    if (championship.rulesFileName.isNotEmpty)
                                      Text(
                                        championship.rulesFileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new_rounded, color: AppColors.primaryDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (championship.rules.trim().isNotEmpty) ...[
                    if (championship.rulesUrl.isNotEmpty) const SizedBox(height: AppSizes.s12),
                    Text(championship.rules, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
                  ],
                ],
              ),
            ),
          if (championship.teams.isNotEmpty)
            _Section(
              title: l10n.championshipFormSectionTeams,
              trailing: l10n.championshipsManageTeamsCount(championship.teams.length),
              child: BlocBuilder<ChampionshipDetailsCubit, List<TeamDTO>>(
                builder: (context, teams) => SizedBox(
                  height: AppSizes.s100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: teams.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
                    itemBuilder: (context, index) => _TeamChip(team: teams[index]),
                  ),
                ),
              ),
            ),
          if (prizes.isNotEmpty)
            _Section(
              title: l10n.championshipFormSectionPrizes,
              child: Column(
                children: [
                  for (final (icon, label, value) in prizes)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(icon, color: AppColors.primaryDark),
                      title: Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                      subtitle: Text(value, style: AppTypography.body().copyWith(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, 0),
            child: ArenaButton.primary(title: l10n.championshipsGroupsButton, function: _openGroups),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.label(color: AppColors.textPrimary))),
              if (trailing != null)
                Text(trailing!, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          child,
        ],
      ),
    );
  }
}

/// Escudo + nome; tocar abre o elenco (quando o time foi encontrado).
class _TeamChip extends StatelessWidget {
  final TeamDTO team;

  const _TeamChip({required this.team});

  @override
  Widget build(BuildContext context) {
    final found = team.id.isNotEmpty;
    return SizedBox(
      width: AppSizes.s80,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        onTap: found ? () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}) : null,
        child: Column(
          children: [
            TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s56),
            const SizedBox(height: AppSizes.s6),
            Text(
              team.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body().copyWith(fontSize: AppSizes.s12, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}
