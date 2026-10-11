import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Campo de busca preenchido (lupa + limpar) para filtrar listas.
class ArenaSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const ArenaSearchField({super.key, required this.hint, required this.onChanged});

  @override
  State<ArenaSearchField> createState() => _ArenaSearchFieldState();
}

class _ArenaSearchFieldState extends State<ArenaSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      style: AppTypography.body(),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.subtitle(),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: AppLocalizations.of(context).commonClear,
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
              ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
