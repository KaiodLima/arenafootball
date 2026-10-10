import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/picked_image_field.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Escolha da nova foto do jogador (câmera/galeria + prévia). Devolve o
/// arquivo escolhido ao tocar em "Salvar", ou nulo em "Voltar".
class PlayerPhotoDialog extends StatefulWidget {
  const PlayerPhotoDialog({super.key});

  static Future<File?> show(BuildContext context) =>
      showDialog<File>(context: context, builder: (_) => const PlayerPhotoDialog());

  @override
  State<PlayerPhotoDialog> createState() => _PlayerPhotoDialogState();
}

class _PlayerPhotoDialogState extends State<PlayerPhotoDialog> {
  File? _file;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      content: SingleChildScrollView(
        child: PickedImageField(file: _file, onPicked: (file) => setState(() => _file = file)),
      ),
      actions: [
        if (_file != null)
          Row(
            children: [
              Expanded(
                child: ArenaButton.outlined(title: l10n.playersPhotoBack, function: () => Navigator.pop(context)),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: ArenaButton.primary(title: l10n.playersPhotoSave, function: () => Navigator.pop(context, _file)),
              ),
            ],
          ),
      ],
    );
  }
}
