import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Grade do álbum: fotos já salvas (URL) e novas (arquivo), cada uma com "x"
/// para remover, e o quadrado "+" para adicionar.
class NewsAlbumGrid extends StatelessWidget {
  final List<String> savedUrls;
  final List<File> newFiles;
  final ValueChanged<String> onRemoveSaved;
  final ValueChanged<int> onRemoveNew;
  final VoidCallback onAdd;

  const NewsAlbumGrid({
    super.key,
    required this.savedUrls,
    required this.newFiles,
    required this.onRemoveSaved,
    required this.onRemoveNew,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.s12);

    final tiles = <Widget>[
      for (final url in savedUrls)
        _Photo(
          image: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          onRemove: () => onRemoveSaved(url),
        ),
      for (var i = 0; i < newFiles.length; i++)
        _Photo(image: Image.file(newFiles[i], fit: BoxFit.cover), onRemove: () => onRemoveNew(i)),
      Material(
        color: AppColors.primarySoft,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onAdd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryDark),
              const SizedBox(height: AppSizes.s4),
              Text(l10n.newsAlbumAdd,
                  style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12)),
            ],
          ),
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: AppSizes.s8,
      crossAxisSpacing: AppSizes.s8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

class _Photo extends StatelessWidget {
  final Widget image;
  final VoidCallback onRemove;

  const _Photo({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(AppSizes.s12), child: image),
        Positioned(
          top: AppSizes.s4,
          right: AppSizes.s4,
          child: Material(
            color: AppColors.black.withValues(alpha: 0.55),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Tooltip(
                message: l10n.commonDelete,
                child: const Padding(
                  padding: EdgeInsets.all(AppSizes.s4),
                  child: Icon(Icons.close_rounded, size: AppSizes.s16, color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
