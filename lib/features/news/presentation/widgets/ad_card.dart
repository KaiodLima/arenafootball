import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Card de publicidade do feed. Sem imagem, mostra o texto "PUBLICIDADE".
class AdCard extends StatelessWidget {
  final NewsDTO news;

  const AdCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const radius = BorderRadius.all(Radius.circular(AppSizes.s24));
    final hasImage = news.imageUrl.isNotEmpty;

    return Container(
      height: size.height * 0.25,
      width: size.width,
      decoration: BoxDecoration(
        image: hasImage ? DecorationImage(image: CachedNetworkImageProvider(news.imageUrl), fit: BoxFit.cover) : null,
        border: Border.all(color: AppColors.white, width: AppSizes.s2),
        borderRadius: radius,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.whiteMuted, borderRadius: radius),
        child: hasImage
            ? null
            : Text(
                AppLocalizations.of(context).newsAdPlaceholder,
                style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s20, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
