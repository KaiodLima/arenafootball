import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: AppSizes.navBarHeight,
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.transparent,
          indicatorColor: AppColors.primarySoft,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTypography.label(
              color: states.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.textSecondary,
            ).copyWith(fontSize: AppSizes.s12),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surface,
          surfaceTintColor: AppColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.fieldRadius)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: CircleBorder(),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge))),
        ),
      );
}
