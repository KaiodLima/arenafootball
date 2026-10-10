import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Dropdown de texto com contorno verde (região, time...).
class ArenaDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final IconData icon;

  const ArenaDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon = Icons.arrow_downward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.s4),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizes.s4),
      ),
      child: DropdownButton<String>(
        value: items.contains(value) ? value : null,
        icon: Icon(icon, color: AppColors.primary),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: AppColors.black, fontSize: AppSizes.s18),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      ),
    );
  }
}
