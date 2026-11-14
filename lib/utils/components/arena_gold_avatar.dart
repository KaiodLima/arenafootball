import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Foto num anel dourado com aro branco (cabeçalho do drawer, "Meu perfil").
/// Sem [image], o ícone de pessoa; [busy] mostra um progresso sobre a foto.
class ArenaGoldAvatar extends StatelessWidget {
  final String? image;
  final double radius;
  final bool busy;

  const ArenaGoldAvatar({super.key, this.image, this.radius = AppSizes.s30, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final url = image?.trim();
    final hasImage = url != null && url.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark],
        ),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: AppSizes.s10)],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s2),
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.background,
          backgroundImage: hasImage ? CachedNetworkImageProvider(url) : null,
          child: busy
              ? const CircularProgressIndicator(color: AppColors.primary)
              : hasImage
                  ? null
                  : Icon(Icons.person_rounded, color: AppColors.textSecondary, size: radius),
        ),
      ),
    );
  }
}
