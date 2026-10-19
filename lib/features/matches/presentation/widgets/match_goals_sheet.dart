import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_goals_cubit.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_scorer_sheet.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Editar placar": abre os gols da partida (autor e assistência de cada um).
/// Devolve true se salvou.
Future<bool> showMatchGoalsSheet(
  BuildContext context, {
  required MatchDTO match,
  String? season,
  String? homeCrest,
  String? awayCrest,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<MatchGoalsCubit>(
      create: (_) => MatchGoalsCubit(sl<WatchTeamPlayersUseCase>(), sl<UpdateMatchGoalsUseCase>())
        ..load(match: match, season: season),
      child: _MatchGoalsSheet(homeCrest: homeCrest, awayCrest: awayCrest),
    ),
  );
  return saved ?? false;
}

class _MatchGoalsSheet extends StatelessWidget {
  final String? homeCrest;
  final String? awayCrest;

  const _MatchGoalsSheet({required this.homeCrest, required this.awayCrest});

  Future<void> _addGoal(BuildContext context, MatchGoalsState state, MatchSide side) async {
    final cubit = BlocProvider.of<MatchGoalsCubit>(context);
    final match = state.match!;
    final squad = state.squadOf(side);
    // Sem elenco cadastrado: o gol entra sem autor.
    if (squad.isEmpty) return cubit.addGoal(side);
    final result = await showGoalScorerSheet(
      context,
      team: side == MatchSide.home ? match.homeTeam : match.awayTeam,
      crest: side == MatchSide.home ? homeCrest : awayCrest,
      squad: squad,
    );
    if (result == null) return;
    cubit.addGoal(side, scorer: result.scorer, assistant: result.assistant);
  }

  Future<void> _editGoal(BuildContext context, MatchGoalsState state, MatchGoal goal) async {
    final cubit = BlocProvider.of<MatchGoalsCubit>(context);
    final match = state.match!;
    final squad = state.squadOf(goal.side);
    if (squad.isEmpty) return;
    PlayerDTO? find(String id) => squad.where((p) => p.id == id).firstOrNull;
    final result = await showGoalScorerSheet(
      context,
      team: goal.side == MatchSide.home ? match.homeTeam : match.awayTeam,
      crest: goal.side == MatchSide.home ? homeCrest : awayCrest,
      squad: squad,
      initialScorer: find(goal.scorerId),
      initialAssistant: find(goal.assistantId),
    );
    if (result == null) return;
    cubit.updateGoal(goal.id, scorer: result.scorer, assistant: result.assistant);
  }

  Future<void> _close(BuildContext context, MatchGoalsState state) async {
    if (!state.dirty) {
      Navigator.pop(context, false);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showArenaConfirm(
      context,
      title: l10n.matchGoalsDiscardTitle,
      confirmLabel: l10n.matchGoalsDiscard,
      icon: Icons.delete_sweep_outlined,
      tone: ArenaAlertTone.danger,
    );
    if (discard && context.mounted) Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<MatchGoalsCubit, MatchGoalsState>(
      listener: (context, state) {
        if (state.saved) {
          showSnackBar(context: context, message: l10n.matchGoalsSaved);
          Navigator.pop(context, true);
        } else if (state.errorMessage != null) {
          showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
        }
      },
      builder: (context, state) {
        final match = state.match;
        if (match == null) return const SizedBox(height: AppSizes.s120);
        return PopScope(
          canPop: !state.dirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _close(context, state);
          },
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            Text(l10n.matchGoalsTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                      ),
                      IconButton(
                        tooltip: l10n.drawerClose,
                        onPressed: () => _close(context, state),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                _Scoreboard(match: match, state: state, homeCrest: homeCrest, awayCrest: awayCrest),
                const SizedBox(height: AppSizes.s8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s16),
                    children: [
                      for (final side in MatchSide.values) ...[
                        _SideHeader(
                          team: side == MatchSide.home ? match.homeTeam : match.awayTeam,
                          crest: side == MatchSide.home ? homeCrest : awayCrest,
                          onAdd: () => _addGoal(context, state, side),
                        ),
                        if (state.goalsOf(side).isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
                            child: Text(l10n.matchGoalsNone, style: AppTypography.subtitle()),
                          ),
                        for (final goal in state.goalsOf(side))
                          _GoalTile(
                            goal: goal,
                            onTap: () => _editGoal(context, state, goal),
                            onRemove: () => BlocProvider.of<MatchGoalsCubit>(context).removeGoal(goal.id),
                          ),
                        const SizedBox(height: AppSizes.s16),
                      ],
                    ],
                  ),
                ),
                ArenaSubmitBar(
                  title: l10n.matchGoalsSave,
                  loading: state.saving,
                  onPressed: BlocProvider.of<MatchGoalsCubit>(context).save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Escudos e o placar contado da lista em edição.
class _Scoreboard extends StatelessWidget {
  final MatchDTO match;
  final MatchGoalsState state;
  final String? homeCrest;
  final String? awayCrest;

  const _Scoreboard({required this.match, required this.state, required this.homeCrest, required this.awayCrest});

  @override
  Widget build(BuildContext context) {
    Widget side(String team, String? crest) => Expanded(
          child: Column(
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s44),
              const SizedBox(height: AppSizes.s4),
              Text(
                team,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
      child: Row(
        children: [
          side(match.homeTeam, homeCrest),
          Text(
            '${state.homeGoals}  ×  ${state.awayGoals}',
            style: AppTypography.display().copyWith(fontSize: AppSizes.s28),
          ),
          side(match.awayTeam, awayCrest),
        ],
      ),
    );
  }
}

class _SideHeader extends StatelessWidget {
  final String team;
  final String? crest;
  final VoidCallback onAdd;

  const _SideHeader({required this.team, required this.crest, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        TeamCrest(imageUrl: crest, size: AppSizes.s28),
        const SizedBox(width: AppSizes.s8),
        Expanded(
          child: Text(
            team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.textPrimary),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: AppSizes.s18),
          label: Text(l10n.matchGoalsAdd),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  final MatchGoal goal;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _GoalTile({required this.goal, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: AppSizes.s4),
      dense: true,
      leading: const Icon(Icons.sports_soccer_rounded, color: AppColors.primaryDark),
      title: Text(
        goal.hasScorer ? goal.scorerName : l10n.matchGoalsNoScorer,
        style: AppTypography.label(color: goal.hasScorer ? AppColors.textPrimary : AppColors.textSecondary),
      ),
      subtitle: goal.hasAssistant
          ? Text(l10n.matchGoalsAssist(goal.assistantName),
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))
          : null,
      onTap: onTap,
      trailing: IconButton(
        tooltip: l10n.matchGoalsRemove,
        onPressed: onRemove,
        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
    );
  }
}
