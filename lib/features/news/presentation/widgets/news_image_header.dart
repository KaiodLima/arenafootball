import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/photo_gallery_page.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Imagem do topo do detalhe da notícia: a capa (com Hero vindo do card) ou o
/// álbum deslizante com contador e pontos. Tocar abre a galeria em tela cheia.
class NewsImageHeader extends StatefulWidget {
  final NewsDTO news;

  const NewsImageHeader({super.key, required this.news});

  @override
  State<NewsImageHeader> createState() => _NewsImageHeaderState();
}

class _NewsImageHeaderState extends State<NewsImageHeader> {
  int _current = 0;

  /// Álbum quando há mais de uma foto; senão, só a capa.
  List<String> get _images {
    final album = widget.news.images.where((url) => url.isNotEmpty).toList();
    if (album.length > 1) return album;
    final cover = widget.news.imageUrl.isNotEmpty ? widget.news.imageUrl : (album.isNotEmpty ? album.first : '');
    return [cover.isNotEmpty ? cover : newsPlaceholderImageUrl];
  }

  void _openGallery(List<String> images) {
    PhotoGalleryPage.open(
      context,
      images: images,
      initialIndex: _current,
      heroTag: _current == 0 ? newsImageHeroTag(widget.news.id) : null,
    );
  }

  Widget _image(String url) => CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => const ColoredBox(color: AppColors.greyLight),
        errorWidget: (_, __, ___) => const ColoredBox(
          color: AppColors.greyLight,
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final images = _images;
    final isAlbum = images.length > 1;

    return GestureDetector(
      onTap: () => _openGallery(images),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isAlbum)
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (_, index) => index == 0
                  ? Hero(tag: newsImageHeroTag(widget.news.id), child: _image(images[index]))
                  : _image(images[index]),
            )
          else
            Hero(tag: newsImageHeroTag(widget.news.id), child: _image(images.first)),
          // Escurece o topo (botões legíveis) e a base (transição para a folha).
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.25, 0.75, 1],
                  colors: [
                    AppColors.black.withValues(alpha: 0.45),
                    AppColors.transparent,
                    AppColors.transparent,
                    AppColors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          // Borda arredondada da folha de conteúdo, desenhada aqui porque a barra
          // fixa do CustomScrollView fica por cima dos slivers seguintes.
          const Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: AppSizes.s24 + 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
              ),
            ),
          ),
          if (isAlbum)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSizes.s40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: AppSizes.s2 + 1),
                      width: i == _current ? AppSizes.s18 : AppSizes.s6,
                      height: AppSizes.s6,
                      decoration: BoxDecoration(
                        color: i == _current ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSizes.s4),
                      ),
                    ),
                ],
              ),
            ),
          if (isAlbum)
            Positioned(
              right: AppSizes.s16,
              bottom: AppSizes.s36,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppSizes.s12),
                ),
                child: Text(
                  l10n.galleryCounter(_current + 1, images.length),
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
