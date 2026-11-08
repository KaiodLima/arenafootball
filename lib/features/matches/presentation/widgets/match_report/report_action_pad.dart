import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Lance pedido no painel: o lado e o tipo (gol, cartão ou substituição).
typedef PadAction = ({MatchSide side, BookingType? booking, bool substitution});

/// Painel de lançamento (o coração da súmula): uma coluna por time, com a
/// borda na cor dele, e os botões grandes Gol, Amarelo e Vermelho.
class ReportActionPad extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final Color homeColor;
  final Color awayColor;
  final ValueChanged<PadAction> onAction;

  const ReportActionPad({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeColor,
    required this.awayColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, AppSizes.s4),
      child: Row(
        children: [
          Expanded(child: _Column(team: homeTeam, color: homeColor, side: MatchSide.home, onAction: onAction)),
          const SizedBox(width: AppSizes.s10),
          Expanded(child: _Column(team: awayTeam, color: awayColor, side: MatchSide.away, onAction: onAction)),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  final String team;
  final Color color;
  final MatchSide side;
  final ValueChanged<PadAction> onAction;

  const _Column({required this.team, required this.color, required this.side, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border(top: BorderSide(color: color, width: AppSizes.s4)),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.06), blurRadius: AppSizes.s10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            team.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label(color: AppColors.textSecondary)
                .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.6),
          ),
          const SizedBox(height: AppSizes.s6),
          _PadButton(
            label: l10n.reportGoal,
            icon: const Icon(Icons.sports_soccer_rounded, color: AppColors.white, size: AppSizes.s20),
            background: AppColors.primary,
            foreground: AppColors.white,
            onTap: () => onAction((side: side, booking: null, substitution: false)),
          ),
          const SizedBox(height: AppSizes.s6),
          Row(
            children: [
              Expanded(
                child: _PadButton(
                  label: l10n.matchReportYellow,
                  icon: const BookingIcon(type: BookingType.yellow),
                  background: AppColors.gold.withValues(alpha: 0.2),
                  foreground: AppColors.textPrimary,
                  onTap: () => onAction((side: side, booking: BookingType.yellow, substitution: false)),
                ),
              ),
              const SizedBox(width: AppSizes.s6),
              _PadButton(
                icon: const BookingIcon(type: BookingType.red),
                background: AppColors.danger.withValues(alpha: 0.12),
                foreground: AppColors.textPrimary,
                onTap: () => onAction((side: side, booking: BookingType.red, substitution: false)),
                tooltip: l10n.matchReportRed,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          _PadButton(
            label: l10n.reportSubstitution,
            icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primaryDark, size: AppSizes.s20),
            background: AppColors.primary.withValues(alpha: 0.12),
            foreground: AppColors.primaryDark,
            onTap: () => onAction((side: side, booking: null, substitution: true)),
          ),
        ],
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final String? label;
  final Widget icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final String? tooltip;

  const _PadButton({
    this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      borderRadius: BorderRadius.circular(AppSizes.s12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onTap,
        child: SizedBox(
          height: AppSizes.s44,
          width: label == null ? AppSizes.s44 : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (label != null) ...[
                const SizedBox(width: AppSizes.s6),
                Flexible(
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: foreground)
                        .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
