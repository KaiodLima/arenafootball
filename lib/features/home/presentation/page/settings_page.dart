import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/delete_account_sheet.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Configurações da conta logada (aberta pelo rodapé do drawer).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final deleted = await DeleteAccountSheet.show(context);
    if (!deleted || !context.mounted) return;
    showSnackBar(context: context, message: AppLocalizations.of(context).deleteAccountSuccess);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.settingsTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
        children: [
          SectionHeader(title: l10n.settingsHelpSection),
          ArenaCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s14),
            onTap: () async {
              await sl<TourService>().reset();
              if (context.mounted) showSnackBar(context: context, message: l10n.settingsReplayToursDone);
            },
            child: Row(
              children: [
                Container(
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                  ),
                  child: const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: AppSizes.s20),
                ),
                const SizedBox(width: AppSizes.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsReplayTours,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                      ),
                      Text(l10n.settingsReplayToursHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s16),
          SectionHeader(title: l10n.settingsAccountSection),
          ArenaCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s14),
            onTap: () => _deleteAccount(context),
            child: Row(
              children: [
                Container(
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                  ),
                  child: const Icon(Icons.person_remove_outlined, color: AppColors.danger, size: AppSizes.s20),
                ),
                const SizedBox(width: AppSizes.s14),
                Expanded(
                  child: Text(
                    l10n.drawerDeleteAccount,
                    style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s16),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
