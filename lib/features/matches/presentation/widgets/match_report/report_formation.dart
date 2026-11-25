import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/formation.dart';
import 'package:arena_soccer/features/matches/domain/match_pitch.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_lineup_pitch.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/pitch_painter.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Sigla da vaga (GOL, LAT, ZAG, VOL, MEI, ATA).
String slotRoleLabel(AppLocalizations l10n, SlotRole role) => switch (role) {
      SlotRole.goalkeeper => l10n.formationSlotGoalkeeper,
      SlotRole.fullBack => l10n.formationSlotFullBack,
      SlotRole.centerBack => l10n.formationSlotCenterBack,
      SlotRole.defensiveMid => l10n.formationSlotDefensiveMid,
      SlotRole.midfielder => l10n.formationSlotMidfielder,
      SlotRole.forward => l10n.formationSlotForward,
    };

/// "Formação" do time na aba Escalação da súmula: a pílula com a formação
/// (abre a folha com as do tamanho atual de titulares + Livre), o "Sugerir
/// pela posição", os avisos (vaga vazia, titular sem vaga, tamanho sem
/// formação) e o editor de vagas: a metade do campo com as vagas da formação,
/// cada uma com a sigla e o titular (número + sobrenome). Tocar na vaga
/// escolhe quem joga nela (quem estava em outra vaga troca de lugar).
class ReportFormationSection extends StatelessWidget {
  final MatchSide side;
  final String teamName;
  final List<LineupEntry> lineup;

  /// Código gravado (nulo = Livre).
  final String? formationCode;
  final List<PlayerDTO> squad;
  final Color color;
  final ValueChanged<Formation?> onFormation;
  final void Function(int slot, String playerId) onSlot;
  final VoidCallback onSuggest;

  const ReportFormationSection({
    super.key,
    required this.side,
    required this.teamName,
    required this.lineup,
    required this.formationCode,
    required this.squad,
    required this.color,
    required this.onFormation,
    required this.onSlot,
    required this.onSuggest,
  });

  Future<void> _pickFormation(BuildContext context, int starters) async {
    final picked = await showFormationSheet(
      context,
      teamName: teamName,
      options: Formation.forStarters(starters),
      current: formationCode,
    );
    if (picked == null) return;
    onFormation(Formation.parse(picked));
  }

  Future<void> _pickPlayer(BuildContext context, Formation formation, int slot) async {
    final playerId = await showSlotPlayerSheet(
      context,
      formation: formation,
      slot: slot,
      starters: lineup.where((e) => e.starter).toList(),
      squad: squad,
      color: color,
    );
    if (playerId != null) onSlot(slot, playerId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formation = Formation.parse(formationCode);
    final starters = lineup.where((e) => e.starter).length;
    final hasOptions = Formation.forStarters(starters).isNotEmpty;
    final empty = formation?.emptySlots(lineup) ?? 0;
    final unplaced = formation == null
        ? 0
        : lineup.where((e) => e.starter && (e.slot == null || formation.seatOf(e.slot!) == null)).length;
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.s8),
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.s14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.reportFormation, style: AppTypography.label(color: AppColors.textPrimary)),
              const SizedBox(width: AppSizes.s8),
              ActionChip(
                key: const ValueKey('report-formation-pill'),
                onPressed: hasOptions || formation != null ? () => _pickFormation(context, starters) : null,
                avatar: Icon(Icons.grid_on_rounded, size: AppSizes.s16, color: color),
                label: Text(formation?.code ?? l10n.reportFormationFree),
                labelStyle: AppTypography.label(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w800),
                side: BorderSide(color: color),
                backgroundColor: color.withValues(alpha: 0.08),
                shape: const StadiumBorder(),
              ),
            ],
          ),
          if (!hasOptions && formation == null) _Notice(text: l10n.reportFormationNeedStarters, warning: false),
          if (formation != null) ...[
            const SizedBox(height: AppSizes.s8),
            FormationSlotEditor(
              formation: formation,
              lineup: lineup,
              squad: squad,
              color: color,
              onTapSlot: (slot) => _pickPlayer(context, formation, slot),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const ValueKey('report-formation-suggest'),
                onPressed: onSuggest,
                style: TextButton.styleFrom(foregroundColor: color),
                icon: const Icon(Icons.auto_fix_high_rounded, size: AppSizes.s18),
                label: Text(l10n.reportFormationSuggest, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (empty > 0) _Notice(text: l10n.reportFormationEmptySlots(empty), warning: true),
            if (unplaced > 0) _Notice(text: l10n.reportFormationUnplaced(unplaced), warning: true),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final bool warning;

  const _Notice({required this.text, required this.warning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s8),
      child: Row(
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: AppSizes.s16,
            color: warning ? AppColors.warning : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.s6),
          Expanded(child: Text(text, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12))),
        ],
      ),
    );
  }
}

