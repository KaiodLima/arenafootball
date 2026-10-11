import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Bloco de formulário: título em versalete (com um complemento opcional à
/// direita, ex.: "3 fotos") e o conteúdo num card branco.
class FormSection extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const FormSection({super.key, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTypography.label(color: AppColors.textSecondary).copyWith(
                      fontSize: AppSizes.s12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          ArenaCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(AppSizes.s16),
            child: child,
          ),
        ],
      ),
    );
  }
}
