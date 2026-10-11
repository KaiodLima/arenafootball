import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// AppBar verde-escura com título e subtítulo (grupos, classificação,
/// rankings e todos os jogos).
class PageTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;

  const PageTitleBar({super.key, required this.title, required this.subtitle, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + AppSizes.s8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      actions: actions,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
          const SizedBox(height: AppSizes.s2),
          Text(subtitle, style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
