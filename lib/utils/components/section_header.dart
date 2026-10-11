import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Título de seção das listas ("Destaques", "Últimas notícias"...), com ação
/// opcional à direita.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s8, bottom: AppSizes.s12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
