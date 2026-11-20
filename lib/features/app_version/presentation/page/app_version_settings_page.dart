import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/app_version/presentation/bloc/app_version_settings_cubit.dart';
import 'package:arena_soccer/features/app_version/presentation/widgets/app_update_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin → "Versão do app" (`config/versao`): builds mínimo
/// (obriga a atualizar) e recomendado (sugere) do Android e do iOS, a
/// mensagem do aviso e o build instalado neste aparelho.
class AppVersionSettingsPage extends StatefulWidget {
  const AppVersionSettingsPage({super.key});

  @override
  State<AppVersionSettingsPage> createState() => _AppVersionSettingsPageState();
}

class _AppVersionSettingsPageState extends State<AppVersionSettingsPage> {
  final _message = TextEditingController();

  AppVersionSettingsCubit get _cubit => context.read<AppVersionSettingsCubit>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _cubit.load();
    if (mounted) _message.text = _cubit.state.draft.message;
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final state = _cubit.state;
    if (state.raisesMinimum) {
      final draft = state.draft;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.appVersionRaiseTitle),
          content: Text(l10n.appVersionRaiseText(draft.minAndroid, draft.minIos)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.fantasyCancel)),
            TextButton(
              key: const ValueKey('app-version-raise-confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.appVersionSave),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    await _cubit.save();
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
        title: Text(l10n.appVersionTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
      ),
      body: BlocConsumer<AppVersionSettingsCubit, AppVersionSettingsState>(
        listenWhen: (_, current) => current.result != AppVersionSaveResult.none,
        listener: (context, state) => showSnackBar(
          context: context,
          message: state.result == AppVersionSaveResult.saved
              ? l10n.appVersionSaved
              : (state.failure ?? l10n.appVersionSaveError),
          isSuccess: state.result == AppVersionSaveResult.saved,
        ),
        builder: (context, state) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final draft = state.draft;
          final ios = appUpdateIsIos;
          return ListView(
            padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
            children: [
              Text(l10n.appVersionIntro, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
              const SizedBox(height: AppSizes.s12),
              Container(
                padding: const EdgeInsets.all(AppSizes.s12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.s12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: AppColors.primaryDark),
                    const SizedBox(width: AppSizes.s10),
                    Expanded(
                      child: Text(
                        l10n.appVersionInstalled(
                          ios ? 'iOS' : 'Android',
                          state.installedName.isEmpty ? '—' : state.installedName,
                          state.installed,
                        ),
                        key: const ValueKey('app-version-installed'),
                        style: AppTypography.label(color: AppColors.textPrimary),
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('app-version-use-installed'),
                      onPressed: state.installed > 0 ? () => _cubit.useInstalledAsRecommended(ios: ios) : null,
                      child: Text(l10n.appVersionUseInstalled),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s16),
              _PlatformCard(
                title: 'Android',
                icon: Icons.android_rounded,
                keyPrefix: 'android',
                min: draft.minAndroid,
                recommended: draft.recommendedAndroid,
                onMin: (v) => _cubit.edit((d) => d.copyWith(minAndroid: v)),
                onRecommended: (v) => _cubit.edit((d) => d.copyWith(recommendedAndroid: v)),
              ),
              const SizedBox(height: AppSizes.s12),
              _PlatformCard(
                title: 'iOS',
                icon: Icons.apple_rounded,
                keyPrefix: 'ios',
                min: draft.minIos,
                recommended: draft.recommendedIos,
                onMin: (v) => _cubit.edit((d) => d.copyWith(minIos: v)),
                onRecommended: (v) => _cubit.edit((d) => d.copyWith(recommendedIos: v)),
              ),
              const SizedBox(height: AppSizes.s16),
              ArenaTextField(
                labelText: l10n.appVersionMessage,
                hintText: l10n.appVersionMessageHint,
                controller: _message,
                maxLines: 3,
                onChaged: (value) => _cubit.edit((d) => d.copyWith(message: value)),
              ),
              const SizedBox(height: AppSizes.s8),
              Text(l10n.appVersionHelp, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              const SizedBox(height: AppSizes.s20),
              ArenaButton.primary(
                key: const ValueKey('app-version-save'),
                title: l10n.appVersionSave,
                isLoading: state.saving,
                function: state.dirty && !state.saving ? () => _save(l10n) : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String keyPrefix;
  final int min;
  final int recommended;
  final ValueChanged<int> onMin;
  final ValueChanged<int> onRecommended;

  const _PlatformCard({
    required this.title,
    required this.icon,
    required this.keyPrefix,
    required this.min,
    required this.recommended,
    required this.onMin,
    required this.onRecommended,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget stepper(String label, String hint, int value, ValueChanged<int> onChanged, String key) => Padding(
          padding: const EdgeInsets.only(top: AppSizes.s8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.label(color: AppColors.textPrimary)),
                    Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('$key-minus'),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              SizedBox(
                width: AppSizes.s40,
                child: Text(
                  value == 0 ? '—' : '$value',
                  key: ValueKey('$key-value'),
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                ),
              ),
              IconButton(
                key: ValueKey('$key-plus'),
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark),
              const SizedBox(width: AppSizes.s8),
              Text(title, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
            ],
          ),
          stepper(l10n.appVersionRecommended, l10n.appVersionRecommendedHint, recommended, onRecommended,
              '$keyPrefix-recommended'),
          stepper(l10n.appVersionMinimum, l10n.appVersionMinimumHint, min, onMin, '$keyPrefix-min'),
        ],
      ),
    );
  }
}
