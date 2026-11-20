import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// A plataforma do aparelho é iOS (a loja e os campos do `config/versao`).
bool get appUpdateIsIos => defaultTargetPlatform == TargetPlatform.iOS;

/// Abre a loja do aparelho (Play Store / App Store) fora do app.
Future<void> openAppStore() async {
  final uri = Uri.parse(AppStores.forPlatform(ios: appUpdateIsIos));
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    AppLogger.e('openAppStore', name: 'AppUpdate', error: e);
  }
}

/// Aviso de atualização. Obrigatório: só "Atualizar agora" (não fecha nem
/// com o voltar). Sugerido: "Atualizar" e "Depois" (devolve `false`).
/// [onUpdate] troca a abertura da loja (teste).
Future<bool?> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdateLevel level,
  String message = '',
  Future<void> Function()? onUpdate,
}) {
  final required = level == AppUpdateLevel.required;
  return showDialog<bool>(
    context: context,
    barrierDismissible: !required,
    builder: (context) => PopScope(
      canPop: !required,
      child: AppUpdateDialog(required: required, message: message, onUpdate: onUpdate ?? openAppStore),
    ),
  );
}

class AppUpdateDialog extends StatelessWidget {
  final bool required;
  final String message;
  final Future<void> Function() onUpdate;

  const AppUpdateDialog({super.key, required this.required, this.message = '', required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      key: ValueKey(required ? 'app-update-required' : 'app-update-recommended'),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s24, AppSizes.s24, AppSizes.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s64),
                Positioned(
                  right: -AppSizes.s8,
                  bottom: -AppSizes.s4,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.s4),
                    decoration: BoxDecoration(
                      color: required ? AppColors.danger : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(Icons.system_update_rounded, size: AppSizes.s16, color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s16),
            Text(
              required ? l10n.appUpdateRequiredTitle : l10n.appUpdateRecommendedTitle,
              textAlign: TextAlign.center,
              style: AppTypography.title().copyWith(fontSize: AppSizes.s20),
            ),
            const SizedBox(height: AppSizes.s8),
            Text(
              required ? l10n.appUpdateRequiredText : l10n.appUpdateRecommendedText,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14),
            ),
            if (message.trim().isNotEmpty) ...[
              const SizedBox(height: AppSizes.s12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.s12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.s12),
                ),
                child: Text(
                  message.trim(),
                  key: const ValueKey('app-update-message'),
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              key: const ValueKey('app-update-now'),
              title: required ? l10n.appUpdateNow : l10n.appUpdateAction,
              function: () async {
                await onUpdate();
                if (!required && context.mounted) Navigator.of(context).pop(true);
              },
            ),
            if (!required) ...[
              const SizedBox(height: AppSizes.s4),
              TextButton(
                key: const ValueKey('app-update-later'),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.appUpdateLater),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
