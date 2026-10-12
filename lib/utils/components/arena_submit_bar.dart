import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Barra fixa no rodapé dos formulários, com a ação principal (publicar,
/// salvar...). Use como `bottomNavigationBar` do Scaffold.
class ArenaSubmitBar extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPressed;

  const ArenaSubmitBar({super.key, required this.title, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s16, offset: Offset(0, -AppSizes.s2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s12),
          child: ArenaButton.primary(
            title: title,
            height: AppSizes.buttonHeightLarge,
            isLoading: loading,
            function: onPressed,
          ),
        ),
      ),
    );
  }
}
