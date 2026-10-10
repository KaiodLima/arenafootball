import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_carousel.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Detalhes de uma notícia: álbum (ou capa), título, texto e link.
class NewsDetailsPage extends StatelessWidget {
  final NewsDTO news;

  const NewsDetailsPage({super.key, required this.news});

  Future<void> _openLink() async {
    final uri = Uri.tryParse(news.link);
    if (uri != null) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            if (news.images.isNotEmpty)
              ArenaCarouselImages(images: news.images)
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
                child: Container(
                  height: size.height * 0.75,
                  width: size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        news.imageUrl.isNotEmpty ? news.imageUrl : newsPlaceholderImageUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s20)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
              child: AutoSizeText(
                news.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppSizes.s24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PTSans',
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
              child: AutoSizeText(
                news.description,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: AppSizes.s18, color: AppColors.white, fontFamily: 'PTSans'),
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            if (news.link.isNotEmpty)
              InkWell(
                onTap: _openLink,
                child: Container(
                  height: AppSizes.s50,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(AppSizes.s20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link, color: AppColors.white),
                      const SizedBox(width: AppSizes.s4),
                      Text(
                        l10n.newsMoreInfo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(decoration: TextDecoration.underline, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.s24),
          ],
        ),
      ),
    );
  }
}