/// Editor de vagas: a metade do campo (o ataque no alto) com uma vaga por
/// jogador da formação.
class FormationSlotEditor extends StatelessWidget {
  final Formation formation;
  final List<LineupEntry> lineup;
  final List<PlayerDTO> squad;
  final Color color;
  final ValueChanged<int> onTapSlot;

  const FormationSlotEditor({
    super.key,
    required this.formation,
    required this.lineup,
    required this.squad,
    required this.color,
    required this.onTapSlot,
  });

  /// Altura de cada fileira (vaga + nome) com folga.
  static const double _rowHeight = AppSizes.s80;

  @override
  Widget build(BuildContext context) {
    final bySlot = {
      for (final e in lineup)
        if (e.starter && e.slot != null) e.slot!: e
    };
    final players = {for (final p in squad) p.id: p};
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.s14),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final rows = formation.lines.length + 1;
          final height = width.clamp(rows * _rowHeight + AppSizes.s24, double.infinity).toDouble();
          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryDark, AppColors.primaryMedium],
                      ),
                    ),
                  ),
                ),
                // O campo inteiro com o dobro da altura: aparece só a metade de baixo.
                Positioned(
                  left: 0,
                  right: 0,
                  top: -height,
                  height: height * 2,
                  child: const CustomPaint(painter: PitchPainter()),
                ),
                for (var slot = 0; slot < formation.players; slot++)
                  _slotAt(
                    context,
                    slot: slot,
                    width: width,
                    height: height,
                    entry: bySlot[slot],
                    player: players[bySlot[slot]?.playerId],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _slotAt(
    BuildContext context, {
    required int slot,
    required double width,
    required double height,
    required LineupEntry? entry,
    required PlayerDTO? player,
  }) {
    final place = formation.slotPlace(slot, MatchSide.home);
    final seat = formation.seatOf(slot)!;
    final tokenWidth = (width * 0.92 / seat.count - AppSizes.s4).clamp(AppSizes.s40, AppSizes.s80).toDouble();
    return Positioned(
      left: place.x * width - tokenWidth / 2,
      top: (place.y - 0.5) * 2 * height - _SlotToken.height / 2,
      width: tokenWidth,
      child: _SlotToken(
        key: ValueKey('slot-$slot'),
        role: formation.roleOf(slot),
        entry: entry,
        player: player,
        color: MatchLineupPitchCard.stripColor(color),
        onTap: () => onTapSlot(slot),
      ),
    );
  }
}

class _SlotToken extends StatelessWidget {
  final SlotRole role;
  final LineupEntry? entry;
  final PlayerDTO? player;
  final Color color;
  final VoidCallback onTap;

  const _SlotToken({
    super.key,
    required this.role,
    required this.entry,
    required this.player,
    required this.color,
    required this.onTap,
  });

  static const double _circle = AppSizes.s32;
  static const double _label = AppSizes.s14;

