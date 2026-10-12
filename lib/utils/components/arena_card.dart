import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Superfície padrão dos cards de conteúdo: branca, raio 20, sombra suave e
/// ripple respeitando o raio.
class ArenaCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry margin;

  const ArenaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin = const EdgeInsets.only(bottom: AppSizes.s14),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4))
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: padding == null ? child : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}
