import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    BlocProvider.of<LoginCubit>(context).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _goHome() => Navigator.pushReplacementNamed(context, AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is SuccessLoginState) {
            BlocProvider.of<SessionCubit>(context).signedIn(state.user);
            showSnackBar(context: context, message: l10n.loginSuccess);
            _goHome();
          }
          if (state is InvalidLoginState) {
            final message = state.error == LoginValidationError.invalidEmail
                ? l10n.loginInvalidEmail
                : l10n.loginInvalidPassword;
            showSnackBar(context: context, message: message, isSuccess: false);
          }
          if (state is ErrorLoginState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(AppImages.logo, height: AppSizes.loginLogoHeight),
                  const SizedBox(height: AppSizes.s16),
                  ArenaTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    labelText: l10n.loginEmailLabel,
                    hintText: l10n.loginEmailHint,
                    icon: const Icon(Icons.email, color: AppColors.primary, size: AppSizes.s24),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  ArenaTextField(
                    controller: _passwordController,
                    obscureText: true,
                    labelText: l10n.loginPasswordLabel,
                    icon: const Icon(Icons.key, color: AppColors.primary, size: AppSizes.s24),
                  ),
                  const SizedBox(height: AppSizes.s24),
                  ArenaButton.primary(
                    title: l10n.loginButton,
                    isLoading: state is LoadingLoginState,
                    function: _submit,
                  ),
                  const SizedBox(height: AppSizes.s8),
                  ArenaButton.outlined(
                    title: l10n.loginCreateAccountButton,
                    function: () => Navigator.pushNamed(context, AppRoutes.registerUserPage),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  TextButton(
                    onPressed: () {
                      BlocProvider.of<SessionCubit>(context).continueAsGuest();
                      _goHome();
                    },
                    child: Text(l10n.loginSkipButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
