import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_details_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_details_header.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_details_sections.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_goals_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Detalhes da partida: cabeçalho com as cores dos dois times, escudos e
/// placar (antes do jogo, o horário), depois os gols em linha do tempo, o
/// melhor da partida e os elencos. O admin edita o placar, lança o card de
/// gol e abre/fecha a votação pelo menu ⋮.
class MatchDetailsPage extends StatelessWidget {
  final String? season;
  final String? homeCrest;
  final String? awayCrest;
  final Color? homeColor;
  final Color? awayColor;

  /// Nome da competição (ou "Amistoso"); nulo = título genérico.
  final String? championshipLabel;

  const MatchDetailsPage({
    super.key,
    this.season,
    this.homeCrest,
    this.awayCrest,
    this.homeColor,
    this.awayColor,
    this.championshipLabel,
  });

  /// Cor do fundo do cabeçalho: sem cor ou cor clara (o texto é branco) cai
  /// no verde escuro do app.
  static Color headerColor(Color? color) =>
      color == null || isLightColor(color) ? AppColors.primaryDark : Color.lerp(color, AppColors.black, 0.2)!;

  void _openVoting(BuildContext context, MatchDetailsState state) {
    Navigator.pushNamed(
      context,
      state.match.isVotingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
      arguments: {'match': state.match, 'season': season},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;
    final cubit = BlocProvider.of<MatchDetailsCubit>(context);

    return BlocConsumer<MatchDetailsCubit, MatchDetailsState>(
      listenWhen: (a, b) => a.errorMessage != b.errorMessage && b.errorMessage != null,
      listener: (context, state) => showSnackBar(context: context, message: state.errorMessage!, isSuccess: false),
      builder: (context, state) {
        final match = state.match;
        final title = [
          championshipLabel ?? l10n.matchDetailsTitle,
          if (match.date.trim().isNotEmpty) match.date.trim(),
        ].join('  ·  ');
        final home = headerColor(homeColor);
        final away = headerColor(awayColor);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: AppSizes.matchHeaderHeight,
                backgroundColor: home,
                foregroundColor: AppColors.white,
                title: Row(
                  children: [
                    if (championshipLabel != null) ...[
                      const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s18),
                      const SizedBox(width: AppSizes.s6),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (isAdmin && !state.deleted)
                    CardMenuButton(
                      onImage: true,
                      actions: [
                        CardMenuAction(
                          icon: Icons.edit_outlined,
                          label: l10n.matchesEditScore,
                          onSelected: () => showMatchGoalsSheet(
                            context,
                            match: match,
                            season: season,
                            homeCrest: homeCrest,
                            awayCrest: awayCrest,
                          ),
                        ),
                        CardMenuAction(
                          icon: Icons.sports_soccer_rounded,
                          label: l10n.matchDetailsGoalCard,
                          onSelected: () => Navigator.pushNamed(
                            context,
                            AppRoutes.goalNotificationPage,
                            arguments: {'match': match, 'season': season},
                          ),
                        ),
                        CardMenuAction(
                          icon: match.isVotingOpen ? Icons.lock_outline_rounded : Icons.how_to_vote_outlined,
                          label: match.isVotingOpen ? l10n.matchesCloseVoting : l10n.matchesOpenVoting,
                          onSelected: cubit.toggleVoting,
                        ),
                      ],
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: MatchDetailsHeader(
                    match: match,
                    homeCrest: homeCrest,
                    awayCrest: awayCrest,
                    homeColor: home,
                    awayColor: away,
                  ),
                ),
              ),
              if (state.deleted)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ArenaEmptyState(message: l10n.matchDetailsDeleted, icon: Icons.event_busy_outlined),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
                  sliver: SliverList.list(
                    children: [
                      MatchGoalsTimeline(match: match),
                      MatchBestPlayerCard(
                        match: match,
                        player: state.bestPlayer,
                        onTap: () => _openVoting(context, state),
                      ),
                      MatchSquadsCard(
                        match: match,
                        selectedSide: state.selectedSide,
                        lines: state.selectedLines,
                        loading: state.squadsLoading,
                        homeCrest: homeCrest,
                        awayCrest: awayCrest,
                        onSideChanged: cubit.selectSide,
                        onPlayerTap: (player) => Navigator.pushNamed(
                          context,
                          AppRoutes.playerProfilePage,
                          arguments: {'playerId': player.id, 'season': season, 'name': player.name, 'player': player},
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
