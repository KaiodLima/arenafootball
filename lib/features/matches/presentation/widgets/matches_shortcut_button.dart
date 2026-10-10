import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Botão em pílula verde dos atalhos da aba de tabelas e da AppBar de
/// "todos os jogos".
class MatchesShortcutButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const MatchesShortcutButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s18)),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
