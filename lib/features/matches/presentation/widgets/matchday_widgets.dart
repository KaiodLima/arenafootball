import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Maior rodada aceita (mesmo limite das regras).
const int maxMatchday = 99;

/// Campo "Rodada" com −/+: nulo = "Sem rodada" (o − a partir da 1ª volta
/// para sem rodada).
class MatchdayStepper extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const MatchdayStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = value;
    final radius = BorderRadius.circular(AppSizes.fieldRadius);
    return Container(
      key: const ValueKey('matchday-stepper'),
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s4, AppSizes.s4, AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_list_numbered_rounded, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.matchdayTitle, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                Text(
                  current == null ? l10n.matchdayNone : l10n.matchdayValue(current),
                  key: const ValueKey('matchday-value'),
                  style: AppTypography.label(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('matchday-less'),
            tooltip: l10n.matchdayLess,
            icon: const Icon(Icons.remove_rounded),
            onPressed: current == null ? null : () => onChanged(current <= 1 ? null : current - 1),
          ),
          IconButton(
            key: const ValueKey('matchday-more'),
            tooltip: l10n.matchdayMore,
            icon: const Icon(Icons.add_rounded),
            onPressed: current != null && current >= maxMatchday ? null : () => onChanged((current ?? 0) + 1),
          ),
        ],
      ),
    );
  }
}

/// Selo "RODADA 3" (contorno verde). [compact]: menor, para o card em linha.
class MatchdayBadge extends StatelessWidget {
  final int matchday;
  final bool compact;

  const MatchdayBadge({super.key, required this.matchday, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? AppSizes.s10 : AppSizes.s12;
    return Container(
      key: const ValueKey('matchday-badge'),
      padding: EdgeInsets.symmetric(horizontal: compact ? AppSizes.s6 : AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.s6),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Text(
        AppLocalizations.of(context).matchdayBadge(matchday),
        maxLines: 1,
        style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: size, letterSpacing: 0.6),
      ),
    );
  }
}

/// Selo "TESTE" (âmbar) da partida de teste do admin e dos cards dela.
class MatchTestBadge extends StatelessWidget {
  final bool compact;

  const MatchTestBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('match-test-badge'),
      padding: EdgeInsets.symmetric(horizontal: compact ? AppSizes.s6 : AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(AppSizes.s6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: compact ? AppSizes.s10 : AppSizes.s12, color: AppColors.black),
          const SizedBox(width: AppSizes.s2),
          Text(
            AppLocalizations.of(context).matchTestBadge,
            maxLines: 1,
            style: AppTypography.label(color: AppColors.black).copyWith(
                fontSize: compact ? AppSizes.s10 : AppSizes.s12, fontWeight: FontWeight.w900, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
