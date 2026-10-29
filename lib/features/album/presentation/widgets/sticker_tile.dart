import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Um espaço do álbum: colada mostra a foto com moldura, número e nome; a que
/// falta, a silhueta com o número. [count] > 1 mostra "×N" (repetidas).
class StickerTile extends StatelessWidget {
  final StickerDTO sticker;
  final int count;

  /// Cor da moldura (a principal do time; sem cor, o verde do app).
  final Color frame;
  final VoidCallback? onTap;

  const StickerTile({super.key, required this.sticker, required this.count, required this.frame, this.onTap});

  bool get _collected => count > 0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.s10);
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: _collected ? AppColors.surface : AppColors.background,
                  border: Border.all(
                    color: _collected ? frame : AppColors.greyLight,
                    width: _collected ? AppSizes.s2 : AppSizes.s1,
                  ),
                  boxShadow: _collected
                      ? [BoxShadow(color: frame.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: _collected ? _Front(sticker: sticker, frame: frame) : _Empty(sticker: sticker),
                ),
              ),
            ),
            if (count > 1)
              Positioned(
                top: -AppSizes.s6,
                right: -AppSizes.s6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s2),
                  decoration:
                      BoxDecoration(color: AppColors.googleYellow, borderRadius: BorderRadius.circular(AppSizes.s10)),
                  child: Text('×$count',
                      style: AppTypography.label(color: AppColors.black).copyWith(fontSize: AppSizes.s10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Front extends StatelessWidget {
  final StickerDTO sticker;
  final Color frame;

  const _Front({required this.sticker, required this.frame});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: sticker.imageUrl.isEmpty
              ? ColoredBox(
                  color: frame.withValues(alpha: 0.12),
                  child: Icon(
                    sticker.kind == StickerKind.crest ? Icons.shield_rounded : Icons.person_rounded,
                    color: frame,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: sticker.imageUrl,
                  fit: sticker.kind == StickerKind.crest ? BoxFit.contain : BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  errorWidget: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: frame),
                ),
        ),
        Container(
          color: frame,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4, vertical: AppSizes.s2),
          child: Text(
            '${sticker.number} · ${sticker.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final StickerDTO sticker;

  const _Empty({required this.sticker});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          sticker.kind == StickerKind.crest ? Icons.shield_outlined : Icons.person_outline_rounded,
          color: AppColors.greyLight,
          size: AppSizes.s32,
        ),
        const SizedBox(height: AppSizes.s4),
        Text(
          '${sticker.number}',
          style: AppTypography.title(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s18),
        ),
      ],
    );
  }
}
