import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Chip de atalho com ícone opcional (todos os jogos, grupos, artilharia...).
class ArenaChipButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onPressed;

  const ArenaChipButton({super.key, required this.title, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.greyLight)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.s18, color: AppColors.primaryDark),
                const SizedBox(width: AppSizes.s6),
              ],
              Text(title, style: AppTypography.label(color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}
