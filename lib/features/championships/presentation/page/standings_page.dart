import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_table.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcuts_bar.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Classificação de um grupo, em tabela. Os dois primeiros (classificados)
/// ganham o filete verde, explicado pela legenda abaixo da tabela.
class StandingsPage extends StatefulWidget {
  final String region;
  final String season;
  final String group;

  const StandingsPage({super.key, required this.region, required this.season, required this.group});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  /// Quantos times por grupo se classificam.
  static const int _qualifiedCount = 2;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StandingsCubit>(context).watch(region: widget.region, group: widget.group, season: widget.season);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorite = context.watch<SessionCubit>().state.user?.favoriteTeam;
    final favoriteKey = (favorite == null || favorite.trim().isEmpty) ? null : normalizeTeamName(favorite);

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

          return ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s20, AppSizes.s12, AppSizes.s24),
            children: [
              StandingsTable(standings: state.standings, qualifiedCount: _qualifiedCount, favoriteTeam: favoriteKey),
              const SizedBox(height: AppSizes.s14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                child: Row(
                  children: [
                    Container(
                      width: AppSizes.s4,
                      height: AppSizes.s16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.s2),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Expanded(
                      child: Text(
                        l10n.standingsQualifiedLegend,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
