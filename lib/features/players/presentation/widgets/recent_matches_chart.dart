import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/presentation/player_match_stats.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Gráfico "Últimas partidas": por jogo, uma barra de gols (verde) e uma de
/// assistências (azul), com o número em cima e a data embaixo.
class RecentMatchesChart extends StatelessWidget {
  final List<PlayerMatchStat> stats;

  /// Toque numa coluna (abre a partida).
  final ValueChanged<PlayerMatchStat>? onTap;

  const RecentMatchesChart({super.key, required this.stats, this.onTap});

  static const double _barsHeight = AppSizes.s100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var top = 1;
    for (final s in stats) {
      if (s.goals > top) top = s.goals;
      if (s.assists > top) top = s.assists;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Legend(color: AppColors.primary, label: l10n.playersSummaryGoals),
            const SizedBox(width: AppSizes.s16),
            _Legend(color: AppColors.teamBlue, label: l10n.playersSummaryAssists),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final s in stats)
              Expanded(
                child: InkWell(
                  onTap: onTap == null ? null : () => onTap!(s),
                  borderRadius: BorderRadius.circular(AppSizes.s8),
                  child: Tooltip(
                    message: l10n.athleteChartTooltip(s.opponent, s.goals, s.assists),
                    child: Column(
                      children: [
                        SizedBox(
                          height: _barsHeight + AppSizes.s16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _Bar(value: s.goals, top: top, color: AppColors.primary),
                              const SizedBox(width: AppSizes.s2),
                              _Bar(value: s.assists, top: top, color: AppColors.teamBlue),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.s4),
                        Text(
                          _shortDate(s.match.date),
                          maxLines: 1,
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// "12/10/2026" → "12/10".
  static String _shortDate(String date) {
    final parts = date.split('/');
    return parts.length >= 2 ? '${parts[0]}/${parts[1]}' : date;
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final int top;
  final Color color;

  const _Bar({required this.value, required this.top, required this.color});

  @override
  Widget build(BuildContext context) {
    final height = value == 0 ? AppSizes.s2 : RecentMatchesChart._barsHeight * value / top;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Text('$value', style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s10)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: height),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, h, _) => Container(
            width: AppSizes.s8,
            height: h,
            decoration: BoxDecoration(
              color: value == 0 ? AppColors.greyLight : color,
              borderRadius: BorderRadius.circular(AppSizes.s4),
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.s10,
          height: AppSizes.s10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.s2)),
        ),
        const SizedBox(width: AppSizes.s6),
        Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
      ],
    );
  }
}
