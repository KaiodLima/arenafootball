import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cores de destaque que mudam com o modo da home: verde (torcedor, padrão
/// do app) ou azul (modo organizador). Os componentes compartilhados leem
/// [ArenaPalette.of] em vez das constantes `AppColors.primary*`.
@immutable
class ArenaPalette extends ThemeExtension<ArenaPalette> {
  final Color primary;
  final Color primaryDark;
  final Color primaryMedium;
  final Color primaryStrong;
  final Color primarySoft;

  const ArenaPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryMedium,
    required this.primaryStrong,
    required this.primarySoft,
  });

  static const green = ArenaPalette(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryMedium: AppColors.primaryMedium,
    primaryStrong: AppColors.primaryStrong,
    primarySoft: AppColors.primarySoft,
  );

  static const blue = ArenaPalette(
    primary: AppColors.organizerPrimary,
    primaryDark: AppColors.organizerDark,
    primaryMedium: AppColors.organizerMedium,
    primaryStrong: AppColors.organizerStrong,
    primarySoft: AppColors.organizerSoft,
  );

  /// Paleta em uso (sem a extensão no tema: a verde).
  static ArenaPalette of(BuildContext context) => Theme.of(context).extension<ArenaPalette>() ?? green;

  /// [base] com a paleta azul: extensão, esquema de cores, barra inferior e FAB.
  static ThemeData organizerTheme(ThemeData base) => withPalette(base, blue);

  static ThemeData withPalette(ThemeData base, ArenaPalette palette) => base.copyWith(
        extensions: [palette],
        colorScheme: ColorScheme.fromSeed(seedColor: palette.primary, primary: palette.primary),
        navigationBarTheme: navigationBarTheme(palette),
        floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: palette.primary),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary),
      );

  static NavigationBarThemeData navigationBarTheme(ArenaPalette palette) => NavigationBarThemeData(
        height: AppSizes.navBarHeight,
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        indicatorColor: palette.primarySoft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.label(
            color: states.contains(WidgetState.selected) ? palette.primaryDark : AppColors.textSecondary,
          ).copyWith(fontSize: AppSizes.s12),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? palette.primaryDark : AppColors.textSecondary,
          ),
        ),
      );

  @override
  ArenaPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryMedium,
    Color? primaryStrong,
    Color? primarySoft,
  }) =>
      ArenaPalette(
        primary: primary ?? this.primary,
        primaryDark: primaryDark ?? this.primaryDark,
        primaryMedium: primaryMedium ?? this.primaryMedium,
        primaryStrong: primaryStrong ?? this.primaryStrong,
        primarySoft: primarySoft ?? this.primarySoft,
      );

  @override
  ArenaPalette lerp(ThemeExtension<ArenaPalette>? other, double t) {
    if (other is! ArenaPalette) return this;
    return ArenaPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryMedium: Color.lerp(primaryMedium, other.primaryMedium, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
    );
  }
}
