import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Item do carrossel de destaques no formato "stories": círculo com anel em
/// gradiente e o título embaixo. Sem [imageUrl] (null), desenha o esqueleto
/// de carregamento.
class HighlightAvatar extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final VoidCallback? onTap;

  const HighlightAvatar({super.key, required this.imageUrl, required this.title, this.onTap});

  const HighlightAvatar.skeleton({super.key})
      : imageUrl = null,
        title = '',
        onTap = null;

  @override
  Widget build(BuildContext context) {
    final isSkeleton = imageUrl == null;
    const ringWidth = AppSizes.s2 + 1;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.storySize + AppSizes.s12,
        child: Column(
          children: [
            Container(
              width: AppSizes.storySize,
              height: AppSizes.storySize,
              padding: const EdgeInsets.all(ringWidth),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSkeleton ? AppColors.greyLight : null,
                gradient: isSkeleton
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.gold, AppColors.primary, AppColors.primaryDark],
                      ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.s2),
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: ClipOval(
                  child: isSkeleton
                      ? const ColoredBox(color: AppColors.greyLight)
                      : CachedNetworkImage(
                          imageUrl: imageUrl!.isNotEmpty ? imageUrl! : newsPlaceholderImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ColoredBox(color: AppColors.greyLight),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s6),
            if (isSkeleton)
              Container(
                width: AppSizes.s40,
                height: AppSizes.s8,
                decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(AppSizes.s4)),
              )
            else
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
              ),
          ],
        ),
      ),
    );
  }
}
