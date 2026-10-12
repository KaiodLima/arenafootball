import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Um lado do placar: escudo e nome tocáveis (trocar o time) e o stepper.
class GoalSide {
  final String label;
  final String? team;
  final String? crest;
  final int goals;
  final VoidCallback onPickTeam;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const GoalSide({
    required this.label,
    required this.team,
    required this.crest,
    required this.goals,
    required this.onPickTeam,
    required this.onIncrement,
    required this.onDecrement,
  });
}

/// Placar do card de gol: mandante × visitante, cada um com − / +.
class GoalScoreboard extends StatelessWidget {
  final GoalSide home;
  final GoalSide away;
  final int maxGoals;

  /// Erro mostrado abaixo do placar (ex.: mesmo time dos dois lados).
  final String? errorText;

  const GoalScoreboard({super.key, required this.home, required this.away, required this.maxGoals, this.errorText});

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s20, AppSizes.s12, AppSizes.s16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Side(side: home, maxGoals: maxGoals)),
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.s20),
                child: Text('×', style: AppTypography.display(color: AppColors.textSecondary)),
              ),
              Expanded(child: _Side(side: away, maxGoals: maxGoals)),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: AppSizes.s12),
            Text(errorText!, style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
          ],
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final GoalSide side;
  final int maxGoals;

  const _Side({required this.side, required this.maxGoals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          side.label.toUpperCase(),
          style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
        ),
        const SizedBox(height: AppSizes.s8),
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.s14),
          onTap: side.onPickTeam,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s6),
            child: Column(
              children: [
                TeamCrest(imageUrl: side.crest, size: AppSizes.s64),
                const SizedBox(height: AppSizes.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        side.team ?? l10n.goalPickTeam,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: side.team == null ? AppColors.primary : AppColors.textPrimary)
                            .copyWith(fontSize: AppSizes.s14),
                      ),
                    ),
                    const Icon(Icons.expand_more_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              tooltip: l10n.goalDecrease,
              onTap: side.goals > 0 ? side.onDecrement : null,
            ),
            SizedBox(
              width: AppSizes.s48,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${side.goals}',
                  key: ValueKey(side.goals),
                  textAlign: TextAlign.center,
                  style: AppTypography.display().copyWith(fontSize: AppSizes.s36, height: 1.0),
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              tooltip: l10n.goalIncrease,
              onTap: side.goals < maxGoals ? side.onIncrement : null,
              filled: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  const _StepButton({required this.icon, required this.tooltip, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background = filled ? AppColors.primary : AppColors.primarySoft;
    final foreground = filled ? AppColors.white : AppColors.primaryDark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? background : AppColors.greyLight,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: AppSizes.s40,
            height: AppSizes.s40,
            child: Icon(icon, color: enabled ? foreground : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
