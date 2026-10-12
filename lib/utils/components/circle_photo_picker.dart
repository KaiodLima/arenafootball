import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Foto em círculo (escudo do time, foto do jogador). Vazio: borda
/// tracejada e [addLabel]; tocar pergunta câmera/galeria. Com foto: "Trocar"
/// e "Remover" embaixo.
class CirclePhotoPicker extends StatelessWidget {
  final File? file;

  /// Foto já salva (edição), mostrada enquanto não há [file].
  final String currentUrl;
  final String addLabel;
  final IconData emptyIcon;
  final double size;
  final ValueChanged<File> onPicked;
  final VoidCallback onRemove;

  const CirclePhotoPicker({
    super.key,
    required this.file,
    this.currentUrl = '',
    required this.addLabel,
    required this.onPicked,
    required this.onRemove,
    this.emptyIcon = Icons.add_photo_alternate_outlined,
    this.size = AppSizes.s120,
  });

  Future<void> _pick(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 90, maxWidth: 1024);
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = file != null || currentUrl.isNotEmpty;

    return Column(
      children: [
        Material(
          color: hasImage ? AppColors.background : AppColors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pick(context),
            child: SizedBox(
              width: size,
              height: size,
              child: hasImage
                  ? Padding(
                      padding: const EdgeInsets.all(AppSizes.s8),
                      child: ClipOval(
                        child: file != null
                            ? Image.file(file!, fit: BoxFit.cover)
                            : CachedNetworkImage(imageUrl: currentUrl, fit: BoxFit.cover),
                      ),
                    )
                  : CustomPaint(
                      painter: _DashedCirclePainter(),
                      child: Center(
                        child: Icon(emptyIcon, color: AppColors.primaryDark, size: AppSizes.s36),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s10),
        if (!hasImage)
          Text(addLabel, style: AppTypography.label(color: AppColors.primaryDark))
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => _pick(context),
                icon: const Icon(Icons.edit_outlined, size: AppSizes.s18),
                label: Text(l10n.newsCoverChange),
              ),
              TextButton.icon(
                onPressed: onRemove,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.s18),
                label: Text(l10n.newsCoverRemove),
              ),
            ],
          ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final radius = size.width / 2 - 1;
    final center = Offset(size.width / 2, size.height / 2);
    const segments = 28;
    const sweep = 2 * math.pi / segments;
    for (var i = 0; i < segments; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * sweep, sweep * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
