import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Par de botões "Tirar foto" / "Galeria" dos formulários com imagem.
class ImageSourceButtons extends StatelessWidget {
  final String cameraLabel;
  final String galleryLabel;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ImageSourceButtons({
    super.key,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: ArenaButton.primary(title: cameraLabel, function: onCamera)),
        const SizedBox(width: AppSizes.s8),
        Expanded(child: ArenaButton.outlined(title: galleryLabel, function: onGallery)),
      ],
    );
  }
}
