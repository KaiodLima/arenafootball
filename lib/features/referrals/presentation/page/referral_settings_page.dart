import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/presentation/bloc/referral_config_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin → "Indique amigos": liga/desliga as indicações
/// (`config/indicacao`) com o resumo das regras.
class ReferralSettingsPage extends StatelessWidget {
  const ReferralSettingsPage({super.key});

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
          l10n.referralTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<ReferralConfigCubit, ReferralConfigState>(
        listener: (context, state) {
          if (state is! SavedReferralConfigState) return;
          final failure = state.failure;
          showSnackBar(
            context: context,
            message: failure ?? l10n.referralSettingsSaved,
            isSuccess: failure == null,
          );
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.s16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: SwitchListTile(
                  value: state.enabled,
                  onChanged: state.saving ? null : BlocProvider.of<ReferralConfigCubit>(context).setEnabled,
                  activeThumbColor: AppColors.primary,
                  title: Text(l10n.referralSettingsSwitch, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.s4),
                    child: Text(
                      state.enabled ? l10n.referralSettingsOn : l10n.referralSettingsOff,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
                  const SizedBox(width: AppSizes.s8),
                  Expanded(
                    child: Text(
                      l10n.referralSettingsRules(ReferralCode.maxExtraPacks),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
