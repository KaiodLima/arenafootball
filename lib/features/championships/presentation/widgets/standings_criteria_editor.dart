import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/domain/standings_criterion.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

String standingsCriterionLabel(AppLocalizations l10n, StandingsCriterion criterion) => switch (criterion) {
      StandingsCriterion.wins => l10n.standingsCriterionWins,
      StandingsCriterion.goalDifference => l10n.standingsCriterionGoalDifference,
      StandingsCriterion.goalsFor => l10n.standingsCriterionGoalsFor,
      StandingsCriterion.headToHead => l10n.standingsCriterionHeadToHead,
      StandingsCriterion.fewestGoalsAgainst => l10n.standingsCriterionFewestGoalsAgainst,
    };

/// "Desempate" do cadastro do campeonato: os critérios depois dos pontos, os
/// ligados em cima na ordem escolhida (arrastar reordena) e os desligados
/// embaixo. Nenhum escolhido = o padrão.
class StandingsCriteriaEditor extends StatelessWidget {
  final List<StandingsCriterion> chosen;
  final ValueChanged<List<StandingsCriterion>> onChanged;

  const StandingsCriteriaEditor({super.key, required this.chosen, required this.onChanged});

  /// Ordem exibida: os que valem e, depois, os outros na ordem do enum.
  static List<StandingsCriterion> displayOrder(List<StandingsCriterion> chosen) {
    final active = StandingsCriterion.effective(chosen);
    return [...active, ...StandingsCriterion.values.where((c) => !active.contains(c))];
  }

  /// Arrastou o item de [oldIndex] para [newIndex] (índices do [displayOrder]).
  static List<StandingsCriterion> reorder(List<StandingsCriterion> chosen, int oldIndex, int newIndex) {
    final active = StandingsCriterion.effective(chosen);
    final display = displayOrder(chosen);
    final item = display.removeAt(oldIndex);
    display.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    return display.where(active.contains).toList();
  }

  /// Liga/desliga o critério, mantendo a posição dele na lista.
  static List<StandingsCriterion> toggle(List<StandingsCriterion> chosen, StandingsCriterion criterion) {
    final active = {...StandingsCriterion.effective(chosen)};
    if (!active.remove(criterion)) active.add(criterion);
    return displayOrder(chosen).where(active.contains).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = StandingsCriterion.effective(chosen);
    final display = displayOrder(chosen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.championshipTiebreakHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        const SizedBox(height: AppSizes.s8),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) => onChanged(reorder(chosen, oldIndex, newIndex)),
          children: [
            for (var i = 0; i < display.length; i++)
              Material(
                key: ValueKey(display[i]),
                color: AppColors.transparent,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: active.contains(display[i]),
                    activeColor: AppColors.primary,
                    onChanged: (_) => onChanged(toggle(chosen, display[i])),
                  ),
                  title: Text(
                    active.contains(display[i])
                        ? '${active.indexOf(display[i]) + 1}º  ${standingsCriterionLabel(l10n, display[i])}'
                        : standingsCriterionLabel(l10n, display[i]),
                    style: AppTypography.body(
                      color: active.contains(display[i]) ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        if (chosen.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onChanged(const []),
              icon: const Icon(Icons.restart_alt_rounded, size: AppSizes.s18),
              label: Text(l10n.championshipTiebreakReset),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
            ),
          ),
      ],
    );
  }
}
