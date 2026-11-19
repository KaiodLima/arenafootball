import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_rules.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Regras e pontuação" do Arena Fantasy: como jogar, prazo, tabela de pontos
/// (de [FantasyScoringRules]) e os parâmetros do campeonato. Sem leitura nova:
/// recebe a [config] de quem abriu; nula = padrões de [FantasyLimits].
class FantasyRulesPage extends StatelessWidget {
  final FantasyConfigDTO? config;

  const FantasyRulesPage({super.key, this.config});

  /// Vagas que pontuam pela posição (a LIVRE usa a do atleta).
  static const _positions = [
    FantasySlot.goalkeeper,
    FantasySlot.defender,
    FantasySlot.midfielder,
    FantasySlot.forward,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = this.config;
    final minMinutes = config?.minMinutes ?? FantasyLimits.defaultMinMinutes;
    final minDefense = config?.minDefenseMinutes ?? FantasyLimits.defaultMinDefenseMinutes;
    final captain = config?.captainMultiplier ?? FantasyLimits.defaultCaptain;
    final title = config?.title ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.fantasyRulesTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
            if (title.isNotEmpty)
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
        children: [
          if (config == null) ...[
            _Note(text: l10n.fantasyRulesDefaultsNote, key: const ValueKey('fantasy-rules-defaults')),
            const SizedBox(height: AppSizes.s16),
          ],
          FormSection(
            title: l10n.fantasyRulesHowToPlay,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Paragraph(l10n.fantasyRulesHowToPlayText),
                const SizedBox(height: AppSizes.s12),
                for (final slot in FantasySlot.values)
                  _Row(label: fantasySlotLabel(l10n, slot), value: _slotText(l10n, slot), badge: true),
                const SizedBox(height: AppSizes.s8),
                _Paragraph(l10n.fantasyRulesFlexNote, muted: true),
              ],
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesRound,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Bullet(icon: Icons.lock_clock_rounded, text: l10n.fantasyRulesRoundLock),
                _Bullet(icon: Icons.content_copy_rounded, text: l10n.fantasyRulesRoundCopy),
                _Bullet(icon: Icons.fact_check_rounded, text: l10n.fantasyRulesRoundPoints, last: true),
              ],
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesScoring,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Row(label: l10n.fantasyRulesPlay, value: l10n.fantasyRulesPoints, header: true),
                _Row(label: l10n.fantasyRuleBase, points: FantasyScoringRules.base),
                _Row(label: l10n.fantasyRuleGoal, points: FantasyScoringRules.goal),
                _Row(label: l10n.fantasyRuleAssist, points: FantasyScoringRules.assist),
                _Row(label: l10n.fantasyRuleWin, points: FantasyScoringRules.win),
                _Row(label: l10n.fantasyRuleDraw, points: FantasyScoringRules.draw),
                _Row(label: l10n.fantasyRuleLoss, points: FantasyScoringRules.loss),
                _Row(label: l10n.fantasyRuleYellow, points: FantasyScoringRules.yellow),
                _Row(label: l10n.fantasyRuleRed, points: FantasyScoringRules.red),
                const SizedBox(height: AppSizes.s8),
                _Paragraph(l10n.fantasyRulesScoringNote, muted: true),
              ],
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesByPosition,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PositionTable(positions: _positions),
                const SizedBox(height: AppSizes.s8),
                _Paragraph(l10n.fantasyRulesPositionNote, muted: true),
              ],
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesMinutes,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Bullet(
                  key: const ValueKey('fantasy-rules-min'),
                  icon: Icons.timer_outlined,
                  text: l10n.fantasyRulesMinutesShort(minMinutes),
                ),
                _Bullet(
                  key: const ValueKey('fantasy-rules-defense'),
                  icon: Icons.shield_outlined,
                  text: l10n.fantasyRulesMinutesDefense(minDefense),
                  last: true,
                ),
              ],
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesCaptain,
            child: _Bullet(
              key: const ValueKey('fantasy-rules-captain'),
              icon: Icons.copyright_rounded,
              text: l10n.fantasyRulesCaptainText(FantasySettings.captainLabel(captain)),
              last: true,
            ),
          ),
          FormSection(
            title: l10n.fantasyRulesRanking,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Bullet(icon: Icons.leaderboard_rounded, text: l10n.fantasyRulesRankingText),
                _Bullet(icon: Icons.drag_handle_rounded, text: l10n.fantasyRulesRankingTies),
                _Bullet(icon: Icons.emoji_events_rounded, text: l10n.fantasyRulesRankingChampion, last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _slotText(AppLocalizations l10n, FantasySlot slot) => switch (slot) {
        FantasySlot.goalkeeper => l10n.fantasyRulesSlotGoalkeeper,
        FantasySlot.defender => l10n.fantasyRulesSlotDefender,
        FantasySlot.midfielder => l10n.fantasyRulesSlotMidfielder,
        FantasySlot.forward => l10n.fantasyRulesSlotForward,
        FantasySlot.flex => l10n.fantasyRulesSlotFlex,
      };
}

/// Cor do valor: verde positivo, vermelho negativo, neutro no zero.
Color _pointsColor(int value) => value > 0
    ? AppColors.success
    : value < 0
        ? AppColors.danger
        : AppColors.textSecondary;

class _Paragraph extends StatelessWidget {
  final String text;
  final bool muted;

  const _Paragraph(this.text, {this.muted = false});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: muted
            ? AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)
            : AppTypography.body().copyWith(fontSize: AppSizes.s14),
      );
}

