import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Decoração dos campos preenchidos das telas de entrada (texto e dropdown).
InputDecoration authInputDecoration({
  required String label,
  required IconData icon,
  String? errorText,
  Widget? suffix,
}) =>
    arenaInputDecoration(label: label, icon: icon, errorText: errorText, suffix: suffix);

/// Campo preenchido com ícone interno. Com [isPassword], ganha o botão de
/// mostrar/ocultar a senha.
class AuthTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool isPassword;
  final Iterable<String>? autofillHints;

  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.isPassword = false,
    this.autofillHints,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.isPassword && _obscured,
      autofillHints: widget.autofillHints,
      style: AppTypography.body(),
      cursorColor: AppColors.primary,
      decoration: authInputDecoration(
        label: widget.label,
        icon: widget.icon,
        errorText: widget.errorText,
        // Fora da ordem de foco: o "próximo" do teclado deve pular para o campo seguinte.
        suffix: widget.isPassword
            ? ExcludeFocus(
                child: IconButton(
                  tooltip: _obscured ? l10n.loginShowPassword : l10n.loginHidePassword,
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: AppSizes.s20,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
