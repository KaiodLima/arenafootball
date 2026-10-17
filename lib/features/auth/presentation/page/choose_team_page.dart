import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/domain/team_change_policy.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/team_change_notice.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/team_choice_selector.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Argumentos da rota. Sem eles, é o fluxo de cadastro/login.
class ChooseTeamArgs {
  /// Aberta pelo menu lateral: dá para voltar, e ao terminar volta à home já aberta.
  final bool canGoBack;

  const ChooseTeamArgs({this.canGoBack = false});
}

/// Etapa 2 do cadastro: região e time do coração. Também aparece no login de
/// contas sem time e pelo menu lateral. Sempre dá para pular.
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

  bool get _canGoBack {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is ChooseTeamArgs && args.canGoBack;
  }

  /// Já tem time (veio trocar): a saída é "manter o time atual", não "pular".
  bool get _keepsCurrentTeam =>
      _canGoBack && (BlocProvider.of<SessionCubit>(context).state.user?.hasFavoriteTeam ?? false);

  /// Sai da tela: volta à home que abriu (menu) ou abre a home (cadastro).
  void _leave() {
    if (_canGoBack) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    }
  }

  Future<void> _save() async {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user == null) return _leave();
    final state = _cubit.state;
    final team = state.selectedTeam!;
    // Troca de um time para outro: avisa do prazo antes de gravar.
    if (TeamChangePolicy.isChange(user, team: team, teamId: state.selectedTeamId)) {
      if (!TeamChangePolicy.canChange(user, DateTime.now())) {
        return showTeamChangeLocked(context, TeamChangePolicy.nextChangeAt(user));
      }
      final l10n = AppLocalizations.of(context);
      final confirmed = await showArenaConfirm(
        context,
        title: l10n.chooseTeamConfirmChangeTitle(team),
        message: l10n.chooseTeamConfirmChangeMessage,
        confirmLabel: l10n.chooseTeamConfirmChange,
        icon: Icons.swap_horiz_rounded,
      );
      if (!confirmed || !mounted) return;
    }
    await _cubit.save(user: user);
  }

  void _onSaved(SavedChooseTeamState state) {
    final session = BlocProvider.of<SessionCubit>(context);
    final user = session.state.user;
    if (user != null) {
      session.updateUser(user.copyWith(
        favoriteTeam: state.selectedTeam,
        favoriteTeamId: state.selectedTeamId,
        teamChangedAt: state.changedAt,
      ));
    }
    BlocProvider.of<RegionCubit>(context).selectRegion(state.selectedRegion!);
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // No cadastro a conta já existe: voltar não faz sentido, a saída é "Pular".
    return PopScope(
      canPop: _canGoBack,
      child: BlocConsumer<ChooseTeamCubit, ChooseTeamState>(
        listener: (context, state) {
          if (state is SavedChooseTeamState) _onSaved(state);
          if (state is SaveErrorChooseTeamState) {
            final failure = state.failure;
            if (failure is TeamChangeLockedFailure) {
              showTeamChangeLocked(context, failure.nextAt);
            } else {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
          }
        },
        builder: (context, state) {
          return AuthScaffold(
            compact: true,
            // Aberta pela carteirinha/menu: seta para voltar sem trocar nada.
            onBack: _canGoBack && state is! SavingChooseTeamState ? _leave : null,
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
                  _SectionLabel(icon: Icons.place_outlined, text: l10n.registerRegionLabel),
                  const SizedBox(height: AppSizes.s10),
                  Wrap(
                    spacing: AppSizes.s8,
                    runSpacing: AppSizes.s8,
                    children: [
                      for (final region in state.regions)
                        ArenaChoiceChip(
                          label: region,
                          selected: region == state.selectedRegion,
                          onTap: () => _cubit.selectRegion(region),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s24),
                  if (!state.loadingTeams && state.teams.isEmpty)
                    Text(l10n.chooseTeamEmptyTeams, style: AppTypography.subtitle())
                  else
                    TeamChoiceSelector(
                      // Nova região: recomeça fechado.
                      key: ValueKey(state.selectedRegion),
                      teams: state.teams,
                      selected: state.selectedTeam,
                      selectedId: state.selectedTeamId,
                      loading: state.loadingTeams,
                      placeholder: l10n.registerTeamLabel,
                      onSelected: _cubit.selectTeam,
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
                    onPressed: state is SavingChooseTeamState ? null : _leave,
                    child: Text(_keepsCurrentTeam ? l10n.chooseTeamKeepCurrent : l10n.chooseTeamSkip,
                        style: AppTypography.label(color: AppColors.textSecondary)),
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.s18, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.s6),
        Text(text, style: AppTypography.label(color: AppColors.textPrimary)),
      ],
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