  /// Sigla (por cima do círculo) + círculo + nome.
  static const double height = AppSizes.s6 + _circle + AppSizes.s2 + _label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = entry;
    final name = current == null
        ? l10n.reportSlotEmpty
        : MatchPitch.shortName(player?.name.isNotEmpty == true ? player!.name : current.playerName);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: AppSizes.s6 + _circle,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: _circle,
                  height: _circle,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: current == null ? AppColors.white.withValues(alpha: 0.12) : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: current == null ? AppColors.whiteSoft : AppColors.white,
                      width: current == null ? 1.5 : 2,
                    ),
                  ),
                  child: current == null
                      ? const Icon(Icons.add_rounded, size: AppSizes.s18, color: AppColors.white)
                      : current.number != null
                          ? Text(
                              '${current.number}',
                              style: AppTypography.label(color: AppColors.white)
                                  .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w900, height: 1),
                            )
                          : player != null
                              ? PlayerAvatar(player: player!, size: _circle - 4)
                              : const Icon(Icons.person_rounded, size: AppSizes.s18, color: AppColors.white),
                ),
                // Sigla da vaga, por cima do círculo.
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.s4),
                    ),
                    child: Text(
                      slotRoleLabel(l10n, role),
                      style: AppTypography.label(color: AppColors.primaryDark)
                          .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w900, height: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s2),
          Container(
            height: _label,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppSizes.s4),
            ),
            alignment: Alignment.center,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: current == null ? AppColors.whiteSoft : AppColors.white)
                  .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w700, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Folha "Formação do <time>": Livre e as formações do tamanho atual de
/// titulares. Devolve o código ('' = Livre) ou nulo (fechou sem escolher).
Future<String?> showFormationSheet(
  BuildContext context, {
  required String teamName,
  required List<Formation> options,
  required String? current,
}) {
  final l10n = AppLocalizations.of(context);
  Widget option(String code, String label, {String? subtitle}) => ListTile(
        key: ValueKey('formation-option-${code.isEmpty ? 'livre' : code}'),
        leading: Icon(code.isEmpty ? Icons.blur_on_rounded : Icons.grid_on_rounded, color: AppColors.primaryDark),
        title: Text(label, style: AppTypography.label(color: AppColors.textPrimary)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        trailing: code == (current ?? '') ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
        onTap: () => Navigator.pop(context, code),
      );
  return showModalBottomSheet<String>(
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
              child: Text(l10n.reportFormationSheetTitle(teamName),
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
            ),
            option('', l10n.reportFormationFree, subtitle: l10n.reportFormationFreeHint),
            for (final f in options) option(f.code, f.code),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s8),
                child: Text(l10n.reportFormationNeedStarters, style: AppTypography.subtitle()),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Folha "Quem joga nesta vaga?": os titulares, com a vaga de cada um.
/// Devolve o id escolhido (nulo = fechou).
Future<String?> showSlotPlayerSheet(
  BuildContext context, {
  required Formation formation,
  required int slot,
  required List<LineupEntry> starters,
  required List<PlayerDTO> squad,
  required Color color,
}) {
  final l10n = AppLocalizations.of(context);
  final players = {for (final p in squad) p.id: p};
  final sorted = [...starters]..sort((a, b) => (a.slot ?? 99).compareTo(b.slot ?? 99));
  return showModalBottomSheet<String>(
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
              child: Text(
                l10n.reportSlotPickTitle(slotRoleLabel(l10n, formation.roleOf(slot))),
                style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
              ),
            ),
            for (final e in sorted)
              ListTile(
                key: ValueKey('slot-player-${e.playerId}'),
                leading: CircleAvatar(
                  backgroundColor: MatchLineupPitchCard.stripColor(color),
                  child: Text(
                    e.number?.toString() ?? '–',
                    style: AppTypography.label(color: AppColors.white).copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(
                  players[e.playerId]?.name ?? e.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  e.slot != null && formation.seatOf(e.slot!) != null
                      ? slotRoleLabel(l10n, formation.roleOf(e.slot!))
                      : l10n.reportSlotNone,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                trailing: e.slot == slot ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () => Navigator.pop(context, e.playerId),
              ),
          ],
        ),
      ),
    ),
  );
}
