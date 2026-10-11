import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Imagem usada quando a notícia não tem foto.
const String newsPlaceholderImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710';

/// Card de notícia: imagem 16:9, título, resumo e há quanto tempo foi publicada.
/// [trailing] fica sobre a imagem, no canto (ex.: menu do admin).
class NewsCard extends StatelessWidget {
  final NewsDTO news;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NewsCard({super.key, required this.news, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl.isNotEmpty ? news.imageUrl : newsPlaceholderImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ColoredBox(color: AppColors.greyLight),
                  errorWidget: (_, __, ___) => const ColoredBox(
                    color: AppColors.greyLight,
                    child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                  ),
                ),
              ),
              if (trailing != null) Positioned(top: AppSizes.s8, right: AppSizes.s8, child: trailing!),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, AppSizes.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s18 - 1),
                ),
                if (news.description.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s6),
                  Text(
                    news.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle(),
                  ),
                ],
                if (news.date != null) ...[
                  const SizedBox(height: AppSizes.s10),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: AppSizes.s14, color: AppColors.textSecondary),
                      const SizedBox(width: AppSizes.s4),
                      Text(
                        RelativeTime.format(news.date!, l10n),
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
