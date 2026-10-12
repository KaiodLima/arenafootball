import 'dart:io';

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

  /// Foto escolhida e ainda não enviada (prévia do cadastro).
  final File? imageFile;

  /// Liga o círculo à foto grande da tela de detalhes.
  final Object? heroTag;

  const HighlightAvatar({
    super.key,
    required this.imageUrl,
    required this.title,
    this.onTap,
    this.imageFile,
    this.heroTag,
  });

  const HighlightAvatar.skeleton({super.key})
      : imageUrl = null,
        title = '',
        onTap = null,
        imageFile = null,
        heroTag = null;

  Widget _withHero(Widget child) => heroTag == null ? child : Hero(tag: heroTag!, child: child);

  @override
  Widget build(BuildContext context) {
    final isSkeleton = imageUrl == null;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.storySize + AppSizes.s12,
        child: Column(
          children: [
            _withHero(
              HighlightRing(imageUrl: imageUrl, imageFile: imageFile, size: AppSizes.storySize),
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

/// Tag do Hero entre o carrossel e a tela do destaque.
String highlightHeroTag(String id) => 'highlight-$id';

/// Círculo com anel em gradiente (estilo "stories"). [imageUrl] nulo =
/// esqueleto; [imageFile] = foto local ainda não enviada.
class HighlightRing extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double size;

  const HighlightRing({super.key, required this.imageUrl, this.imageFile, this.size = AppSizes.storySize});

  @override
  Widget build(BuildContext context) {
    final isSkeleton = imageUrl == null;
    final ringWidth = size * 0.05;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
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
        padding: EdgeInsets.all(ringWidth * 0.66),
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: ClipOval(
          child: isSkeleton
              ? const ColoredBox(color: AppColors.greyLight)
              : imageFile != null
                  ? Image.file(imageFile!, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: imageUrl!.isNotEmpty ? imageUrl! : newsPlaceholderImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(color: AppColors.greyLight),
                    ),
        ),
      ),
    );
  }
}
