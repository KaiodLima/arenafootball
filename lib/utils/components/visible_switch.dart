import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha "Exibir no feed" (ícone de olho, rótulo, dica e switch). Toque na
/// linha inteira alterna.
class VisibleSwitch extends StatelessWidget {
  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  const VisibleSwitch(
      {super.key, required this.label, required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.s12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
        child: Row(
          children: [
            Icon(
              value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: value ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                  const SizedBox(height: AppSizes.s2),
                  Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
