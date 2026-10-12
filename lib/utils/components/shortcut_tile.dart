import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Bloco de atalho: ícone num círculo verde-claro e o rótulo embaixo. Ocupa
/// uma fatia igual da linha (usar dentro de um `Row`).
class ShortcutTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ShortcutTile({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: title,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s2),
            child: Column(
              children: [
                Container(
                  width: AppSizes.s48,
                  height: AppSizes.s48,
                  decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.s22),
                ),
                const SizedBox(height: AppSizes.s6),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12, height: 1.15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
