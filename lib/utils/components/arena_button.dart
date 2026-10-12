import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Botão padrão do app. Sem [width], ocupa a largura disponível.
class ArenaButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String? title;
  final double? fontSize;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonBorderColor;
  final double? borderRadius;
  final bool? isLoading;
  final void Function()? function;

  /// Ícone opcional à esquerda do título (ex.: logo do Google).
  final Widget? leading;

  const ArenaButton({
    super.key,
    this.height,
    this.width,
    required this.title,
    this.fontSize,
    this.textColor,
    this.buttonColor,
    this.buttonBorderColor,
    this.borderRadius,
    required this.function,
    this.isLoading,
    this.leading,
  });

  /// Botão cheio verde (ação principal).
  const ArenaButton.primary({
    super.key,
    required this.title,
    required this.function,
    this.isLoading,
    this.width,
    this.height,
  })  : fontSize = AppSizes.s16,
        textColor = AppColors.white,
        buttonColor = AppColors.primary,
        buttonBorderColor = null,
        borderRadius = AppSizes.radius,
        leading = null;

  /// Botão com contorno verde (ação secundária).
  const ArenaButton.outlined({
    super.key,
    required this.title,
    required this.function,
    this.isLoading,
    this.width,
    this.height,
  })  : fontSize = AppSizes.s16,
        textColor = AppColors.primary,
        buttonColor = AppColors.white,
        buttonBorderColor = AppColors.primary,
        borderRadius = AppSizes.radius,
        leading = null;

  @override
  Widget build(BuildContext context) {
    final loading = isLoading ?? false;
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : function,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? AppColors.primary,
          disabledBackgroundColor: buttonColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: buttonBorderColor ?? buttonColor ?? AppColors.white),
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
          ),
        ),
        child: loading
            ? SizedBox(
                width: AppSizes.s24,
                height: AppSizes.s24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor ?? AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: AppSizes.s10)],
                  Flexible(
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        color: textColor ?? AppColors.white,
                        fontSize: fontSize ?? AppSizes.s14,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
