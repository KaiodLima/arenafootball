import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_settings_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/app_routes.dart';

/// Admin → engrenagem do campeonato → "Arena Fantasy": liga/desliga o Fantasy
/// daquele campeonato e ajusta os parâmetros (`fantasy/{idDocCampeonato}`).
class FantasySettingsPage extends StatefulWidget {
  final ChampionshipDTO championship;

  const FantasySettingsPage({super.key, required this.championship});

  @override
  State<FantasySettingsPage> createState() => _FantasySettingsPageState();
}

class _FantasySettingsPageState extends State<FantasySettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FantasySettingsCubit>().load(widget.championship);
  }

  String? _errorText(AppLocalizations l10n, FantasySettingsError? error) => switch (error) {
        null => null,
        FantasySettingsError.minMinutesRange || FantasySettingsError.defenseRange => l10n.fantasyErrorRange,
        FantasySettingsError.defenseBelowMin => l10n.fantasyErrorDefenseBelowMin,
        FantasySettingsError.captainRange => l10n.fantasyErrorCaptain,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<FantasySettingsCubit>();
    return BlocConsumer<FantasySettingsCubit, FantasySettingsState>(
      listenWhen: (previous, current) => current.result != FantasySaveResult.none,
      listener: (context, state) => showSnackBar(
        context: context,
        message: state.result == FantasySaveResult.saved ? l10n.fantasySaved : (state.failure ?? l10n.fantasySaveError),
        isSuccess: state.result == FantasySaveResult.saved,
      ),
      builder: (context, state) {
        final draft = state.draft;
        final error = _errorText(l10n, state.error);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.fantasyTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          bottomNavigationBar: draft == null
              ? null
              : ArenaSubmitBar(
                  title: l10n.fantasySave,
                  loading: state.saving,
                  onPressed: () {
                    if (error == null) cubit.save();
                  },
                ),
          body: draft == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  children: [
                    Row(
                      children: [
                        TeamCrest(imageUrl: widget.championship.imageUrl, size: AppSizes.s48),
                        const SizedBox(width: AppSizes.s12),
                        Expanded(
                          child: Text(
                            widget.championship.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.s16),
                    _Panel(
                      child: SwitchListTile(
                        key: const ValueKey('fantasy-active'),
                        value: draft.active,
                        onChanged: state.saving ? null : cubit.setActive,
                        activeThumbColor: AppColors.primary,
                        title: Text(l10n.fantasyActive, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSizes.s4),
                          child: Text(
                            draft.active ? l10n.fantasyActiveOn : l10n.fantasyActiveOff,
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                        ),
                      ),
                    ),
                    if (draft.participants > 0) ...[
                      const SizedBox(height: AppSizes.s8),
                      Text(
                        l10n.fantasyParticipants(draft.participants),
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
                    const SizedBox(height: AppSizes.s20),
                    Text(l10n.fantasyParams, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
                    const SizedBox(height: AppSizes.s8),
                    _Panel(
                      child: Column(
                        children: [
                          _Stepper(
                            keyName: 'fantasy-min',
                            title: l10n.fantasyMinMinutes,
                            hint: l10n.fantasyMinMinutesHint,
                            value: l10n.fantasyMinutesValue(draft.minMinutes),
                            onLess: () => cubit.setMinMinutes(draft.minMinutes - FantasyLimits.minutesStep),
                            onMore: () => cubit.setMinMinutes(draft.minMinutes + FantasyLimits.minutesStep),
                          ),
                          const Divider(height: 1, color: AppColors.greyLight),
                          _Stepper(
                            keyName: 'fantasy-defense',
                            title: l10n.fantasyDefenseMinutes,
                            hint: l10n.fantasyDefenseMinutesHint,
                            value: l10n.fantasyMinutesValue(draft.minDefenseMinutes),
                            onLess: () => cubit.setDefenseMinutes(draft.minDefenseMinutes - FantasyLimits.minutesStep),
                            onMore: () => cubit.setDefenseMinutes(draft.minDefenseMinutes + FantasyLimits.minutesStep),
                          ),
                          const Divider(height: 1, color: AppColors.greyLight),
                          _Stepper(
                            keyName: 'fantasy-captain',
                            title: l10n.fantasyCaptain,
                            hint: l10n.fantasyCaptainHint,
                            value: FantasySettings.captainLabel(draft.captainMultiplier),
                            onLess: () => cubit.setCaptain(draft.captainMultiplier - FantasyLimits.captainStep),
                            onMore: () => cubit.setCaptain(draft.captainMultiplier + FantasyLimits.captainStep),
                          ),
                        ],
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: AppSizes.s8),
                      Text(error, style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const ValueKey('fantasy-defaults'),
                        onPressed: state.saving ? null : cubit.restoreDefaults,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(l10n.fantasyRestoreDefaults),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
                        const SizedBox(width: AppSizes.s8),
                        Expanded(
                          child: Text(
                            l10n.fantasyParamsNote,
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                        ),
                      ],
                    ),
                    // Acompanhar: rodadas/apuração, participantes e o ranking.
                    const SizedBox(height: AppSizes.s24),
                    Text(l10n.fantasyFollowTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
                    const SizedBox(height: AppSizes.s8),
                    _Panel(
                      child: Column(
                        children: [
                          _FollowTile(
                            keyName: 'fantasy-follow-rounds',
                            icon: Icons.fact_check_outlined,
                            title: l10n.fantasyFollowRounds,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.fantasyAdminPage,
                                arguments: {'championship': widget.championship, 'tab': 0}),
                          ),
                          const Divider(height: 1, color: AppColors.greyLight),
                          _FollowTile(
                            keyName: 'fantasy-follow-participants',
                            icon: Icons.groups_rounded,
                            title: l10n.fantasyFollowParticipants,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.fantasyAdminPage,
                                arguments: {'championship': widget.championship, 'tab': 1}),
                          ),
                          const Divider(height: 1, color: AppColors.greyLight),
                          _FollowTile(
                            keyName: 'fantasy-follow-ranking',
                            icon: Icons.emoji_events_outlined,
                            title: l10n.fantasyRankingTitle,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.fantasyRankingPage,
                                arguments: widget.championship),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.greyLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

/// Linha de parâmetro com −/+.
class _Stepper extends StatelessWidget {
  final String keyName;
  final String title;
  final String hint;
  final String value;
  final VoidCallback onLess;
  final VoidCallback onMore;

  const _Stepper({
    required this.keyName,
    required this.title,
    required this.hint,
    required this.value,
    required this.onLess,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s8, AppSizes.s12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label(color: AppColors.textPrimary)),
                const SizedBox(height: AppSizes.s2),
                Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          IconButton(key: ValueKey('$keyName-less'), icon: const Icon(Icons.remove_rounded), onPressed: onLess),
          SizedBox(
            width: AppSizes.s52,
            child: Text(
              value,
              key: ValueKey('$keyName-value'),
              textAlign: TextAlign.center,
              style: AppTypography.title().copyWith(fontSize: AppSizes.s16),
            ),
          ),
          IconButton(key: ValueKey('$keyName-more'), icon: const Icon(Icons.add_rounded), onPressed: onMore),
        ],
      ),
    );
  }
}

/// Linha da seção "Acompanhar".
class _FollowTile extends StatelessWidget {
  final String keyName;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FollowTile({required this.keyName, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        key: ValueKey(keyName),
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: AppTypography.label(color: AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
      );
}
