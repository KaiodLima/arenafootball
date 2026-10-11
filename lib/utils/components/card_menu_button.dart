import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Uma ação do [CardMenuButton].
class CardMenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  /// Ação destrutiva (ex.: excluir) aparece em vermelho.
  final bool destructive;

  const CardMenuAction({required this.icon, required this.label, required this.onSelected, this.destructive = false});
}

/// Menu ⋮ das ações de um card (ações do admin). Com [onImage], o botão fica
/// num círculo escuro translúcido para aparecer sobre fotos.
class CardMenuButton extends StatelessWidget {
  final List<CardMenuAction> actions;
  final bool onImage;

  const CardMenuButton({super.key, required this.actions, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    final button = PopupMenuButton<int>(
      tooltip: AppLocalizations.of(context).commonMoreActions,
      icon: Icon(Icons.more_vert_rounded, color: onImage ? AppColors.white : AppColors.textSecondary),
      onSelected: (index) => actions[index].onSelected(),
      itemBuilder: (_) => [
        for (var i = 0; i < actions.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Icon(
                  actions[i].icon,
                  size: AppSizes.s20,
                  color: actions[i].destructive ? AppColors.danger : AppColors.textPrimary,
                ),
                const SizedBox(width: AppSizes.s12),
                Text(
                  actions[i].label,
                  style: TextStyle(color: actions[i].destructive ? AppColors.danger : AppColors.textPrimary),
                ),
              ],
            ),
          ),
      ],
    );

    if (!onImage) return button;
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
      child: button,
    );
  }
}
