import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Placar digitado no diálogo. Campo vazio = manter o gol atual (regra no
/// UseCase).
typedef ScoreInput = ({String homeGoals, String awayGoals});

/// Diálogo "Alterar Placar". Devolve o placar digitado ou `null` se cancelado.
Future<ScoreInput?> showEditScoreDialog(BuildContext context) {
  return showDialog<ScoreInput>(context: context, builder: (_) => const _EditScoreDialog());
}

class _EditScoreDialog extends StatefulWidget {
  const _EditScoreDialog();

  @override
  State<_EditScoreDialog> createState() => _EditScoreDialogState();
}

class _EditScoreDialogState extends State<_EditScoreDialog> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Center(child: Text(l10n.matchesEditScoreTitle, style: const TextStyle(fontSize: AppSizes.s24))),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoalField(controller: _homeController, label: l10n.matchesHomeLabel),
          const SizedBox(width: AppSizes.s16),
          Text(l10n.matchesVersus, style: const TextStyle(fontSize: AppSizes.s24, color: AppColors.primary)),
          const SizedBox(width: AppSizes.s16),
          _GoalField(controller: _awayController, label: l10n.matchesAwayLabel),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ArenaButton.outlined(title: l10n.commonCancel, function: () => Navigator.pop(context)),
            ),
            const SizedBox(width: AppSizes.s8),
            Expanded(
              child: ArenaButton.primary(
                title: l10n.commonSave,
                function: () => Navigator.pop<ScoreInput>(
                  context,
                  (homeGoals: _homeController.text, awayGoals: _awayController.text),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _GoalField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.s80,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: AppSizes.s22, color: AppColors.black),
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: const TextStyle(color: AppColors.black, fontSize: AppSizes.s18),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
        ),
      ),
    );
  }
}
