import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/image_source_buttons.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Prévia da imagem escolhida (arquivo novo ou URL atual) + botões
/// "Tirar foto" / "Galeria". Usado nos formulários de notícia, anúncio e
/// destaque.
class PickedImageField extends StatelessWidget {
  final File? file;
  final String? currentUrl;
  final ValueChanged<File> onPicked;

  const PickedImageField({super.key, required this.file, required this.onPicked, this.currentUrl});

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.of(context).size.height * 0.3;

    Widget? preview;
    if (file != null) {
      preview = Image.file(file!, height: height);
    } else if (currentUrl != null && currentUrl!.isNotEmpty) {
      preview = Image.network(currentUrl!, height: height);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null) Padding(padding: const EdgeInsets.all(AppSizes.s10), child: preview),
        ImageSourceButtons(
          cameraLabel: l10n.commonTakePhoto,
          galleryLabel: l10n.commonGallery,
          onCamera: () => _pick(ImageSource.camera),
          onGallery: () => _pick(ImageSource.gallery),
        ),
      ],
    );
  }
}
