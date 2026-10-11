import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Separador "—— ou ——" entre as ações principal e secundária.
class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.greyLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
          child: Text(label, style: AppTypography.subtitle()),
        ),
        const Expanded(child: Divider(color: AppColors.greyLight)),
      ],
    );
  }
}
