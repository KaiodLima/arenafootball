import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';

/// Confirmação de rejeição com motivo opcional, no modal padrão do app
/// ([showArenaConfirm]). Devolve o motivo (pode ser vazio) ou `null` se
/// cancelar ou fechar.
Future<String?> showReasonDialog(BuildContext context, {required String title, required String confirmLabel}) async {
  final l10n = AppLocalizations.of(context);
  var reason = '';
  final confirmed = await showArenaConfirm(
    context,
    title: title,
    message: l10n.rejectReasonMessage,
    icon: Icons.block_rounded,
    tone: ArenaAlertTone.danger,
    confirmLabel: confirmLabel,
    content: _ReasonField(onChanged: (value) => reason = value),
  );
  return confirmed ? reason.trim() : null;
}

/// Campo do motivo (dono do próprio controller: o modal fecha animando).
class _ReasonField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _ReasonField({required this.onChanged});

  @override
  State<_ReasonField> createState() => _ReasonFieldState();
}

class _ReasonFieldState extends State<_ReasonField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLength: 200,
      minLines: 1,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: arenaInputDecoration(label: l10n.playerRequestsRejectReason),
    );
  }
}
