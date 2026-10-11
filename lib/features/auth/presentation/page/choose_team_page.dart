import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_dropdown_field.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Etapa 2 do cadastro: região e time do coração. Também aparece no login de
/// contas sem time. Sempre dá para pular.
class ChooseTeamPage extends StatefulWidget {
  const ChooseTeamPage({super.key});

  @override
  State<ChooseTeamPage> createState() => _ChooseTeamPageState();
}

class _ChooseTeamPageState extends State<ChooseTeamPage> {
  late final ChooseTeamCubit _cubit;
  late final String _initialRegion;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ChooseTeamCubit>(context);
    _initialRegion = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    _cubit.load(initialRegion: _initialRegion);
  }

  void _goHome() => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);

  void _save() {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user == null) return _goHome();
    _cubit.save(userId: user.id);
  }

  void _onSaved(SavedChooseTeamState state) {
    final session = BlocProvider.of<SessionCubit>(context);
    final user = session.state.user;
    if (user != null) session.updateUser(user.copyWith(favoriteTeam: state.selectedTeam));
    BlocProvider.of<RegionCubit>(context).selectRegion(state.selectedRegion!);
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // A conta já existe: voltar para o cadastro não faz sentido. A saída é "Pular".
    return PopScope(
      canPop: false,
      child: BlocConsumer<ChooseTeamCubit, ChooseTeamState>(
        listener: (context, state) {
          if (state is SavedChooseTeamState) _onSaved(state);
          if (state is SaveErrorChooseTeamState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          return AuthScaffold(
            compact: true,
            title: l10n.chooseTeamTitle,
            subtitle: l10n.chooseTeamSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.chooseTeamDescription, style: AppTypography.subtitle()),
                const SizedBox(height: AppSizes.s24),
                if (state is LoadingChooseTeamState)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (state is LoadErrorChooseTeamState)
                  _LoadError(onRetry: () => _cubit.retry(initialRegion: _initialRegion))
                else ...[
                  AuthDropdownField(
                    label: l10n.registerRegionLabel,
                    icon: Icons.place_outlined,
                    value: state.selectedRegion,
                    items: state.regions,
                    onChanged: _cubit.selectRegion,
                  ),
                  const SizedBox(height: AppSizes.s14),
                  if (state.loadingTeams)
                    const LinearProgressIndicator(minHeight: AppSizes.s2, color: AppColors.primary)
                  else if (state.teams.isEmpty)
                    Text(l10n.chooseTeamEmptyTeams, style: AppTypography.subtitle())
                  else
                    AuthDropdownField(
                      label: l10n.registerTeamLabel,
                      icon: Icons.shield_outlined,
                      value: state.selectedTeam,
                      items: state.teams,
                      onChanged: _cubit.selectTeam,
                    ),
                  const SizedBox(height: AppSizes.s28),
                  ArenaButton(
                    title: l10n.chooseTeamConfirm,
                    height: AppSizes.buttonHeightLarge,
                    borderRadius: AppSizes.fieldRadius,
                    fontSize: AppSizes.s16,
                    textColor: AppColors.white,
                    buttonColor: state.canSave ? AppColors.primary : AppColors.grey,
                    isLoading: state is SavingChooseTeamState,
                    function: state.canSave ? _save : null,
                  ),
                ],
                const SizedBox(height: AppSizes.s8),
                Center(
                  child: TextButton(
                    onPressed: state is SavingChooseTeamState ? null : _goHome,
                    child: Text(l10n.chooseTeamSkip, style: AppTypography.label(color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary, size: AppSizes.s40),
        const SizedBox(height: AppSizes.s12),
        Text(l10n.chooseTeamLoadError, textAlign: TextAlign.center, style: AppTypography.subtitle()),
        const SizedBox(height: AppSizes.s16),
        ArenaButton(
          title: l10n.commonTryAgain,
          height: AppSizes.buttonHeightLarge,
          borderRadius: AppSizes.fieldRadius,
          fontSize: AppSizes.s16,
          buttonColor: AppColors.surface,
          buttonBorderColor: AppColors.primary,
          textColor: AppColors.primary,
          function: onRetry,
        ),
      ],
    );
  }
}
