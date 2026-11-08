import 'package:flutter/painting.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Cores resolvidas de uma paleta: fundo ([base] → [deep]), destaque
/// principal ([accent], o "dourado") e o secundário ([accent2], LED/detalhes).
class ArtColors {
  final Color base;
  final Color deep;
  final Color accent;
  final Color accent2;

  const ArtColors({required this.base, required this.deep, required this.accent, required this.accent2});
}

/// Paletas que o usuário escolhe nas artes de divulgação. "Times" usa as
/// cores dos dois times (padrão); as outras são fixas. Escudos e faixas de
/// cada time continuam na cor do time em qualquer paleta.
enum ArtPalette {
  teams,
  arena,
  night,
  crimson,
  ocean,
  graphite;

  ArtColors resolve(ArtTheme theme) => switch (this) {
        ArtPalette.teams => ArtColors(
            base: Color.lerp(theme.home, AppColors.black, 0.3)!,
            deep: Color.lerp(theme.away, AppColors.black, 0.6)!,
            accent: AppColors.gold,
            accent2: const Color(0xFF46E86A),
          ),
        ArtPalette.arena => const ArtColors(
            base: AppColors.primaryStrong,
            deep: Color(0xFF0A1F0C),
            accent: AppColors.gold,
            accent2: Color(0xFF46E86A),
          ),
        ArtPalette.night => const ArtColors(
            base: Color(0xFF1C2F6B),
            deep: Color(0xFF080F2A),
            accent: AppColors.gold,
            accent2: Color(0xFF7FB2FF),
          ),
        ArtPalette.crimson => const ArtColors(
            base: Color(0xFFA51C24),
            deep: Color(0xFF2E070A),
            accent: Color(0xFFFFD54F),
            accent2: Color(0xFFFFFFFF),
          ),
        ArtPalette.ocean => const ArtColors(
            base: Color(0xFF0E6BA0),
            deep: Color(0xFF04253A),
            accent: Color(0xFF4DE1F0),
            accent2: Color(0xFFFFFFFF),
          ),
        ArtPalette.graphite => const ArtColors(
            base: Color(0xFF353C44),
            deep: Color(0xFF0B0E11),
            accent: Color(0xFFFFB300),
            accent2: Color(0xFF46E86A),
          ),
      };
}
