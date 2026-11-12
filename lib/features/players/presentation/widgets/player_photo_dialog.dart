import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/image_source_buttons.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Troca da foto do atleta no modal padrão do app ([showArenaConfirm]):
/// prévia redonda (a foto atual do [player] ou a recém-escolhida) e os botões
/// Tirar foto / Galeria; Cancelar ou Salvar. Devolve o arquivo escolhido ao
/// salvar (nulo ao cancelar, fechar ou salvar sem escolher).
abstract final class PlayerPhotoDialog {
  static Future<File?> show(BuildContext context, {PlayerDTO? player}) async {
    final l10n = AppLocalizations.of(context);
    File? picked;
    final confirmed = await showArenaConfirm(
      context,
      header: l10n.playersPhotoHeader,
      title: l10n.playersPhotoTitle,
      message: l10n.playersPhotoMessage,
      icon: Icons.photo_camera_rounded,
      confirmLabel: l10n.playersPhotoSave,
      content: _PhotoPicker(player: player, onPicked: (file) => picked = file),
    );
    return confirmed ? picked : null;
  }
}

class _PhotoPicker extends StatefulWidget {
  final PlayerDTO? player;
  final ValueChanged<File> onPicked;

  const _PhotoPicker({required this.player, required this.onPicked});

  @override
  State<_PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<_PhotoPicker> {
  File? _file;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (picked == null || !mounted) return;
    final file = File(picked.path);
    setState(() => _file = file);
    widget.onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = widget.player ?? const PlayerDTO(name: '', team: '');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _file == null ? AppColors.greyLight : AppColors.primary, width: 2),
            ),
            child: PlayerAvatar(player: player, photoFile: _file, size: AppSizes.s120),
          ),
        ),
        const SizedBox(height: AppSizes.s16),
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
