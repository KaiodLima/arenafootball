import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Resumo do elenco: total de jogadores, gols e assistências.
class SquadSummary extends StatelessWidget {
  final int players;
  final int goals;
  final int assists;

  const SquadSummary({super.key, required this.players, required this.goals, required this.assists});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _Stat(value: players, label: l10n.playersSummaryPlayers, icon: Icons.groups_rounded)),
        const SizedBox(width: AppSizes.s10),
        Expanded(child: _Stat(value: goals, label: l10n.playersSummaryGoals, icon: Icons.sports_soccer_rounded)),
        const SizedBox(width: AppSizes.s10),
        Expanded(child: _Stat(value: assists, label: l10n.playersSummaryAssists, icon: Icons.assistant_rounded)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14, horizontal: AppSizes.s8),
      child: Column(
        children: [
          Icon(icon, size: AppSizes.s20, color: AppColors.primary),
          const SizedBox(height: AppSizes.s6),
          Text('$value', style: AppTypography.display().copyWith(fontSize: AppSizes.s24)),
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
