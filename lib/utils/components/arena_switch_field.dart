import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Rótulo + switch (ex.: "Exibir notícia"). O valor fica com quem chama.
class ArenaSwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color inactiveTextColor;

  const ArenaSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.inactiveTextColor = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.s24,
                fontWeight: FontWeight.bold,
                color: value ? AppColors.primary : inactiveTextColor,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}
