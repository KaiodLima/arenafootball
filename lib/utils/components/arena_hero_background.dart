import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';

/// Fundo da marca: gradiente verde-escuro, um brilho suave no canto e a
/// ilustração da bola na rede como marca d'água. Usado no splash, no topo das
/// telas de entrada, no header da home e no drawer.
///
/// Funciona com altura fixa (ocupa tudo) ou sem limite de altura (dentro de
/// uma `Column`): aí o tamanho vem do [child].
class ArenaHeroBackground extends StatelessWidget {
  final Widget child;

  /// Tamanho da marca d'água em relação à altura disponível (ou à largura,
  /// quando a altura não tem limite).
  final double watermarkFactor;

  const ArenaHeroBackground({super.key, required this.child, this.watermarkFactor = 0.85});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedHeight = constraints.hasBoundedHeight;
        final base = boundedHeight ? constraints.maxHeight : constraints.maxWidth * 0.5;
        final watermarkHeight = base * watermarkFactor;
        final glow = constraints.maxWidth * 0.8;

        // Sempre na largura toda (pais como a Column do drawer não esticam o filho).
        return SizedBox(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          child: ClipRect(
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
                    left: -glow * 0.4,
                    top: -glow * 0.4,
                    child: Container(
                      width: glow,
                      height: glow,
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
                  // O conteúdo define o tamanho do Stack; com altura fixa, ocupa tudo.
                  if (boundedHeight) Positioned.fill(child: child) else child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
