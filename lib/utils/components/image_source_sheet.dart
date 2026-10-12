import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Pergunta de onde vem a foto (câmera ou galeria). Nulo se o usuário fechar.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  Widget option(IconData icon, String label, ImageSource source) => ListTile(
        leading: Container(
          width: AppSizes.s40,
          height: AppSizes.s40,
          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.s20),
        ),
        title: Text(label),
        onTap: () => Navigator.pop(context, source),
      );

  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(Icons.photo_camera_outlined, l10n.commonTakePhoto, ImageSource.camera),
            option(Icons.photo_library_outlined, l10n.commonGallery, ImageSource.gallery),
          ],
        ),
      ),
    ),
  );
}
