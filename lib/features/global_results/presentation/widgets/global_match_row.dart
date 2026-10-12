import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/match_goals_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/widgets/match_status_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha de uma partida: status à esquerda, os dois times empilhados com o
/// placar à direita (vencedor em negrito, perdedor esmaecido). Tocar expande
/// a lista de autores: a do destaque vem junto; a dos demais encerrados é
/// buscada na página de análise ao abrir ([MatchGoalsCubit]).
class GlobalMatchRow extends StatefulWidget {
  final GlobalMatch match;

  const GlobalMatchRow({super.key, required this.match});

  @override
  State<GlobalMatchRow> createState() => _GlobalMatchRowState();
}

class _GlobalMatchRowState extends State<GlobalMatchRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final expandable = match.goals.isNotEmpty || match.canLoadGoals;
    // Só a linha deste jogo reconstrói quando os gols dele chegam.
    final loaded = match.canLoadGoals
        ? context.select<MatchGoalsCubit, MatchGoals?>((cubit) => cubit.state[match.detailsUrl])
        : null;

    void toggle() {
      // Aberto com falha: o toque tenta de novo em vez de fechar.
      if (_expanded && loaded?.status == GoalsStatus.failed) {
        BlocProvider.of<MatchGoalsCubit>(context).load(match);
        return;
      }
      setState(() => _expanded = !_expanded);
      if (_expanded && match.canLoadGoals) BlocProvider.of<MatchGoalsCubit>(context).load(match);
    }

    return InkWell(
      onTap: expandable ? toggle : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s10, AppSizes.s10, AppSizes.s10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: AppSizes.s72,
                  child: Align(alignment: Alignment.centerLeft, child: MatchStatusBadge(match: match)),
                ),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child: Column(
                    children: [
                      _TeamLine(
                        name: match.homeTeam,
                        goals: match.homeGoals,
                        won: match.homeWon,
                        lost: match.awayWon,
                        live: match.isLive,
                      ),
                      const SizedBox(height: AppSizes.s4),
                      _TeamLine(
                        name: match.awayTeam,
                        goals: match.awayGoals,
                        won: match.awayWon,
                        lost: match.homeWon,
                        live: match.isLive,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: AppSizes.s28,
                  child: expandable
                      ? AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
                        )
                      : null,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s10, left: AppSizes.s80, right: AppSizes.s28),
                      child: _Goals(goals: match.goals, loaded: loaded),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gols já conhecidos, ou o andamento da busca: carregando, falha (tocar a
/// linha tenta de novo) ou a lista carregada.
class _Goals extends StatelessWidget {
  final List<GoalEvent> goals;
  final MatchGoals? loaded;

  const _Goals({required this.goals, required this.loaded});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = goals.isNotEmpty ? goals : loaded?.goals ?? const <GoalEvent>[];

    if (goals.isEmpty && (loaded == null || loaded!.status == GoalsStatus.loading)) {
      return const Padding(
        padding: EdgeInsets.only(bottom: AppSizes.s4),
        child: SizedBox(
          width: AppSizes.s18,
          height: AppSizes.s18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }
    if (goals.isEmpty && loaded!.status == GoalsStatus.failed) {
      return Text(
        l10n.globalResultsGoalsError,
        textAlign: TextAlign.center,
        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
      );
    }
    return Column(children: [for (final goal in list) _GoalLine(goal: goal)]);
  }
}

class _TeamLine extends StatelessWidget {
  final String name;
  final int? goals;
  final bool won;
  final bool lost;
  final bool live;

  const _TeamLine({required this.name, required this.goals, required this.won, required this.lost, required this.live});

  @override
  Widget build(BuildContext context) {
    final color = lost ? AppColors.textSecondary : AppColors.textPrimary;
    final weight = won ? FontWeight.w800 : FontWeight.w500;

    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(color: color).copyWith(fontSize: AppSizes.s14, fontWeight: weight),
          ),
        ),
        if (goals != null)
          Text(
            '$goals',
            style: AppTypography.title(color: live ? AppColors.danger : color).copyWith(
              fontSize: AppSizes.s16,
              fontWeight: won || live ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

/// "⚽ 65' Erling Haaland": gols do mandante à esquerda, do visitante à direita.
class _GoalLine extends StatelessWidget {
  final GoalEvent goal;

  const _GoalLine({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final note = goal.isOwnGoal
        ? l10n.globalResultsOwnGoal
        : goal.isPenalty
            ? l10n.globalResultsPenalty
            : null;
    final text = note == null ? goal.scorer : '${goal.scorer} ($note)';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s4),
      child: Row(
        mainAxisAlignment: goal.isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          const Icon(Icons.sports_soccer_rounded, size: AppSizes.s14, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s4),
          Text("${goal.minute}'",
              style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12)),
          const SizedBox(width: AppSizes.s6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
            ),
          ),
        ],
      ),
    );
  }
}
