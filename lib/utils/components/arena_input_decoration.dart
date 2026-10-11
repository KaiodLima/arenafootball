import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Decoração dos campos preenchidos do app (login, cadastro, formulários):
/// fundo claro, cantos arredondados, rótulo flutuando dentro do campo.
InputDecoration arenaInputDecoration({
  required String label,
  IconData? icon,
  String? errorText,
  String? hintText,
  Widget? suffix,
}) {
  InputBorder border(Color color, double width) => _FilledFieldBorder(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    errorText: errorText,
    errorMaxLines: 2,
    filled: true,
    fillColor: AppColors.inputFill,
    prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textSecondary, size: AppSizes.s20),
    suffixIcon: suffix,
    labelStyle: AppTypography.subtitle(),
    hintStyle: AppTypography.subtitle(),
    floatingLabelStyle: AppTypography.label(),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
    border: border(AppColors.transparent, 0),
    enabledBorder: border(AppColors.transparent, 0),
    focusedBorder: border(AppColors.primary, 1.5),
    errorBorder: border(AppColors.danger, 1),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// Contorno arredondado que se comporta como campo preenchido: com
/// `isOutline` falso o rótulo flutua *dentro* do campo (e não recortado na
/// linha da borda, como no `OutlineInputBorder`).
class _FilledFieldBorder extends OutlineInputBorder {
  const _FilledFieldBorder({super.borderSide, super.borderRadius});

  @override
  bool get isOutline => false;

  // Sem a brecha que o contorno abre para o rótulo: aqui o rótulo fica dentro.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    super.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  _FilledFieldBorder copyWith({BorderSide? borderSide, BorderRadius? borderRadius, double? gapPadding}) {
    return _FilledFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
