import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card da notícia para compartilhar: a capa inteira no alto (sem corte, com
/// fundo desfocado; sem foto, o verde do app com a logo), região · data, o
/// título e o rodapé chamando para o app.
class NewsShareCard extends StatelessWidget {
  final NewsDTO news;

  const NewsShareCard({super.key, required this.news});

  /// Capa da notícia; sem ela, a primeira foto do álbum.
  String get _cover {
    if (news.imageUrl.isNotEmpty) return news.imageUrl;
    return news.images.firstWhere((url) => url.isNotEmpty, orElse: () => '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final kicker = [
      if (news.region.isNotEmpty) news.region,
      if (news.date != null) RelativeTime.format(news.date!, l10n),
    ].join('  ·  ');
    final cover = _cover;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ColoredBox(
            color: AppColors.surface,
            // O texto ocupa só o que precisa (sem vazio com título curto) e a
            // capa fica com o resto; o texto nunca passa de 45% da altura.
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: cover.isEmpty ? const _CoverPlaceholder() : _FullCover(url: cover),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.45),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kicker.isNotEmpty)
                            Text(
                              kicker.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.primaryStrong).copyWith(
                                fontSize: AppSizes.s10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          const SizedBox(height: AppSizes.s6),
                          Flexible(
                            child: Text(
                              news.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.display().copyWith(fontSize: AppSizes.s20, height: 1.2),
                            ),
                          ),
                          const SizedBox(height: AppSizes.s8),
                          const Divider(height: AppSizes.s16, color: AppColors.greyLight),
                          Row(
                            children: [
                              Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s20),
                              const SizedBox(width: AppSizes.s8),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.newsShareCardFooter,
                                    maxLines: 1,
                                    style: AppTypography.label(color: AppColors.primaryDark)
                                        .copyWith(fontSize: AppSizes.s12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Capa inteira (a arte pode ter informação escrita): a imagem sem corte por
/// cima e, preenchendo a sobra, ela mesma ampliada, desfocada e escurecida.
class _FullCover extends StatelessWidget {
  final String url;

  const _FullCover({required this.url});

  CachedNetworkImage _image(BoxFit fit, {bool placeholder = true}) => CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        // Sem fade: o "print" pode sair no meio da animação.
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => placeholder ? const _CoverPlaceholder() : const SizedBox.shrink(),
        errorWidget: (_, __, ___) => placeholder ? const _CoverPlaceholder() : const SizedBox.shrink(),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.primaryDark),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
          child: _image(BoxFit.cover, placeholder: false),
        ),
        ColoredBox(color: AppColors.black.withValues(alpha: 0.35)),
        _image(BoxFit.contain),
      ],
    );
  }
}

/// Sem foto (ou carregando): o verde do app com a logo no centro.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryMedium, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.4,
          child: Image.asset('lib/assets/images/ic_logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
