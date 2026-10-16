import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/domain/account_provider.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Bottom sheet de "Excluir conta": explica o que é apagado e confirma pela
/// senha (conta com e-mail) ou entrando de novo no Google/Apple. Erros
/// aparecem dentro do sheet: um snackbar ficaria escondido atrás dele.
class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({super.key});

  /// Abre o sheet. Devolve true se a conta foi excluída.
  static Future<bool> show(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => const DeleteAccountSheet(),
    );
    return deleted ?? false;
  }

  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final _passwordController = TextEditingController();
  late final AccountProvider _provider = BlocProvider.of<SessionCubit>(context).accountProvider;
  bool _deleting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool get _needsPassword => _provider == AccountProvider.password;

  Future<void> _delete() async {
    if (_needsPassword && _passwordController.text.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).deleteAccountPasswordRequired);
      return;
    }
    setState(() {
      _deleting = true;
      _error = null;
    });
    final failure = await BlocProvider.of<SessionCubit>(context).deleteAccount(
      password: _needsPassword ? _passwordController.text : null,
    );
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, true);
      return;
    }
    final canceled = failure is ErrorWithMessage && failure.code == deleteAccountCanceledCode;
    setState(() {
      _deleting = false;
      _error = canceled ? null : failure.toString();
    });
  }

  String _confirmHint(AppLocalizations l10n) => switch (_provider) {
        AccountProvider.google => l10n.deleteAccountConfirmGoogle,
        AccountProvider.apple => l10n.deleteAccountConfirmApple,
        _ => l10n.deleteAccountConfirmPassword,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
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
              Text(l10n.deleteAccountTitle, style: AppTypography.title()),
              const SizedBox(height: AppSizes.s8),
              Text(l10n.deleteAccountMessage, style: AppTypography.subtitle()),
              const SizedBox(height: AppSizes.s16),
              Text(_confirmHint(l10n), style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.s16),
              if (_needsPassword) ...[
                AuthTextField(
                  controller: _passwordController,
                  label: l10n.loginPasswordLabel,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  errorText: _error,
                  onSubmitted: (_) => _delete(),
                ),
                const SizedBox(height: AppSizes.s24),
              ] else if (_error != null) ...[
                Text(_error!, style: AppTypography.label(color: AppColors.danger)),
                const SizedBox(height: AppSizes.s16),
              ],
              ArenaButton(
                title: l10n.deleteAccountButton,
                height: AppSizes.buttonHeightLarge,
                borderRadius: AppSizes.fieldRadius,
                fontSize: AppSizes.s16,
                buttonColor: AppColors.danger,
                textColor: AppColors.white,
                isLoading: _deleting,
                function: _deleting ? null : _delete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
