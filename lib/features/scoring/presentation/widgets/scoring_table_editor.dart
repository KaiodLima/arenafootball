import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_rules.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Editor da tabela de pontos do Arena Fantasy (painel "Pontuações" e a
/// tabela própria do campeonato): os lances e, por posição, gols sofridos,
/// sem sofrer gols e gol da equipe, com −/+ de 0,5 em 0,5 (−20 a 20).
class ScoringTableEditor extends StatelessWidget {
  final FantasyScoringTable table;
  final ValueChanged<FantasyScoringTable> onChanged;
  final bool enabled;

  /// Prefixo das chaves (testes).
  final String keyPrefix;

  const ScoringTableEditor({
    super.key,
    required this.table,
    required this.onChanged,
    this.enabled = true,
    this.keyPrefix = 'scoring',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decimal = Localizations.localeOf(context).languageCode == 'pt' ? ',' : '.';
    String label(FantasyScoreRule rule) => switch (rule) {
          FantasyScoreRule.base => l10n.fantasyRuleBase,
          FantasyScoreRule.goal => l10n.fantasyRuleGoal,
          FantasyScoreRule.assist => l10n.fantasyRuleAssist,
          FantasyScoreRule.win => l10n.fantasyRuleWin,
          FantasyScoreRule.draw => l10n.fantasyRuleDraw,
          FantasyScoreRule.loss => l10n.fantasyRuleLoss,
          FantasyScoreRule.yellow => l10n.fantasyRuleYellow,
          FantasyScoreRule.red => l10n.fantasyRuleRed,
        };
    String groupLabel(FantasyPositionRule rule) => switch (rule) {
          FantasyPositionRule.conceded => l10n.fantasyRulesConcededEach,
          FantasyPositionRule.cleanSheet => l10n.fantasyRuleCleanSheet,
          FantasyPositionRule.teamGoal => l10n.fantasyRuleTeamGoals,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          children: [
            for (final rule in FantasyScoreRule.values)
              ScoreStepperRow(
                keyName: '$keyPrefix-${rule.name}',
                label: label(rule),
                value: table.valueOf(rule),
                decimal: decimal,
                onLess: enabled
                    ? () => onChanged(table.withValue(rule, table.valueOf(rule) - FantasyScoringTable.step))
                    : null,
                onMore: enabled
                    ? () => onChanged(table.withValue(rule, table.valueOf(rule) + FantasyScoringTable.step))
                    : null,
              ),
          ],
        ),
        for (final group in FantasyPositionRule.values) ...[
          const SizedBox(height: AppSizes.s16),
          Text(groupLabel(group), style: AppTypography.title().copyWith(fontSize: AppSizes.s14)),
          const SizedBox(height: AppSizes.s6),
          _Card(
            children: [
              for (final slot in FantasyScoringTable.positions)
                ScoreStepperRow(
                  keyName: '$keyPrefix-${group.name}-${slot.key}',
                  label: fantasySlotLabel(l10n, slot),
                  badge: true,
                  value: table.positionValue(group, slot),
                  decimal: decimal,
                  onLess: enabled
                      ? () => onChanged(table.withPositionValue(
                          group, slot, table.positionValue(group, slot) - FantasyScoringTable.step))
                      : null,
                  onMore: enabled
                      ? () => onChanged(table.withPositionValue(
                          group, slot, table.positionValue(group, slot) + FantasyScoringTable.step))
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.greyLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.greyLight),
              children[i],
            ],
          ],
        ),
      );
}

/// Linha "rótulo · −  valor  +" (valor com sinal, verde/vermelho).
class ScoreStepperRow extends StatelessWidget {
  final String keyName;
  final String label;
  final num value;
  final String decimal;
  final bool badge;
  final VoidCallback? onLess;
  final VoidCallback? onMore;

  const ScoreStepperRow({
    super.key,
    required this.keyName,
    required this.label,
    required this.value,
    this.decimal = ',',
    this.badge = false,
    this.onLess,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final color = value > 0
        ? AppColors.success
        : value < 0
            ? AppColors.danger
            : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s2, AppSizes.s4, AppSizes.s2),
      child: Row(
        children: [
          Expanded(
            child: badge
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(AppSizes.s6),
                      ),
                      child: Text(label,
                          style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
                    ),
                  )
                : Text(label, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
          ),
          IconButton(key: ValueKey('$keyName-less'), icon: const Icon(Icons.remove_rounded), onPressed: onLess),
          SizedBox(
            width: AppSizes.s52,
            child: Text(
              FantasyScoringRules.signed(value, decimal: decimal),
              key: ValueKey('$keyName-value'),
              textAlign: TextAlign.center,
              style: AppTypography.title(color: color).copyWith(fontSize: AppSizes.s16),
            ),
          ),
          IconButton(key: ValueKey('$keyName-more'), icon: const Icon(Icons.add_rounded), onPressed: onMore),
        ],
      ),
    );
  }
}