class _Note extends StatelessWidget {
  final String text;

  const _Note({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: AppSizes.s18, color: AppColors.primaryDark),
            const SizedBox(width: AppSizes.s8),
            Expanded(
              child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s12)),
            ),
          ],
        ),
      );
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool last;

  const _Bullet({super.key, required this.icon, required this.text, this.last = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : AppSizes.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.s20, color: AppColors.primaryDark),
            const SizedBox(width: AppSizes.s10),
            Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
          ],
        ),
      );
}

/// Linha "rótulo → valor": cabeçalho, vaga (sigla em selo) ou lance com os
/// [points] coloridos.
class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final int? points;
  final bool header;
  final bool badge;

  const _Row({required this.label, this.value, this.points, this.header = false, this.badge = false});

  @override
  Widget build(BuildContext context) {
    final points = this.points;
    final headerStyle = AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.greyLight))),
      child: Row(
        children: [
          if (badge)
            SizedBox(width: AppSizes.s60, child: _SlotBadge(label: label))
          else
            Expanded(
              child: Text(
                label,
                style: header ? headerStyle : AppTypography.body().copyWith(fontSize: AppSizes.s14),
              ),
            ),
          if (badge) const SizedBox(width: AppSizes.s12),
          if (badge)
            Expanded(child: Text(value ?? '', style: AppTypography.body().copyWith(fontSize: AppSizes.s14)))
          else
            Text(
              points == null ? (value ?? '') : FantasyScoringRules.signed(points),
              style: header
                  ? headerStyle
                  : AppTypography.label(color: _pointsColor(points ?? 0)).copyWith(fontSize: AppSizes.s16),
            ),
        ],
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label;

  const _SlotBadge({required this.label});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(AppSizes.s6),
          ),
          child: Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
        ),
      );
}

/// GOL/ZAG/MEI/ATA × gols sofridos, sem sofrer gols e gols da equipe.
class _PositionTable extends StatelessWidget {
  final List<FantasySlot> positions;

  const _PositionTable({required this.positions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headerStyle = AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12);
    Widget cell(Widget child, {bool first = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
          child: Align(alignment: first ? Alignment.centerLeft : Alignment.center, child: child),
        );
    Widget header(String text, {bool first = false}) =>
        cell(Text(text, textAlign: first ? TextAlign.left : TextAlign.center, style: headerStyle), first: first);
    Widget value(int? points) => cell(Text(
          points == null ? '—' : FantasyScoringRules.signed(points),
          style: AppTypography.label(color: points == null ? AppColors.textSecondary : _pointsColor(points))
              .copyWith(fontSize: AppSizes.s16),
        ));
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: const TableBorder(horizontalInside: BorderSide(color: AppColors.greyLight)),
      children: [
        TableRow(children: [
          header(l10n.fantasyRulesPosition, first: true),
          header(l10n.fantasyRulesConcededEach),
          header(l10n.fantasyRuleCleanSheet),
          header(l10n.fantasyRuleTeamGoals),
        ]),
        for (final slot in positions)
          TableRow(
            key: ValueKey('fantasy-rules-pos-${slot.key}'),
            children: [
              cell(_SlotBadge(label: fantasySlotLabel(l10n, slot)), first: true),
              value(FantasyScoringRules.conceded[slot]),
              value(FantasyScoringRules.cleanSheet[slot]),
              value(FantasyScoringRules.teamGoalsFor(slot)),
            ],
          ),
      ],
    );
  }
}
