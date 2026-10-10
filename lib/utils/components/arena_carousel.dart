import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Carrossel de imagens da rede (fotos do álbum de uma notícia).
class ArenaCarouselImages extends StatelessWidget {
  final List<String> images;
  final double? height;
  final bool? autoPlay;
  final bool? infiniteScroll;

  const ArenaCarouselImages({
    super.key,
    required this.images,
    this.height,
    this.autoPlay,
    this.infiniteScroll,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CarouselSlider(
      options: CarouselOptions(
        height: height ?? size.height * 0.55,
        autoPlay: autoPlay ?? images.length > 1,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: infiniteScroll ?? images.length > 1,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: images.map((url) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(image: CachedNetworkImageProvider(url), fit: BoxFit.cover),
              borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s20)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
