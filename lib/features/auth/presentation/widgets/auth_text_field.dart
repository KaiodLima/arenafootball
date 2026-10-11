import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Decoração dos campos preenchidos das telas de entrada (texto e dropdown).
InputDecoration authInputDecoration({
  required String label,
  required IconData icon,
  String? errorText,
  Widget? suffix,
}) {
  InputBorder border(Color color, double width) => _FilledFieldBorder(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        borderSide: width == 0 ? BorderSide.none : BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    errorText: errorText,
    errorMaxLines: 2,
    filled: true,
    fillColor: AppColors.inputFill,
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: AppSizes.s20),
    suffixIcon: suffix,
    labelStyle: AppTypography.subtitle(),
    floatingLabelStyle: AppTypography.label(),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
    border: border(AppColors.transparent, 0),
    enabledBorder: border(AppColors.transparent, 0),
    focusedBorder: border(AppColors.primary, 1.5),
    errorBorder: border(AppColors.danger, 1),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// Contorno arredondado que se comporta como campo preenchido: com
/// `isOutline` falso o rótulo flutua *dentro* do campo (e não recortado na
/// linha da borda, como no `OutlineInputBorder`).
class _FilledFieldBorder extends OutlineInputBorder {
  const _FilledFieldBorder({super.borderSide, super.borderRadius});

  @override
  bool get isOutline => false;

  // Sem a brecha que o contorno abre para o rótulo: aqui o rótulo fica dentro.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    super.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  _FilledFieldBorder copyWith({BorderSide? borderSide, BorderRadius? borderRadius, double? gapPadding}) {
    return _FilledFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

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
