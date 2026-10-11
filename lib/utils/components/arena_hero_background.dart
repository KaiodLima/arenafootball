import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';

/// Fundo da marca: gradiente verde-escuro, um brilho suave no canto e a
/// ilustração da bola na rede como marca d'água. Usado no splash e no topo
/// das telas de entrada.
class ArenaHeroBackground extends StatelessWidget {
  final Widget child;

  /// Altura da marca d'água em relação à altura disponível.
  final double watermarkFactor;

  const ArenaHeroBackground({super.key, required this.child, this.watermarkFactor = 0.85});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final watermarkHeight = constraints.maxHeight * watermarkFactor;
        return ClipRect(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primaryMedium],
              ),
            ),
            child: Stack(
              children: [
                // Brilho verde no canto superior esquerdo, para dar profundidade.
                Positioned(
                  left: -constraints.maxWidth * 0.3,
                  top: -constraints.maxWidth * 0.3,
                  child: Container(
                    width: constraints.maxWidth * 0.8,
                    height: constraints.maxWidth * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.35), AppColors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -watermarkHeight * 0.25,
                  bottom: -watermarkHeight * 0.1,
                  child: Opacity(
                    opacity: 0.08,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      child: Image.asset(AppImages.ballInNet, height: watermarkHeight),
                    ),
                  ),
                ),
                Positioned.fill(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
