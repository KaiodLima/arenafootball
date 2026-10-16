import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/google_logo.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/or_divider.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Enquanto o sheet de recuperação está aberto, os erros aparecem nele.
  bool _resetSheetOpen = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<LoginCubit>(context).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _signInWithGoogle() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<LoginCubit>(context).signInWithGoogle();
  }

  void _signInWithApple() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<LoginCubit>(context).signInWithApple();
  }

  Future<void> _openForgotPassword() async {
    setState(() => _resetSheetOpen = true);
    await ForgotPasswordSheet.show(context, initialEmail: _emailController.text.trim());
    if (mounted) setState(() => _resetSheetOpen = false);
  }

  void _goHome() => Navigator.pushReplacementNamed(context, AppRoutes.home);

  void _onStateChanged(BuildContext context, LoginState state, AppLocalizations l10n) {
    if (state is SuccessLoginState) {
      BlocProvider.of<SessionCubit>(context).signedIn(state.user);
      showSnackBar(context: context, message: l10n.loginSuccess);
      // Contas antigas (ou quem pulou a etapa 2) ainda podem escolher o time.
      if (state.user.hasFavoriteTeam) {
        _goHome();
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.chooseTeamPage);
      }
    }
    if (state is PasswordResetSentLoginState) {
      showSnackBar(context: context, message: l10n.forgotPasswordSent);
    }
    if (_resetSheetOpen) return;
    if (state is InvalidLoginState) {
      final message =
          state.error == LoginValidationError.invalidEmail ? l10n.loginInvalidEmail : l10n.loginInvalidPassword;
      showSnackBar(context: context, message: message, isSuccess: false);
    }
    if (state is ErrorLoginState) {
      showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) => _onStateChanged(context, state, l10n),
      builder: (context, state) {
        final busy =
            state is LoadingLoginState || state is GoogleLoadingLoginState || state is AppleLoadingLoginState;
        return AuthScaffold(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.loginWelcomeTitle, style: AppTypography.display()),
                const SizedBox(height: AppSizes.s6),
                Text(l10n.loginWelcomeSubtitle, style: AppTypography.subtitle()),
                const SizedBox(height: AppSizes.s28),
                AuthTextField(
                  controller: _emailController,
                  label: l10n.loginEmailLabel,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSizes.s14),
                AuthTextField(
                  controller: _passwordController,
                  label: l10n.loginPasswordLabel,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openForgotPassword,
                    child: Text(l10n.loginForgotPassword, style: AppTypography.label()),
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                ArenaButton(
                  title: l10n.loginButton,
                  height: AppSizes.buttonHeightLarge,
                  borderRadius: AppSizes.fieldRadius,
                  fontSize: AppSizes.s16,
                  buttonColor: AppColors.primary,
                  textColor: AppColors.white,
                  isLoading: state is LoadingLoginState,
                  function: busy ? null : _submit,
                ),
                const SizedBox(height: AppSizes.s20),
                OrDivider(label: l10n.loginOr),
                const SizedBox(height: AppSizes.s20),
                ArenaButton(
                  title: l10n.loginWithGoogleButton,
                  height: AppSizes.buttonHeightLarge,
                  borderRadius: AppSizes.fieldRadius,
                  fontSize: AppSizes.s16,
                  buttonColor: AppColors.surface,
                  buttonBorderColor: AppColors.greyLight,
                  textColor: AppColors.textPrimary,
                  leading: const GoogleLogo(),
                  isLoading: state is GoogleLoadingLoginState,
                  function: busy ? null : _signInWithGoogle,
                ),
                // Login da Apple só no iOS (exigência da App Store junto do Google).
                if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                  const SizedBox(height: AppSizes.s12),
                  ArenaButton(
                    title: l10n.loginWithAppleButton,
                    height: AppSizes.buttonHeightLarge,
                    borderRadius: AppSizes.fieldRadius,
                    fontSize: AppSizes.s16,
                    buttonColor: AppColors.black,
                    buttonBorderColor: AppColors.black,
                    textColor: AppColors.white,
                    leading: const Icon(Icons.apple, size: AppSizes.s22, color: AppColors.white),
                    isLoading: state is AppleLoadingLoginState,
                    function: busy ? null : _signInWithApple,
                  ),
                ],
                const SizedBox(height: AppSizes.s12),
                ArenaButton(
                  title: l10n.loginCreateAccountButton,
                  height: AppSizes.buttonHeightLarge,
                  borderRadius: AppSizes.fieldRadius,
                  fontSize: AppSizes.s16,
                  buttonColor: AppColors.surface,
                  buttonBorderColor: AppColors.primary,
                  textColor: AppColors.primary,
                  function: () => Navigator.pushNamed(context, AppRoutes.registerUserPage),
                ),
                const SizedBox(height: AppSizes.s16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      BlocProvider.of<SessionCubit>(context).continueAsGuest();
                      _goHome();
                    },
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
                    label: Text(l10n.loginContinueAsGuest, style: AppTypography.label(color: AppColors.textSecondary)),
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
