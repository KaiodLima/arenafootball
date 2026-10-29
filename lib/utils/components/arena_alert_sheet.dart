import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cor do ícone e do botão de confirmar.
enum ArenaAlertTone { primary, danger, warning }

extension on ArenaAlertTone {
  Color get color => switch (this) {
        ArenaAlertTone.primary => AppColors.primary,
        ArenaAlertTone.danger => AppColors.danger,
        ArenaAlertTone.warning => AppColors.warning,
      };
}

/// Confirmação no padrão de alerta do app (o mesmo do Relove): bottom sheet
/// com alça, cabeçalho pequeno com ✕, ícone, título, descrição e os botões
/// Cancelar (suave) e Confirmar (sólido). Devolve true só se confirmou.
Future<bool> showArenaConfirm(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  required String confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.help_outline_rounded,
  ArenaAlertTone tone = ArenaAlertTone.primary,
  String? header,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await _show<bool>(
    context,
    _ArenaAlertSheet(
      header: header ?? l10n.alertHeaderConfirm,
      title: title,
      message: message,
      content: content,
      icon: icon,
      tone: tone,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel ?? l10n.commonCancel,
    ),
  );
  return confirmed ?? false;
}

/// Aviso com um botão só ("Ok"), no mesmo padrão.
Future<void> showArenaNotice(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  IconData icon = Icons.info_outline_rounded,
  ArenaAlertTone tone = ArenaAlertTone.primary,
}) async {
  final l10n = AppLocalizations.of(context);
  await _show<bool>(
    context,
    _ArenaAlertSheet(
      header: l10n.alertHeaderNotice,
      title: title,
      message: message,
      content: content,
      icon: icon,
      tone: tone,
      confirmLabel: l10n.commonOk,
    ),
  );
}

Future<T?> _show<T>(BuildContext context, Widget sheet) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.s16)),
    ),
    // Folha com campo: sobe junto com o teclado.
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: sheet,
    ),
  );
  FocusManager.instance.primaryFocus?.unfocus();
  return result;
}

class _ArenaAlertSheet extends StatelessWidget {
  final String header;
  final String title;
  final String? message;
  final Widget? content;
  final IconData icon;
  final ArenaAlertTone tone;
  final String confirmLabel;

  /// Nulo = aviso (só o botão de confirmar).
  final String? cancelLabel;

  const _ArenaAlertSheet({
    required this.header,
    required this.title,
    required this.message,
    required this.content,
    required this.icon,
    required this.tone,
    required this.confirmLabel,
    this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    final divider = Divider(height: AppSizes.s1, thickness: AppSizes.s1, color: AppColors.greyLight.withValues(alpha: 0.6));

    final cancel = cancelLabel == null
        ? null
        : _SheetButton(
            label: cancelLabel!,
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
            onTap: () => Navigator.pop(context, false),
          );
    final confirm = _SheetButton(
      label: confirmLabel,
      background: color,
      foreground: AppColors.white,
      onTap: () => Navigator.pop(context, true),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s16, AppSizes.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alça.
              Container(
                width: AppSizes.s40,
                height: AppSizes.s4,
                margin: const EdgeInsets.only(bottom: AppSizes.s12),
                decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(AppSizes.s2)),
              ),
              // Cabeçalho pequeno com o ✕.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      header,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              divider,
              const SizedBox(height: AppSizes.s20),
              Container(
                width: AppSizes.s64,
                height: AppSizes.s64,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: AppSizes.s32),
              ),
              const SizedBox(height: AppSizes.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s16),
                ),
              ],
              if (content != null) ...[const SizedBox(height: AppSizes.s16), content!],
              const SizedBox(height: AppSizes.s20),
              divider,
              const SizedBox(height: AppSizes.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (cancel == null) return SizedBox(width: double.infinity, child: confirm);
                  // Tela estreita: um embaixo do outro (confirmar em cima).
                  if (constraints.maxWidth < 300) {
                    return Column(children: [confirm, const SizedBox(height: AppSizes.s10), cancel]);
                  }
                  return Row(
                    children: [
                      Expanded(child: cancel),
                      const SizedBox(width: AppSizes.s12),
                      Expanded(child: confirm),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetButton({required this.label, required this.background, required this.foreground, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.s48,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
