import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Seletor "Ontem · Hoje · Amanhã" da aba de tabelas, com a data de cada dia.
class MatchDaySwitch extends StatelessWidget {
  static const List<MatchesFilter> days = [MatchesFilter.yesterday, MatchesFilter.today, MatchesFilter.tomorrow];

  final MatchesFilter selected;
  final ValueChanged<MatchesFilter> onChanged;

  /// Base das datas (testes); padrão = agora.
  final DateTime? now;

  const MatchDaySwitch({super.key, required this.selected, required this.onChanged, this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = now ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: _DaySegment(
                label: switch (day) {
                  MatchesFilter.yesterday => l10n.matchesYesterday,
                  MatchesFilter.tomorrow => l10n.matchesTomorrow,
                  _ => l10n.matchesToday,
                },
                date: WatchMatchesUseCase.formatMatchDate(
                  DateTime(base.year, base.month, base.day + (day.dayOffset ?? 0)),
                ),
                selected: day == selected,
                onTap: () => onChanged(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _DaySegment extends StatelessWidget {
  final String label;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  const _DaySegment({required this.label, required this.date, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.s10);
    final foreground = selected ? AppColors.white : AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $date',
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: selected ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
            decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.transparent, borderRadius: radius),
            child: Column(
              children: [
                Text(
                  label,
                  style: AppTypography.label(color: foreground).copyWith(
                    fontSize: AppSizes.s14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.s2),
                Text(
                  date,
                  style: AppTypography.subtitle(color: selected ? AppColors.whiteSoft : AppColors.textSecondary)
                      .copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
