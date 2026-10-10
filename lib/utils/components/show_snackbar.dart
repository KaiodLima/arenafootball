import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Snackbar padrão do app (sucesso/erro). Substitui os vários
/// `_chamarSnackBar` que cada tela tinha.
void showSnackBar({
  required BuildContext context,
  required String message,
  bool isSuccess = true,
  int? durationSeconds,
}) {
  final messenger = ScaffoldMessenger.of(context);
  // Um aviso pendente não pode atrasar (ou engolir) o novo.
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
      duration: Duration(seconds: durationSeconds ?? 3),
      content: Text(message, style: const TextStyle(color: AppColors.white)),
    ),
  );
}
