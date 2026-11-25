import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Como terminou o pênalti: convertido (gol) ou perdido ([PenaltyMiss]).
sealed class PenaltyOutcome {
  const PenaltyOutcome();
}

class PenaltyScored extends PenaltyOutcome {
  const PenaltyScored();
}

class PenaltyMissed extends PenaltyOutcome {
  final PenaltyMiss miss;

  const PenaltyMissed(this.miss);
}

/// 1º passo do "Pênalti" na súmula: Convertido · Defendido · Para fora/trave.
/// Nulo = fechou a folha.
Future<PenaltyOutcome?> showPenaltyOutcomeSheet(BuildContext context, {required String title}) {
  return showModalBottomSheet<PenaltyOutcome>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (sheet) {
      final l10n = AppLocalizations.of(sheet);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
              const SizedBox(height: AppSizes.s12),
              _OutcomeTile(
                icon: Icons.sports_soccer_rounded,
                color: AppColors.primary,
                label: l10n.reportPenaltyScored,
                onTap: () => Navigator.pop(sheet, const PenaltyScored()),
              ),
              const SizedBox(height: AppSizes.s8),
              _OutcomeTile(
                icon: Icons.back_hand_rounded,
                color: AppColors.danger,
                label: l10n.reportPenaltySavedOption,
                onTap: () => Navigator.pop(sheet, const PenaltyMissed(PenaltyMiss.saved)),
              ),
              const SizedBox(height: AppSizes.s8),
              _OutcomeTile(
                icon: Icons.block_rounded,
                color: AppColors.danger,
                label: l10n.reportPenaltyWideOption,
                onTap: () => Navigator.pop(sheet, const PenaltyMissed(PenaltyMiss.wide)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OutcomeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _OutcomeTile({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.s12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s14),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.s24),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.label(color: AppColors.textPrimary)
                      .copyWith(fontSize: AppSizes.s16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
