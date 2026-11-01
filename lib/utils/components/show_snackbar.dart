import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Snackbar padrão do app (sucesso/erro). Substitui os vários
/// `_chamarSnackBar` que cada tela tinha.
void showSnackBar({
  required BuildContext context,
  required String message,
  bool isSuccess = true,
  int? durationSeconds,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  // Um aviso pendente não pode atrasar (ou engolir) o novo.
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
      duration: Duration(seconds: durationSeconds ?? 3),
      content: Text(message, style: const TextStyle(color: AppColors.white)),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(label: actionLabel, textColor: AppColors.white, onPressed: onAction)
          : null,
    ),
  );
}
