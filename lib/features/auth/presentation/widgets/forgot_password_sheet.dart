import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_state.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Bottom sheet de "esqueci minha senha". Usa o [LoginCubit] da página.
/// Erros aparecem dentro do sheet: um snackbar ficaria escondido atrás dele.
class ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordSheet({super.key, required this.initialEmail});

  /// Abre o sheet. Completa quando ele fecha.
  static Future<void> show(BuildContext context, {String initialEmail = ''}) {
    final cubit = BlocProvider.of<LoginCubit>(context)..clear();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ForgotPasswordSheet(initialEmail: initialEmail),
      ),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final TextEditingController _emailController = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _send() => BlocProvider.of<LoginCubit>(context).sendPasswordReset(_emailController.text);

  String? _errorFor(LoginState state, AppLocalizations l10n) {
    if (state is InvalidLoginState) return l10n.loginInvalidEmail;
    if (state is ErrorLoginState) return state.errorMessage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is PasswordResetSentLoginState) Navigator.pop(context);
      },
      builder: (context, state) {
        // O teclado é lido aqui, e não no builder do showModalBottomSheet: a rota
        // modal guarda a página em cache e não reconstruiria o builder.
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SafeArea(
            top: false,
            child: _buildContent(context, state, l10n),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LoginState state, AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s12, AppSizes.s24, AppSizes.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSizes.s40,
              height: AppSizes.s4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppSizes.s2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s24),
          Text(l10n.forgotPasswordTitle, style: AppTypography.title()),
          const SizedBox(height: AppSizes.s8),
          Text(l10n.forgotPasswordDescription, style: AppTypography.subtitle()),
          const SizedBox(height: AppSizes.s24),
          AuthTextField(
            controller: _emailController,
            label: l10n.loginEmailLabel,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [AutofillHints.email],
            errorText: _errorFor(state, l10n),
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: AppSizes.s24),
          ArenaButton(
            title: l10n.forgotPasswordSend,
            height: AppSizes.buttonHeightLarge,
            borderRadius: AppSizes.fieldRadius,
            fontSize: AppSizes.s16,
            buttonColor: AppColors.primary,
            textColor: AppColors.white,
            isLoading: state is SendingPasswordResetLoginState,
            function: _send,
          ),
        ],
      ),
    );
  }
}
