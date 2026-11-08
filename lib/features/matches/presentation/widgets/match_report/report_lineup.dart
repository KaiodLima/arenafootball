import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba Escalação da súmula: o time escolhido nas abas com escudo e cor, o
/// placar de vagas (titulares x/11, reservas) e os atletas em três grupos
/// (Titulares, Reservas, Não relacionados) com a camisa, a foto e a pílula
/// Titular | Reserva; no fim, o espaço tracejado "+ Adicionar atleta".
class ReportLineup extends StatefulWidget {
  final MatchReportState state;
  final String? homeCrest;
  final String? awayCrest;
  final Color homeColor;
  final Color awayColor;
  final void Function(MatchSide side, PlayerDTO player, LineupRole role) onRole;
  final void Function(MatchSide side, LineupEntry entry) onNumber;
  final ValueChanged<MatchSide> onAddPlayer;

  const ReportLineup({
    super.key,
    required this.state,
    required this.homeCrest,
    required this.awayCrest,
    required this.homeColor,
    required this.awayColor,
    required this.onRole,
    required this.onNumber,
    required this.onAddPlayer,
  });

  @override
  State<ReportLineup> createState() => _ReportLineupState();
}

class _ReportLineupState extends State<ReportLineup> {
  MatchSide _side = MatchSide.home;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final match = state.match!;
    final color = _side == MatchSide.home ? widget.homeColor : widget.awayColor;
    final squad = state.squadOf(_side);
    final entries = {for (final e in match.lineup.of(_side)) e.playerId: e};
    final count = MatchReport.lineupCount(match.lineup.of(_side));
    List<PlayerDTO> group(LineupRole role) => squad.where((p) => state.roleOf(_side, p.id) == role).toList()
      ..sort((a, b) => (entries[a.id]?.number ?? 999).compareTo(entries[b.id]?.number ?? 999));

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s120),
      children: [
        Row(
          children: [
            for (final side in MatchSide.values) ...[
              if (side == MatchSide.away) const SizedBox(width: AppSizes.s8),
              Expanded(
                child: _SideTab(
                  name: side == MatchSide.home ? match.homeTeam : match.awayTeam,
                  crest: side == MatchSide.home ? widget.homeCrest : widget.awayCrest,
                  color: side == MatchSide.home ? widget.homeColor : widget.awayColor,
                  selected: _side == side,
                  onTap: () => setState(() => _side = side),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        _Counter(starters: count.starters, subs: count.subs, color: color),
        const SizedBox(height: AppSizes.s8),
        if (state.loadingSquads)
          const Padding(padding: EdgeInsets.all(AppSizes.s24), child: Center(child: CircularProgressIndicator()))
        else ...[
          for (final role in [LineupRole.starter, LineupRole.sub, LineupRole.none])
            if (group(role).isNotEmpty) ...[
              _GroupLabel(
                switch (role) {
                  LineupRole.starter => l10n.matchDetailsStarters,
                  LineupRole.sub => l10n.matchDetailsSubs,
                  LineupRole.none => l10n.reportNotRelated,
                },
              ),
              for (final player in group(role))
                _PlayerRow(
                  player: player,
                  entry: entries[player.id],
                  role: role,
                  color: color,
                  onRole: (next) => widget.onRole(_side, player, next),
                  onNumber: () {
                    final entry = entries[player.id];
                    if (entry != null) widget.onNumber(_side, entry);
                  },
                ),
            ],
          const SizedBox(height: AppSizes.s8),
          _AddTile(onTap: state.busy ? null : () => widget.onAddPlayer(_side)),
        ],
      ],
    );
  }
}

class _SideTab extends StatelessWidget {
  final String name;
  final String? crest;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SideTab(
      {required this.name, required this.crest, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s14),
        border: Border.all(color: selected ? color : AppColors.greyLight, width: selected ? AppSizes.s2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s8),
          child: Row(
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s28),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Titulares 9/11 · Reservas 4" com a barrinha das vagas de titular.
class _Counter extends StatelessWidget {
  final int starters;
  final int subs;
  final Color color;

  const _Counter({required this.starters, required this.subs, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.s14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reportStarters(starters),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Flexible(
                child: Text(
                  l10n.reportSubs(subs),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s4),
            child: LinearProgressIndicator(
              value: (starters / 11).clamp(0.0, 1.0),
              minHeight: AppSizes.s6,
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s12, AppSizes.s4, AppSizes.s6),
        child: Text(
          text.toUpperCase(),
          style:
              AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6),
        ),
      );
}

class _PlayerRow extends StatelessWidget {
  final PlayerDTO player;
  final LineupEntry? entry;
  final LineupRole role;
  final Color color;
  final ValueChanged<LineupRole> onRole;
  final VoidCallback onNumber;

  const _PlayerRow({
    required this.player,
    required this.entry,
    required this.role,
    required this.color,
    required this.onRole,
    required this.onNumber,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final position = PlayerPosition.fromKey(player.position);
    final related = role != LineupRole.none;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s14),
      ),
      child: Row(
        children: [
          // Camisa com o número (toque para trocar).
          GestureDetector(
            onTap: related ? onNumber : null,
            child: Container(
              width: AppSizes.s36,
              height: AppSizes.s36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: related ? color : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: related && entry?.number == null
                  ? const Icon(Icons.edit_rounded, size: AppSizes.s14, color: AppColors.white)
                  : Text(
                      entry?.number?.toString() ?? '–',
                      style: AppTypography.label(color: related ? AppColors.white : AppColors.textSecondary)
                          .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w900),
                    ),
            ),
          ),
          const SizedBox(width: AppSizes.s10),
          PlayerAvatar(player: player, size: AppSizes.s36),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary)),
                if (position != null)
                  Text(playerPositionLabel(l10n, position),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          _RolePill(role: role, color: color, onChanged: onRole),
        ],
      ),
    );
  }
}

/// Pílula segmentada Titular | Reserva; tocar na escolhida tira o atleta.
class _RolePill extends StatelessWidget {
  final LineupRole role;
  final Color color;
  final ValueChanged<LineupRole> onChanged;

  const _RolePill({required this.role, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget segment(LineupRole value, String label) {
      final selected = role == value;
      return GestureDetector(
        onTap: () => onChanged(selected ? LineupRole.none : value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s6),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.s20),
          ),
          child: Text(
            label,
            style: AppTypography.label(color: selected ? AppColors.white : AppColors.textSecondary)
                .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.s2),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(LineupRole.starter, l10n.reportStarter),
          segment(LineupRole.sub, l10n.reportSub),
        ],
      ),
    );
  }
}

/// Espaço tracejado "+ Adicionar atleta".
class _AddTile extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.s14),
      child: CustomPaint(
        painter: _DashedRect(color: AppColors.primary.withValues(alpha: 0.6)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              const SizedBox(width: AppSizes.s8),
              Text(l10n.matchReportAddPlayer, style: AppTypography.label(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  final Color color;

  const _DashedRect({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppSizes.s14)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}
