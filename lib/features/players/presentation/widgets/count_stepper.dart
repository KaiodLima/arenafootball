import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha "ícone + rótulo ... [−] valor [+]" para contagens (gols,
/// assistências). O "−" fica desabilitado no 0 e o "+" no [max].
class CountStepper extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int max;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CountStepper({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.max,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Container(
          width: AppSizes.s36,
          height: AppSizes.s36,
          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          child: Icon(icon, size: AppSizes.s18, color: AppColors.primaryDark),
        ),
        const SizedBox(width: AppSizes.s12),
        Expanded(
          child: Text(label, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
        ),
        _Step(icon: Icons.remove_rounded, tooltip: l10n.goalDecrease, onTap: value > 0 ? onDecrement : null),
        SizedBox(
          width: AppSizes.s48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.title().copyWith(fontSize: AppSizes.s22),
          ),
        ),
        _Step(
            icon: Icons.add_rounded, tooltip: l10n.goalIncrease, onTap: value < max ? onIncrement : null, filled: true),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  const _Step({required this.icon, required this.tooltip, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: !enabled ? AppColors.greyLight : (filled ? AppColors.primary : AppColors.primarySoft),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: AppSizes.s36,
            height: AppSizes.s36,
            child: Icon(
              icon,
              size: AppSizes.s20,
              color: !enabled ? AppColors.textSecondary : (filled ? AppColors.white : AppColors.primaryDark),
            ),
          ),
        ),
      ),
    );
  }
}
