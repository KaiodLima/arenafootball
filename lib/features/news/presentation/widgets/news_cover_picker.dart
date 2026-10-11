import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Capa da notícia em 16:9. Vazia, mostra o convite tracejado; tocar (ou
/// "Trocar") pergunta câmera/galeria. Com capa, "Remover" limpa.
class NewsCoverPicker extends StatelessWidget {
  final File? file;
  final String currentUrl;
  final ValueChanged<File> onPicked;
  final VoidCallback onRemove;

  const NewsCoverPicker({
    super.key,
    required this.file,
    required this.currentUrl,
    required this.onPicked,
    required this.onRemove,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = file != null || currentUrl.isNotEmpty;
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: hasImage ? AppColors.black : AppColors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _pick(context),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    if (file != null)
                      Image.file(file!, fit: BoxFit.cover)
                    else
                      CachedNetworkImage(imageUrl: currentUrl, fit: BoxFit.cover),
                    Positioned(
                      right: AppSizes.s10,
                      bottom: AppSizes.s10,
                      child: Row(
                        children: [
                          _OverlayButton(
                            icon: Icons.edit_outlined,
                            label: l10n.newsCoverChange,
                            onTap: () => _pick(context),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          _OverlayButton(
                              icon: Icons.delete_outline_rounded, label: l10n.newsCoverRemove, onTap: onRemove),
                        ],
                      ),
                    ),
                  ],
                )
              : CustomPaint(
                  painter: _DashedBorderPainter(radius: AppSizes.cardRadius),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSizes.s56,
                          height: AppSizes.s56,
                          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                          child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: AppSizes.s10),
                        Text(l10n.newsCoverAdd, style: AppTypography.label(color: AppColors.textPrimary)),
                        const SizedBox(height: AppSizes.s2),
                        Text(l10n.newsCoverHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OverlayButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.55),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSizes.s16, color: AppColors.white),
              const SizedBox(width: AppSizes.s4),
              Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borda tracejada arredondada da área vazia.
class _DashedBorderPainter extends CustomPainter {
  final double radius;

  _DashedBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(1);
    final path = Path()..addRRect(rect);
    const dash = 8.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.radius != radius;
}
