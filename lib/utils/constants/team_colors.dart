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

/// Cores do time prontas para desenhar o cabeçalho: fundo claro no centro
/// (secundária) e acento nos cantos (principal). Nula quando o time não tem cor.
class TeamPalette {
  /// Fundo do centro (cor secundária, ou um tom bem claro do acento).
  final Color background;

  /// Texto/ícones sobre o fundo (o de maior contraste).
  final Color onBackground;

  /// Cantos, pílulas, pontos e feixes (cor principal).
  final Color accent;

  /// Tom mais escuro do acento (degradê dos cantos).
  final Color accentDark;

  /// Texto/ícones sobre o acento (chips, barra recolhida).
  final Color onAccent;

  /// Barra recolhida: o acento levemente escurecido.
  final Color bar;

  const TeamPalette({
    required this.background,
    required this.onBackground,
    required this.accent,
    required this.accentDark,
    required this.onAccent,
    required this.bar,
  });

  /// Barra recolhida clara: status bar escura.
  bool get isBarLight => onAccent != AppColors.white;

  /// Anel do escudo (círculo branco): o acento; se ele for claro, o tom escuro.
  Color get ring => isLightColor(accent) ? accentDark : accent;

  /// Filete dentro dos cantos: claro sobre acento escuro, escuro sobre claro.
  Color get line => isLightColor(accent) ? accentDark : AppColors.white;

  /// - principal e secundária: acento = principal, fundo = secundária (se as
  ///   duas forem parecidas demais, o fundo vira um tom claro da principal);
  /// - só uma delas: ela é o acento e o fundo é um tom claro dela;
  /// - nenhuma: nulo (o cabeçalho usa o verde do app).
  /// Como [fromHex], mas sem cores cai no verde e branco do app (cards que
  /// sempre precisam de uma paleta: carteirinha, card do atleta).
  static TeamPalette orDefault(String primary, String secondary) =>
      fromHex(primary, secondary) ?? fromHex(colorToHex(AppColors.primaryStrong), colorToHex(AppColors.white))!;

  static TeamPalette? fromHex(String primary, String secondary) {
    final first = colorFromHex(primary);
    final second = colorFromHex(secondary);
    final accent = first ?? second;
    if (accent == null) return null;
    final distinct = first != null && second != null && contrastRatio(first, second) >= 1.5;
    final background = distinct ? second : lightTint(accent);
    return TeamPalette(
      background: background,
      onBackground: readableOn(background),
      accent: accent,
      accentDark: Color.lerp(accent, AppColors.black, 0.3)!,
      onAccent: readableOn(accent),
      bar: Color.lerp(accent, AppColors.black, 0.12)!,
    );
  }
}

/// Tom bem claro da cor (fundo quando o time só tem uma cor).
Color lightTint(Color color) => Color.lerp(color, AppColors.white, 0.92)!;

/// Branco ou o texto escuro do app, o que tiver mais contraste com [background].
Color readableOn(Color background) {
  final white = contrastRatio(AppColors.white, background);
  final dark = contrastRatio(AppColors.textPrimary, background);
  return white >= dark ? AppColors.white : AppColors.textPrimary;
}

/// Contraste WCAG entre duas cores (1 a 21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final light = la > lb ? la : lb;
  final dark = la > lb ? lb : la;
  return (light + 0.05) / (dark + 0.05);
}

