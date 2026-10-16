import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/edit_score_dialog.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_summary_card.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/team_filter_chips.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Lista de partidas do [MatchesCubit] do contexto (usada pela aba de
/// tabelas, com as partidas do dia, e pela tela "todos os jogos"). Com
/// [groupByDate] ("todos os jogos"), mostra o resumo, o filtro por time e as
/// partidas agrupadas por data.
class MatchesList extends StatelessWidget {
  /// Temporada da lista: as telas de votação leem os jogadores dela.
  final String season;

  /// Conteúdo antes dos cards (ex.: atalhos e título da seção na aba de tabelas).
  final Widget? header;

  final bool groupByDate;

  /// Mensagem quando não há partidas no recorte (padrão: "Nenhuma partida cadastrada").
  final String? emptyMessage;

  const MatchesList({super.key, required this.season, this.header, this.groupByDate = false, this.emptyMessage});

  void _openVoting(BuildContext context, MatchDTO match) {
    Navigator.pushNamed(
      context,
      match.isVotingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
      arguments: {'match': match, 'season': season},
    );
  }

  Future<void> _editScore(BuildContext context, MatchDTO match) async {
    final cubit = BlocProvider.of<MatchesCubit>(context);
    final score = await showEditScoreDialog(context);
    if (score != null) await cubit.updateScore(match, homeGoals: score.homeGoals, awayGoals: score.awayGoals);
  }

  Future<void> _confirmDelete(BuildContext context, MatchDTO match) async {
    final cubit = BlocProvider.of<MatchesCubit>(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.matchesDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await cubit.delete(match);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<SessionCubit>().state;
    final isAdmin = session.isAdmin;
    final user = session.user;
    // Chips de time (só o nome); a partida usa os ids quando tem.
    bool isFavoriteTeam(String team) => user?.isFavorite(name: team) ?? false;
    bool isFavoriteMatch(MatchDTO match) =>
        user != null &&
        (user.isFavorite(id: match.homeTeamId, name: match.homeTeam) ||
            user.isFavorite(id: match.awayTeamId, name: match.awayTeam));

    return BlocConsumer<MatchesCubit, MatchesState>(
      listener: (context, state) {
        // Com a lista vazia o erro já aparece na tela; aqui só o de ação.
        if (state is ErrorMatchesState && state.matches.isNotEmpty) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final Widget? placeholder;
        if (state is LoadingMatchesState && state.matches.isEmpty) {
          placeholder = const Padding(
            padding: EdgeInsets.only(top: AppSizes.s48),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ErrorMatchesState && state.matches.isEmpty) {
          placeholder = ArenaEmptyState.error(message: l10n.matchesLoadError);
        } else if (state.matches.isEmpty) {
          placeholder = ArenaEmptyState(message: emptyMessage ?? l10n.matchesEmpty, icon: Icons.sports_soccer_outlined);
        } else if (state.visibleMatches.isEmpty) {
          placeholder = ArenaEmptyState(message: l10n.matchesEmptyForTeam, icon: Icons.filter_alt_off_outlined);
        } else {
          placeholder = null;
        }

        Widget card(MatchDTO match) => MatchCard(
              match: match,
              isAdmin: isAdmin,
              homeCrest: state.crestOf(match.homeTeam),
              awayCrest: state.crestOf(match.awayTeam),
              isFavorite: isFavoriteMatch(match),
              isFavoriteTeam: isFavoriteTeam,
              onVotingTap: () => _openVoting(context, match),
              onToggleVoting: () => BlocProvider.of<MatchesCubit>(context).toggleVoting(match),
              onEditScore: () => _editScore(context, match),
              onDelete: () => _confirmDelete(context, match),
              // Admin: lança um card de gol desta partida (e atualiza o placar dela).
              onTap: isAdmin
                  ? () => Navigator.pushNamed(
                        context,
                        AppRoutes.goalNotificationPage,
                        arguments: {'match': match, 'season': season},
                      )
                  : null,
            );

        final teams = state.teams;
        return ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          children: [
            if (header != null) header!,
            if (groupByDate && state.matches.isNotEmpty) ...[
              MatchesSummaryCard(summary: state.summary),
              const SizedBox(height: AppSizes.s14),
              TeamFilterChips(
                teams: teams,
                selected: state.teamFilter,
                favoriteTeam: teams.where(isFavoriteTeam).firstOrNull,
                crestOf: state.crestOf,
                onSelected: BlocProvider.of<MatchesCubit>(context).setTeamFilter,
              ),
              const SizedBox(height: AppSizes.s6),
            ],
            if (placeholder != null)
              placeholder
            else if (groupByDate)
              for (final day in state.days) ...[
                _DayHeader(
                  title: day.date.isEmpty ? l10n.matchesNoDate : day.date,
                  count: l10n.matchesDayCount(day.matches.length),
                ),
                for (final match in day.matches) card(match),
              ]
            else
              for (final match in state.visibleMatches) card(match),
          ],
        );
      },
    );
  }
}

/// "08/06  ·  2 jogos" acima das partidas do dia.
class _DayHeader extends StatelessWidget {
  final String title;
  final String count;

  const _DayHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s14, AppSizes.s4, AppSizes.s10),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: AppSizes.s18, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s8),
          Text(title, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
          const SizedBox(width: AppSizes.s8),
          Text(count, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          const SizedBox(width: AppSizes.s12),
          const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.greyLight)),
        ],
      ),
    );
  }
}
