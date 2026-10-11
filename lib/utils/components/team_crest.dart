import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Escudo de um time num círculo; sem [imageUrl], o ícone de escudo.
class TeamCrest extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const TeamCrest({super.key, required this.imageUrl, this.size = AppSizes.s32});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.shield_outlined, color: AppColors.textSecondary, size: size * 0.55);
    final url = imageUrl ?? '';
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: ClipOval(
        child: url.isEmpty
            ? Center(child: fallback)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(child: fallback),
                errorWidget: (_, __, ___) => Center(child: fallback),
              ),
      ),
    );
  }
}
