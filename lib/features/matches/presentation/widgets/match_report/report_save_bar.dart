import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Barra de salvar flutuante (só com mudança): "3 mudanças", a chave de
/// publicar card de gol (com gol novo) e o botão Salvar.
class ReportSaveBar extends StatelessWidget {
  final int changes;
  final int newGoals;
  final bool publishCards;
  final bool saving;
  final ValueChanged<bool> onPublishCards;
  final VoidCallback onSave;

  const ReportSaveBar({
    super.key,
    required this.changes,
    required this.newGoals,
    required this.publishCards,
    required this.saving,
    required this.onPublishCards,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      minimum: const EdgeInsets.all(AppSizes.s12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s10, AppSizes.s10),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppSizes.s20),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withValues(alpha: 0.25), blurRadius: AppSizes.s16, offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportChanges(changes),
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                  ),
                  if (newGoals > 0)
                    InkWell(
                      onTap: () => onPublishCards(!publishCards),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: AppSizes.s28,
                            child: FittedBox(
                              child: Switch(
                                value: publishCards,
                                onChanged: onPublishCards,
                                activeThumbColor: AppColors.gold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              l10n.reportPublishCards,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            FilledButton(
              onPressed: saving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(AppSizes.s100, AppSizes.s44),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox.square(
                      dimension: AppSizes.s20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                    )
                  : Text(l10n.reportSave,
                      style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s16)),
            ),
          ],
        ),
      ),
    );
  }
}
