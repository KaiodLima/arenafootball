import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_criteria_editor.dart';
import 'package:arena_soccer/features/championships/domain/standings_criterion.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_hero.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_table.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcuts_bar.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Classificação de um grupo: destaque com o líder e os números do grupo, a
/// tabela (os dois primeiros, classificados, ganham o verde) e a legenda.
class StandingsPage extends StatefulWidget {
  final String region;
  final String season;
  final String group;

  /// Id do grupo (`grupos{ano}`): a tabela calculada fica em `tabelas{ano}/{id}`.
  final String groupId;

  const StandingsPage({
    super.key,
    required this.region,
    required this.season,
    required this.group,
    this.groupId = '',
  });

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  /// Quantos times por grupo se classificam.
  static const int _qualifiedCount = 2;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StandingsCubit>(context)
        .watch(region: widget.region, group: widget.group, season: widget.season, groupId: widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PageTitleBar(
        title: l10n.championshipsGroupTitle(widget.group),
        subtitle: l10n.groupsSubtitle(widget.region, widget.season),
      ),
      bottomNavigationBar: StatsShortcutsBar(region: widget.region, season: widget.season),
      body: BlocBuilder<StandingsCubit, StandingsState>(
        builder: (context, state) {
          if (state is LoadingStandingsState && state.standings.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorStandingsState && state.standings.isEmpty) {
            return ArenaEmptyState.error(message: l10n.championshipsStandingsLoadError);
          }
          if (state.standings.isEmpty) {
            return ArenaEmptyState(message: l10n.championshipsStandingsEmpty, icon: Icons.leaderboard_outlined);
          }

          return StandingsBody(
            group: widget.group,
            standings: state.standings,
            qualifiedCount: _qualifiedCount,
            isFavorite: (s) => user?.isFavorite(id: s.teamId, name: s.teamName) ?? false,
            automaticLegend: state.automatic
                ? l10n.standingsAutomaticLegend(StandingsCriterion.effective(state.criteria)
                    .map((c) => standingsCriterionLabel(l10n, c))
                    .join(', '))
                : null,
          );
        },
      ),
    );
  }
}

/// Corpo da classificação: o destaque do grupo (líder e números), a tabela e
/// o cartão de legenda (zona de classificação e, se automática, o desempate).
class StandingsBody extends StatelessWidget {
  final String group;
  final List<StandingDTO> standings;
  final int qualifiedCount;
  final bool Function(StandingDTO standing) isFavorite;

  /// Texto da tabela automática (atualização e desempate); nulo = manual.
  final String? automaticLegend;

  const StandingsBody({
    super.key,
    required this.group,
    required this.standings,
    required this.qualifiedCount,
    required this.isFavorite,
    this.automaticLegend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final legend = automaticLegend;
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s16, AppSizes.s12, AppSizes.s24),
      children: [
        StandingsHero(
          group: group,
          standings: standings,
          leaderIsFavorite: standings.isNotEmpty && isFavorite(standings.first),
        ),
        const SizedBox(height: AppSizes.s14),
        StandingsTable(standings: standings, qualifiedCount: qualifiedCount, isFavorite: isFavorite),
        const SizedBox(height: AppSizes.s14),
        Container(
          padding: const EdgeInsets.all(AppSizes.s12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.s14),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.s14,
                    height: AppSizes.s14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.s4),
                    ),
                  ),
                  const SizedBox(width: AppSizes.s8),
                  Expanded(
                    child: Text(
                      l10n.standingsQualifiedLegend,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ],
              ),
              if (legend != null) ...[
                const SizedBox(height: AppSizes.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.autorenew_rounded, size: AppSizes.s14, color: AppColors.primaryStrong),
                    const SizedBox(width: AppSizes.s8),
                    Expanded(
                      child: Text(legend, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
