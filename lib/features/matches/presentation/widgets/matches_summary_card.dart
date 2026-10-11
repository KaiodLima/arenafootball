import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/features/matches/domain/match_day.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Faixa com jogos · gols · média de gols por jogo do recorte.
class MatchesSummaryCard extends StatelessWidget {
  final MatchesSummary summary;

  const MatchesSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final average = NumberFormat('0.0', locale).format(summary.average);

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Item(
              icon: Icons.sports_rounded,
              value: '${summary.games}',
              label: l10n.matchesSummaryGames(summary.games),
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.greyLight),
            _Item(
              icon: Icons.sports_soccer_rounded,
              value: '${summary.goals}',
              label: l10n.matchesSummaryGoals(summary.goals),
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.greyLight),
            _Item(icon: Icons.trending_up_rounded, value: average, label: l10n.matchesSummaryAverage),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Item({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.s18, color: AppColors.primary),
              const SizedBox(width: AppSizes.s6),
              Text(value, style: AppTypography.title().copyWith(fontSize: AppSizes.s20, height: 1.0)),
            ],
          ),
          const SizedBox(height: AppSizes.s4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}
