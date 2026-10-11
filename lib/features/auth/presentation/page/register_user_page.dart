import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Etapa 1 do cadastro: dados de acesso. Ao criar a conta, segue para a
/// escolha de região e time (etapa 2).
class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  late final RegisterUserCubit _cubit;

  // Antes da primeira tentativa de envio, o erro só aparece no campo já tocado.
  final Set<String> _touched = {};

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<RegisterUserCubit>(context);
  }

  String? _errorText(String field, RegisterUserState state, RegisterFieldError? error, AppLocalizations l10n) {
    if (error == null || (!_touched.contains(field) && !state.submitAttempted)) return null;
    switch (error) {
      case RegisterFieldError.required:
        return l10n.commonRequiredField;
      case RegisterFieldError.nameTooShort:
        return l10n.registerNameTooShort;
      case RegisterFieldError.invalidEmail:
        return l10n.registerEmailExample;
      case RegisterFieldError.passwordTooShort:
        return l10n.registerPasswordTooShort;
      case RegisterFieldError.passwordMismatch:
        return l10n.registerPasswordMismatch;
    }
  }

  void _onChanged(String field, ValueChanged<String> update, String value) {
    setState(() => _touched.add(field));
    update(value);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<RegisterUserCubit, RegisterUserState>(
      listener: (context, state) {
        if (state is SuccessRegisterUserState) {
          showSnackBar(context: context, message: l10n.registerSuccess);
          BlocProvider.of<SessionCubit>(context).signedIn(state.user);
          Navigator.pushReplacementNamed(context, AppRoutes.chooseTeamPage);
        }
        if (state is ErrorRegisterUserState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          compact: true,
          title: l10n.registerTitle,
          subtitle: l10n.registerStepOne,
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
                  errorText: _errorText('name', state, state.nameError, l10n),
                  onChanged: (value) => _onChanged('name', _cubit.changeName, value),
                ),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  label: l10n.registerEmailLabel,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _errorText('email', state, state.emailError, l10n),
                  onChanged: (value) => _onChanged('email', _cubit.changeEmail, value),
                ),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  label: l10n.registerPasswordLabel,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _errorText('password', state, state.passwordError, l10n),
                  onChanged: (value) => _onChanged('password', _cubit.changePassword, value),
                ),
                if (state.password.isNotEmpty) PasswordStrengthMeter(strength: state.passwordStrength),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  label: l10n.registerConfirmPasswordLabel,
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  errorText: _errorText('confirmPassword', state, state.confirmPasswordError, l10n),
                  onChanged: (value) => _onChanged('confirmPassword', _cubit.changeConfirmPassword, value),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSizes.s28),
                ArenaButton(
                  title: l10n.registerCreateAccountButton,
                  height: AppSizes.buttonHeightLarge,
                  borderRadius: AppSizes.fieldRadius,
                  fontSize: AppSizes.s16,
                  textColor: AppColors.white,
                  buttonColor: AppColors.primary,
                  isLoading: state is SubmittingRegisterUserState,
                  function: _submit,
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
