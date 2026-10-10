import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Imagem usada quando a notícia não tem foto.
const String newsPlaceholderImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/arenasoccerflutter.appspot.com/o/noticias%2Fic_arena.png?alt=media&token=6f3cd481-7199-489a-91b5-a8527e919710';

/// Card de notícia comum: imagem de fundo com título e resumo por cima.
class NewsCard extends StatelessWidget {
  final NewsDTO news;

  const NewsCard({super.key, required this.news});

  static const int _titleMaxLength = 40;
  static const int _titleCutAt = 30;
  static const int _descriptionMaxLength = 120;
  static const int _descriptionCutAt = 110;

  static String _ellipsis(String text, int maxLength, int cutAt) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, cutAt)}...';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height * 0.55;
    const radius = BorderRadius.all(Radius.circular(AppSizes.s24));

    return Stack(
      children: [
        Container(
          height: height,
          width: size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(news.imageUrl.isNotEmpty ? news.imageUrl : newsPlaceholderImageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: radius,
          ),
        ),
        Container(
          height: height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.black, AppColors.black.withAlpha(0)],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
            borderRadius: radius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: AutoSizeText(
                  _ellipsis(news.title, _titleMaxLength, _titleCutAt),
                  style: const TextStyle(
                    fontSize: AppSizes.s24,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PTSans',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: AutoSizeText(
                  _ellipsis(news.description, _descriptionMaxLength, _descriptionCutAt),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: AppSizes.s18, color: AppColors.white, fontFamily: 'PTSans'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
