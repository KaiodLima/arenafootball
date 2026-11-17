import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_round.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Grupo A" a partir do nome gravado ("A" ou já "Grupo A").
String groupLabel(AppLocalizations l10n, String name) {
  final trimmed = name.trim();
  return trimmed.toLowerCase().startsWith('grupo') ? trimmed : l10n.matchRoundGroup(trimmed);
}

/// Nome da fase eliminatória por extenso.
String matchStageLabel(AppLocalizations l10n, MatchStage stage) => switch (stage) {
      MatchStage.roundOf16 => l10n.matchStageRoundOf16,
      MatchStage.quarterFinal => l10n.matchStageQuarterFinal,
      MatchStage.semiFinal => l10n.matchStageSemiFinal,
      MatchStage.thirdPlace => l10n.matchStageThirdPlace,
      MatchStage.finalMatch => l10n.matchStageFinal,
      MatchStage.other => l10n.matchStageOther,
    };

/// Texto da fase (tile do formulário).
String matchRoundLabel(AppLocalizations l10n, MatchRound round) =>
    round.isKnockout ? matchStageLabel(l10n, round.stage!) : groupLabel(l10n, round.groupName);

/// Escolha na folha: [round] nulo = "Sem fase definida".
class MatchRoundPick {
  final MatchRound? round;

  const MatchRoundPick(this.round);
}

/// Folha "Fase da partida": os grupos do campeonato (contam na tabela) e as
/// fases do mata-mata. Nulo = fechou sem escolher.
Future<MatchRoundPick?> showMatchRoundPicker(
  BuildContext context, {
  required List<GroupDTO> groups,
  required MatchRound? selected,
}) {
  final l10n = AppLocalizations.of(context);
  Widget option(MatchRound? round, String label, IconData icon, {Key? key}) => ListTile(
        key: key,
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(label, style: AppTypography.label(color: AppColors.textPrimary)),
        trailing: round == selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
        onTap: () => Navigator.pop(context, MatchRoundPick(round)),
      );
  Widget section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s12, AppSizes.s20, AppSizes.s4),
        child: Text(text, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
      );
  return showModalBottomSheet<MatchRoundPick>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: AppSizes.s16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
              child: Text(l10n.matchRoundPick, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
            ),
            option(null, l10n.matchRoundNone, Icons.remove_circle_outline_rounded, key: const ValueKey('round-none')),
            if (groups.isNotEmpty) ...[
              section(l10n.matchRoundGroupsSection),
              for (final g in groups)
                option(
                  MatchRound.group(groupId: g.id, groupName: g.description),
                  groupLabel(l10n, g.description),
                  Icons.grid_view_rounded,
                  key: ValueKey('round-group-${g.id}'),
                ),
            ],
            section(l10n.matchRoundKnockoutSection),
            for (final stage in MatchStage.values)
              option(
                MatchRound.knockout(stage),
                matchStageLabel(l10n, stage),
                stage == MatchStage.finalMatch ? Icons.emoji_events_rounded : Icons.account_tree_outlined,
                key: ValueKey('round-stage-${stage.key}'),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Campo "Fase" do formulário (abre a folha).
class MatchRoundTile extends StatelessWidget {
  final MatchRound? round;
  final VoidCallback onTap;

  const MatchRoundTile({super.key, required this.round, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    final current = round;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        key: const ValueKey('match-round-tile'),
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, AppSizes.s12),
          child: Row(
            children: [
              Icon(
                current == null
                    ? Icons.flag_outlined
                    : current.isKnockout
                        ? Icons.account_tree_outlined
                        : Icons.grid_view_rounded,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.matchRoundPick, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    Text(
                      current == null ? l10n.matchRoundNone : matchRoundLabel(l10n, current),
                      style: AppTypography.label(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selo da fase: "GRUPO A" (verde), as fases do mata-mata e a "FINAL"
/// dourada com troféu. [compact]: menor, para o card em linha.
class MatchStageBadge extends StatelessWidget {
  final MatchRound round;
  final bool compact;

  const MatchStageBadge({super.key, required this.round, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stage = round.stage;
    final isFinal = stage == MatchStage.finalMatch;
    final label = stage == null
        ? groupLabel(l10n, round.groupName).toUpperCase()
        : switch (stage) {
            MatchStage.roundOf16 => l10n.matchStageBadgeRoundOf16,
            MatchStage.quarterFinal => l10n.matchStageBadgeQuarterFinal,
            MatchStage.semiFinal => l10n.matchStageBadgeSemiFinal,
            MatchStage.thirdPlace => l10n.matchStageBadgeThirdPlace,
            MatchStage.finalMatch => l10n.matchStageBadgeFinal,
            MatchStage.other => l10n.matchStageBadgeOther,
          };
    final background = isFinal
        ? AppColors.gold
        : stage == null
            ? AppColors.primarySoft
            : AppColors.primaryDark;
    final foreground = isFinal
        ? AppColors.primaryDark
        : stage == null
            ? AppColors.primaryDark
            : AppColors.white;
    final size = compact ? AppSizes.s10 : AppSizes.s12;
    return Container(
      key: const ValueKey('match-stage-badge'),
      padding: EdgeInsets.symmetric(horizontal: compact ? AppSizes.s6 : AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.s6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFinal) ...[
            Icon(Icons.emoji_events_rounded, size: size + AppSizes.s2, color: foreground),
            const SizedBox(width: AppSizes.s2),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: foreground).copyWith(fontSize: size, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
