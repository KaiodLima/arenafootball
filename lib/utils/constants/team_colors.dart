import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Cor da paleta de times. O que se grava no Firestore é o [hex]
/// (`corPrimaria`/`corSecundaria`), para não depender desta lista.
enum TeamColor {
  white(AppColors.teamWhite),
  black(AppColors.teamBlack),
  grey(AppColors.teamGrey),
  red(AppColors.teamRed),
  wine(AppColors.teamWine),
  orange(AppColors.teamOrange),
  yellow(AppColors.teamYellow),
  green(AppColors.teamGreen),
  blue(AppColors.teamBlue),
  navy(AppColors.teamNavy),
  purple(AppColors.teamPurple),
  pink(AppColors.teamPink);

  final Color color;

  const TeamColor(this.color);

  String get hex => colorToHex(color);

  /// Cor da paleta com esse hex (ignora caixa); nula se não for da paleta.
  static TeamColor? fromHex(String hex) {
    final key = hex.trim().toUpperCase();
    for (final value in values) {
      if (value.hex == key) return value;
    }
    return null;
  }

  String label(AppLocalizations l10n) => switch (this) {
        TeamColor.white => l10n.colorWhite,
        TeamColor.black => l10n.colorBlack,
        TeamColor.grey => l10n.colorGrey,
        TeamColor.red => l10n.colorRed,
        TeamColor.wine => l10n.colorWine,
        TeamColor.orange => l10n.colorOrange,
        TeamColor.yellow => l10n.colorYellow,
        TeamColor.green => l10n.colorGreen,
        TeamColor.blue => l10n.colorBlue,
        TeamColor.navy => l10n.colorNavy,
        TeamColor.purple => l10n.colorPurple,
        TeamColor.pink => l10n.colorPink,
      };
}

/// "#RRGGBB" (maiúsculo, sem alfa).
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Cor de "#RRGGBB"; nula se o texto não for um hex válido.
Color? colorFromHex(String hex) {
  final digits = hex.trim().replaceFirst('#', '');
  if (digits.length != 6) return null;
  final value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// Cor clara (o check e a borda ficam escuros sobre ela).
bool isLightColor(Color color) => color.computeLuminance() > 0.6;
