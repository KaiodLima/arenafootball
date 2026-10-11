import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_dropdown_field.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  late final RegisterUserCubit _cubit;

  // Os erros só aparecem depois que o usuário mexe no campo.
  final Set<String> _touched = {};

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<RegisterUserCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  String? _errorText(String field, RegisterFieldError? error, AppLocalizations l10n) {
    if (!_touched.contains(field) || error == null) return null;
    switch (error) {
      case RegisterFieldError.required:
        return l10n.commonRequiredField;
      case RegisterFieldError.nameTooShort:
        return l10n.registerNameTooShort;
      case RegisterFieldError.invalidEmail:
        return l10n.registerEmailExample;
      case RegisterFieldError.passwordTooShort:
        return l10n.registerPasswordTooShort;
    }
  }

  void _onChanged(String field, ValueChanged<String> update, String value) {
    setState(() => _touched.add(field));
    update(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<RegisterUserCubit, RegisterUserState>(
      listener: (context, state) {
        if (state is SuccessRegisterUserState) {
          showSnackBar(context: context, message: l10n.registerSuccess);
          BlocProvider.of<SessionCubit>(context).signedIn(state.user);
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
        }
        if (state is ErrorRegisterUserState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          compact: true,
          title: l10n.registerTitle,
          subtitle: l10n.registerSubtitle,
          onBack: () => Navigator.pop(context),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  label: l10n.registerNameLabel,
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _errorText('name', state.nameError, l10n),
                  onChanged: (value) => _onChanged('name', _cubit.changeName, value),
                ),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  label: l10n.registerEmailLabel,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _errorText('email', state.emailError, l10n),
                  onChanged: (value) => _onChanged('email', _cubit.changeEmail, value),
                ),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  label: l10n.registerPasswordLabel,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _errorText('password', state.passwordError, l10n),
                  onChanged: (value) => _onChanged('password', _cubit.changePassword, value),
                ),
                const SizedBox(height: AppSizes.s14),
                AuthDropdownField(
                  label: l10n.registerRegionLabel,
                  icon: Icons.place_outlined,
                  value: state.selectedRegion,
                  items: state.regions,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s14),
                AuthDropdownField(
                  label: l10n.registerTeamLabel,
                  icon: Icons.shield_outlined,
                  value: state.selectedTeam,
                  items: state.teams,
                  onChanged: _cubit.selectTeam,
                ),
                const SizedBox(height: AppSizes.s28),
                ArenaButton(
                  title: l10n.registerButton,
                  height: AppSizes.buttonHeightLarge,
                  borderRadius: AppSizes.fieldRadius,
                  fontSize: AppSizes.s16,
                  textColor: AppColors.white,
                  buttonColor: state.canSubmit ? AppColors.primary : AppColors.grey,
                  isLoading: state is SubmittingRegisterUserState,
                  function: state.canSubmit ? _cubit.submit : null,
                ),
                const SizedBox(height: AppSizes.s8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.registerHaveAccountButton, style: AppTypography.label()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
