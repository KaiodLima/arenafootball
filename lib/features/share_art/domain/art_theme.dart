import 'package:flutter/painting.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Cores da arte: a marca do Arena e as dos dois times. Ponto único para, no
/// futuro, aplicar cores, logo e patrocinador do campeonato (os templates só
/// leem daqui).
class ArtTheme {
  final Color brandDark;
  final Color brand;
  final Color accent;
  final Color home;
  final Color away;

  const ArtTheme({
    required this.brandDark,
    required this.brand,
    required this.accent,
    required this.home,
    required this.away,
  });

  /// Cor do time para fundo: a principal; sem cor, um tom da marca.
  /// Principal muito clara (time branco) com secundária escura: a secundária,
  /// para a arte não ficar desbotada nem o escudo sumir no branco.
  static Color teamColor(ArtTeam team, Color fallback) {
    final primary = colorFromHex(team.primaryColor);
    final secondary = colorFromHex(team.secondaryColor);
    if (primary != null && isLightColor(primary) && secondary != null && !isLightColor(secondary)) return secondary;
    return primary ?? fallback;
  }

  factory ArtTheme.of(ArtTeam home, ArtTeam away) {
    final homeColor = teamColor(home, AppColors.primaryMedium);
    return ArtTheme(
      brandDark: AppColors.primaryDark,
      brand: AppColors.primary,
      accent: AppColors.gold,
      home: homeColor,
      away: contrastingAway(homeColor, [
        teamColor(away, AppColors.primaryStrong),
        if (colorFromHex(away.secondaryColor) != null) colorFromHex(away.secondaryColor)!,
        AppColors.primary,
        AppColors.primaryDark,
      ]),
    );
  }

  /// Cores parecidas demais (distância RGB) não separam as duas metades.
  static bool similar(Color a, Color b) {
    double c(double v) => v * 255;
    final dr = c(a.r) - c(b.r), dg = c(a.g) - c(b.g), db = c(a.b) - c(b.b);
    return dr * dr + dg * dg + db * db < 90 * 90;
  }

  /// Cor do visitante: a 1ª das [options] (principal, secundária, marca...)
  /// que se distingue da casa; nenhuma, a principal mesmo.
  static Color contrastingAway(Color home, List<Color> options) =>
      options.firstWhere((c) => !similar(home, c), orElse: () => options.first);

  Color sideColor(ArtSide side) => side == ArtSide.home ? home : away;
}
