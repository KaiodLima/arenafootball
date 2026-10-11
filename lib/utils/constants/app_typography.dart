import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Estilos de texto. Títulos em Montserrat (fonte variável: o peso vem de
/// `fontVariations`, não só de `fontWeight`), corpo em Roboto.
class AppTypography {
  static const String _headingFamily = 'Montserrat';

  static TextStyle _heading(double size, double weight, Color color) => TextStyle(
        fontFamily: _headingFamily,
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w700,
        fontVariations: [FontVariation('wght', weight)],
        height: 1.2,
      );

  /// Título grande das telas de entrada.
  static TextStyle display({Color color = AppColors.textPrimary}) => _heading(AppSizes.s28, 750, color);

  /// Título de seção, sheet ou hero compacto.
  static TextStyle title({Color color = AppColors.textPrimary}) => _heading(AppSizes.s22, 700, color);

  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      TextStyle(fontSize: AppSizes.s14, color: color, height: 1.4);

  static TextStyle body({Color color = AppColors.textPrimary}) => TextStyle(fontSize: AppSizes.s16, color: color);

  /// Rótulo de botão e link.
  static TextStyle label({Color color = AppColors.primary}) =>
      TextStyle(fontSize: AppSizes.s14, color: color, fontWeight: FontWeight.w600);
}
