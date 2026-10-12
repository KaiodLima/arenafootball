import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Chip de escolha única: selecionado fica verde-escuro com texto branco.
class ArenaChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const ArenaChoiceChip({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.primaryDark;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primaryDark : AppColors.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primaryDark : AppColors.greyLight)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSizes.s16, color: foreground),
                  const SizedBox(width: AppSizes.s6),
                ],
                Text(label, style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
