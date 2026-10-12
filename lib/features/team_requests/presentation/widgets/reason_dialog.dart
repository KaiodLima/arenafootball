import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Confirmação de rejeição com motivo opcional. Devolve o motivo (pode ser
/// vazio) ou `null` se cancelar.
Future<String?> showReasonDialog(BuildContext context, {required String title, required String confirmLabel}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(title: title, confirmLabel: confirmLabel),
  );
}

class _ReasonDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;

  const _ReasonDialog({required this.title, required this.confirmLabel});

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 200,
        minLines: 1,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: arenaInputDecoration(label: l10n.playerRequestsRejectReason),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}
