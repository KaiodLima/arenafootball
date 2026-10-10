import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Item redondo do carrossel de destaques.
class HighlightAvatar extends StatelessWidget {
  final String imageUrl;

  const HighlightAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.20;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.s10),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s56)),
          border: Border.all(color: AppColors.primary, width: AppSizes.s2),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl.isNotEmpty ? imageUrl : newsPlaceholderImageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
