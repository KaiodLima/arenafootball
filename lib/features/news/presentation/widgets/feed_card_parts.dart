import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Peças dos cards automáticos do feed (resultado, votação encerrada), na
/// linguagem esportiva: fontes empacotadas, selo dourado, escudos em quadros.
abstract final class FeedCardFonts {
  static const String display = 'Anton';
  static const String condensed = 'BarlowCondensed';
}

/// Fundo verde da marca dos cards automáticos.
const feedCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryDark, AppColors.primaryStrong],
);

/// Selo dourado num retângulo escuro com o canto cortado ("FIM DE JOGO").
class FeedCutBadge extends StatelessWidget {
  final String label;
  final IconData? icon;

  const FeedCutBadge({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CutCornerClipper(),
      child: Container(
        color: AppColors.black.withValues(alpha: 0.32),
        padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s4, AppSizes.s14, AppSizes.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.s14, color: AppColors.gold),
              const SizedBox(width: AppSizes.s4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontFamily: FeedCardFonts.display,
                fontSize: AppSizes.s14,
                letterSpacing: 1.2,
                height: 1.3,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper();

  @override
  Path getClip(Size size) {
    final cut = size.height * 0.5;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Escudo num quadro branco arredondado, com sombra.
class FeedCrestBox extends StatelessWidget {
  final String crest;
  final double size;

  const FeedCrestBox({super.key, required this.crest, this.size = AppSizes.s56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: AppSizes.s8,
            offset: const Offset(0, AppSizes.s2),
          ),
        ],
      ),
      child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: size * 0.78),
    );
  }
}

/// Ação do card ("Ver partida", "Ver resultado") numa pílula translúcida.
class FeedActionPill extends StatelessWidget {
  final String label;
  final IconData? icon;

  const FeedActionPill({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? AppSizes.s14 : AppSizes.s10, AppSizes.s6, AppSizes.s8, AppSizes.s6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.s20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.gold, size: AppSizes.s18),
            const SizedBox(width: AppSizes.s6),
          ],
          Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: AppSizes.s20),
        ],
      ),
    );
  }
}
