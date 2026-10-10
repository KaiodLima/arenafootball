import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
      );
}
