import 'package:flutter/material.dart';
import 'package:arena_soccer/features/auth/domain/validators/password_strength.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Barra de 3 segmentos + rótulo com a força da senha.
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthMeter({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (filled, color, label) = switch (strength) {
      PasswordStrength.weak => (1, AppColors.danger, l10n.passwordStrengthWeak),
      PasswordStrength.medium => (2, AppColors.warning, l10n.passwordStrengthMedium),
      PasswordStrength.strong => (3, AppColors.primary, l10n.passwordStrengthStrong),
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s8, left: AppSizes.s4, right: AppSizes.s4),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: AppSizes.s4,
                decoration: BoxDecoration(
                  color: i < filled ? color : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSizes.s2),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: AppSizes.s4),
          ],
          const SizedBox(width: AppSizes.s12),
          Text(label, style: AppTypography.subtitle(color: color).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
