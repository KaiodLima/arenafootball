import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Atleta novo informado na folha rápida.
typedef QuickPlayer = ({String name, String position, File? photo});

/// Cadastro rápido de atleta (súmula e elenco da competição do organizador):
/// foto opcional, nome (3+ letras) e posição opcional.
Future<QuickPlayer?> showQuickPlayerSheet(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
}) =>
    showModalBottomSheet<QuickPlayer>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QuickPlayerSheet(title: title, hint: hint, confirmLabel: confirmLabel),
    );

class QuickPlayerSheet extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmLabel;

  const QuickPlayerSheet({super.key, required this.title, required this.hint, required this.confirmLabel});

  @override
  State<QuickPlayerSheet> createState() => QuickPlayerSheetState();
}

class QuickPlayerSheetState extends State<QuickPlayerSheet> {
  final _name = TextEditingController();
  PlayerPosition? _position;
  File? _photo;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _name.text.trim().length >= 3;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s20,
        0,
        AppSizes.s20,
        AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
            Text(widget.hint, style: AppTypography.subtitle()),
            const SizedBox(height: AppSizes.s16),
            Center(
              child: CirclePhotoPicker(
                file: _photo,
                addLabel: l10n.matchReportPhoto,
                emptyIcon: Icons.person_rounded,
                onPicked: (file) => setState(() => _photo = file),
                onRemove: () => setState(() => _photo = null),
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            ArenaTextField(
              controller: _name,
              labelText: l10n.matchReportPlayerName,
              icon: const Icon(Icons.badge_outlined),
              onChaged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSizes.s12),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final position in PlayerPosition.values)
                  ArenaChoiceChip(
                    label: playerPositionLabel(l10n, position),
                    selected: _position == position,
                    onTap: () => setState(() => _position = _position == position ? null : position),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: widget.confirmLabel,
              function: valid
                  ? () =>
                      Navigator.pop(context, (name: _name.text.trim(), position: _position?.key ?? '', photo: _photo))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
