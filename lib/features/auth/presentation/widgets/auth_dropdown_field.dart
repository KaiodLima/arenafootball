import 'package:flutter/material.dart';
import 'package:arena_soccer/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Dropdown no mesmo estilo preenchido do [AuthTextField].
class AuthDropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const AuthDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = items.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      // A lista chega depois (Firestore): a key recria o campo com o valor novo.
      key: ValueKey('$label-$selected-${items.length}'),
      initialValue: selected,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      dropdownColor: AppColors.surface,
      style: AppTypography.body(),
      decoration: authInputDecoration(label: label, icon: icon),
      onChanged: items.isEmpty
          ? null
          : (newValue) {
              if (newValue != null) onChanged(newValue);
            },
      items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
    );
  }
}
