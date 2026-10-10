import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Campo de texto padrão do app (contorno, ícone à esquerda e erro opcional).
class ArenaTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final Function(String)? onChaged;
  final String? Function()? errorText;
  final Widget? icon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool? obscureText;
  final bool autofocus;
  final int? maxLines;

  const ArenaTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.onChaged,
    this.errorText,
    this.icon,
    this.keyboardType,
    this.controller,
    this.obscureText,
    this.autofocus = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final error = errorText?.call();
    return TextField(
      controller: controller,
      onChanged: onChaged,
      keyboardType: keyboardType,
      autofocus: autofocus,
      maxLines: maxLines,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error == null ? AppColors.primary : AppColors.danger),
        ),
        labelText: labelText,
        hintText: hintText,
        errorText: error,
        icon: icon,
      ),
    );
  }
}
