import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_rules.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/standings_table.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// Resultado da folha de regras: as regras e se valem para todos os grupos.
typedef GroupRulesChoice = ({GroupRules rules, bool toAll});

/// Folha "Regras do grupo": classificados, nome da próxima fase, repescagem,
/// eliminados e ida e volta, com a prévia das faixas num grupo de
/// [teamCount] times e "Aplicar a todos os grupos" (com mais de um grupo).
Future<GroupRulesChoice?> showGroupRulesSheet(
  BuildContext context, {
  required GroupRules rules,
  required int teamCount,
  required bool canApplyToAll,
}) {
  return showModalBottomSheet<GroupRulesChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _safeSheet(Theme(
      data: Theme.of(context),
      child: _GroupRulesSheet(rules: rules, teamCount: teamCount, canApplyToAll: canApplyToAll),
    )),
  );
}

class _GroupRulesSheet extends StatefulWidget {
  final GroupRules rules;
  final int teamCount;
  final bool canApplyToAll;

  const _GroupRulesSheet({required this.rules, required this.teamCount, required this.canApplyToAll});

  @override
  State<_GroupRulesSheet> createState() => _GroupRulesSheetState();
}

class _GroupRulesSheetState extends State<_GroupRulesSheet> {
  late GroupRules _rules = widget.rules;
  late final _phase = TextEditingController(text: widget.rules.nextPhase);
  bool _toAll = false;

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);
    final total = widget.teamCount;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.groupRulesTitle, style: AppTypography.title()),
            const SizedBox(height: AppSizes.s12),
            if (total > 0) ...[
              _ZonesPreview(rules: _rules, total: total),
              const SizedBox(height: AppSizes.s12),
            ],
            _CounterRow(
              title: l10n.groupRulesQualified,
              hint: l10n.groupRulesQualifiedHint,
              color: groupZoneColor(GroupZone.qualified),
              value: _rules.qualified,
              onChanged: (v) => setState(() => _rules = _rules.copyWith(qualified: v)),
            ),
            if (_rules.qualified > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.s8),
                child: ArenaTextField(
                  controller: _phase,
                  labelText: l10n.groupRulesNextPhase,
                  onChaged: (v) => _rules = _rules.copyWith(nextPhase: v.trim()),
                ),
              ),
            _CounterRow(
              title: l10n.groupRulesPlayoff,
              hint: l10n.groupRulesPlayoffHint,
              color: groupZoneColor(GroupZone.playoff),
              value: _rules.playoff,
              onChanged: (v) => setState(() => _rules = _rules.copyWith(playoff: v)),
            ),
            _CounterRow(
              title: l10n.groupRulesEliminated,
              hint: l10n.groupRulesEliminatedHint,
              color: groupZoneColor(GroupZone.eliminated),
              value: _rules.eliminated,
              onChanged: (v) => setState(() => _rules = _rules.copyWith(eliminated: v)),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _rules.homeAndAway,
              activeThumbColor: palette.primary,
              onChanged: (v) => setState(() => _rules = _rules.copyWith(homeAndAway: v)),
              title: Text(l10n.groupRulesHomeAndAway, style: AppTypography.label(color: AppColors.textPrimary)),
              subtitle: Text(l10n.groupRulesHomeAndAwayHint,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ),
            if (_rules.exceeds(total))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.s8),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: AppSizes.s18),
                    const SizedBox(width: AppSizes.s6),
                    Expanded(
                      child: Text(
                        l10n.groupRulesExceeds(total),
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.canApplyToAll)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _toAll,
                activeColor: palette.primary,
                onChanged: (v) => setState(() => _toAll = v ?? false),
                title: Text(l10n.groupRulesApplyAll, style: AppTypography.label(color: AppColors.textPrimary)),
              ),
            const SizedBox(height: AppSizes.s8),
            ArenaButton.primary(
              title: l10n.commonSave,
              function: () => Navigator.pop(
                context,
                (rules: _rules.copyWith(nextPhase: _rules.qualified > 0 ? _phase.text.trim() : ''), toAll: _toAll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha com título, explicação e o contador −/+ (0 = desligada).
class _CounterRow extends StatelessWidget {
  final String title;
  final String hint;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.title,
    required this.hint,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
      child: Row(
        children: [
          Container(
            width: AppSizes.s6,
            height: AppSizes.s36,
            decoration: BoxDecoration(
              color: value > 0 ? color : AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppSizes.s4),
            ),
          ),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label(color: AppColors.textPrimary)),
                Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          IconButton(
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: AppSizes.s28,
            child: Text('$value',
                textAlign: TextAlign.center, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
          ),
          IconButton(
            onPressed: value < GroupRules.maxCount ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

/// Prévia: uma bolinha por posição na cor da faixa.
class _ZonesPreview extends StatelessWidget {
  final GroupRules rules;
  final int total;

  const _ZonesPreview({required this.rules, required this.total});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.s6,
      runSpacing: AppSizes.s6,
      children: [
        for (var p = 1; p <= total; p++)
          Container(
            width: AppSizes.s28,
            height: AppSizes.s28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rules.zoneOf(p, total) == GroupZone.none
                  ? AppColors.greyLight
                  : groupZoneColor(rules.zoneOf(p, total)),
              borderRadius: BorderRadius.circular(AppSizes.s6),
            ),
            child: Text(
              '$p',
              style: AppTypography.label(
                color: rules.zoneOf(p, total) == GroupZone.none ? AppColors.textSecondary : AppColors.white,
              ).copyWith(fontSize: AppSizes.s12),
            ),
          ),
      ],
    );
  }
}

/// Resumo das regras ativas ("2 classificam · 1 na repescagem · Ida e
/// volta"); vazio quando nenhuma está ativa.
String groupRulesSummary(AppLocalizations l10n, GroupRules rules) => [
      if (rules.qualified > 0) l10n.groupRulesSummaryQualified(rules.qualified),
      if (rules.playoff > 0) l10n.groupRulesSummaryPlayoff(rules.playoff),
      if (rules.eliminated > 0) l10n.groupRulesSummaryEliminated(rules.eliminated),
      if (rules.homeAndAway) l10n.groupRulesHomeAndAway,
    ].join('  ·  ');

/// Folha acima da barra de navegação do sistema (Android de ponta a ponta).
Widget _safeSheet(Widget child) => SafeArea(top: false, child: child);
