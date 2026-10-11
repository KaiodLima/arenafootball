import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de publicidade do feed: imagem 2:1 com o selo "Publicidade".
class AdCard extends StatelessWidget {
  final NewsDTO news;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AdCard({super.key, required this.news, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (news.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: news.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: AppColors.greyLight),
              )
            else
              ColoredBox(
                color: AppColors.background,
                child: Center(
                  child: Text(l10n.newsAdPlaceholder, style: AppTypography.title(color: AppColors.textSecondary)),
                ),
              ),
            Positioned(
              top: AppSizes.s10,
              left: AppSizes.s10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppSizes.s8),
                ),
                child: Text(
                  l10n.newsAdLabel,
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ),
            if (trailing != null) Positioned(top: AppSizes.s8, right: AppSizes.s8, child: trailing!),
          ],
        ),
      ),
    );
  }
}
