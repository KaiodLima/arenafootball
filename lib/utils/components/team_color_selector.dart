import 'package:flutter/material.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Cor principal e secundária do time: dois seletores e a prévia da camisa.
/// Os valores são hex ("#2E7D32"); vazio = sem cor.
class TeamColorsPicker extends StatelessWidget {
  final String primary;
  final String secondary;
  final ValueChanged<String> onPrimaryChanged;
  final ValueChanged<String> onSecondaryChanged;

  const TeamColorsPicker({
    super.key,
    required this.primary,
    required this.secondary,
    required this.onPrimaryChanged,
    required this.onSecondaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeamColorSelector(
          label: l10n.teamColorPrimary,
          value: primary,
          unavailable: secondary,
          onChanged: onPrimaryChanged,
        ),
        const SizedBox(height: AppSizes.s12),
        TeamColorSelector(
          label: l10n.teamColorSecondary,
          value: secondary,
          unavailable: primary,
          onChanged: onSecondaryChanged,
        ),
        if (primary.isNotEmpty || secondary.isNotEmpty) ...[
          const SizedBox(height: AppSizes.s14),
          Row(
            children: [
              TeamColorsBadge(primary: primary, secondary: secondary, size: AppSizes.s40),
              const SizedBox(width: AppSizes.s10),
              Text(l10n.teamColorPreview, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ],
          ),
        ],
      ],
    );
  }
}

/// Seletor de uma cor, no estilo do seletor de time: fechado parece um campo
/// (bolinha + nome); aberto, uma grade com a paleta. Escolher fecha.
class TeamColorSelector extends StatefulWidget {
  final String label;

  /// Hex escolhido ('' = sem cor).
  final String value;

  /// Hex que não pode ser escolhido aqui (a cor da outra caixa).
  final String unavailable;
  final ValueChanged<String> onChanged;

  const TeamColorSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.unavailable = '',
  });

  @override
  State<TeamColorSelector> createState() => _TeamColorSelectorState();
}

class _TeamColorSelectorState extends State<TeamColorSelector> {
  static const Duration _animation = Duration(milliseconds: 220);
  bool _expanded = false;

  void _select(String hex) {
    widget.onChanged(hex);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = colorFromHex(widget.value);
    final named = TeamColor.fromHex(widget.value);
    final decoration = arenaInputDecoration(
      label: widget.label,
      icon: color == null ? Icons.palette_outlined : null,
      suffix: AnimatedRotation(
        turns: _expanded ? 0.5 : 0,
        duration: _animation,
        child: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
            onTap: () => setState(() => _expanded = !_expanded),
            child: InputDecorator(
              decoration: color == null
                  ? decoration
                  : decoration.copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                        child: _Swatch(color: color, size: AppSizes.s24),
                      ),
                    ),
              isFocused: _expanded,
              isEmpty: color == null,
              child: Text(named?.label(l10n) ?? widget.value, style: AppTypography.body()),
            ),
          ),
        ),
        AnimatedSize(
          duration: _animation,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded ? _buildPalette(l10n) : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildPalette(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: AppSizes.s8,
            crossAxisSpacing: AppSizes.s8,
            childAspectRatio: 0.9,
            children: [
              for (final option in TeamColor.values)
                _ColorOption(
                  color: option.color,
                  label: option.label(l10n),
                  selected: option.hex == widget.value.toUpperCase(),
                  enabled: option.hex != widget.unavailable.toUpperCase(),
                  onTap: () => _select(option.hex),
                ),
            ],
          ),
          if (widget.value.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _select(''),
                icon: const Icon(Icons.format_color_reset_outlined, size: AppSizes.s18),
                label: Text(l10n.teamColorNone),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSizes.s6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
              border: Border.all(color: selected ? AppColors.primary : AppColors.transparent, width: AppSizes.s2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _Swatch(color: color, size: AppSizes.s40),
                    if (selected)
                      Icon(
                        Icons.check_rounded,
                        size: AppSizes.s22,
                        color: isLightColor(color) ? AppColors.textPrimary : AppColors.white,
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.s4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body().copyWith(
                    fontSize: AppSizes.s12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bolinha da cor, com borda fina para o branco aparecer no fundo claro.
class _Swatch extends StatelessWidget {
  final Color color;
  final double size;

  const _Swatch({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyLight),
      ),
    );
  }
}

/// Selo das cores do time: círculo dividido ao meio (principal à esquerda,
/// secundária à direita) com o ícone de camisa. Sem nenhuma cor, não aparece.
class TeamColorsBadge extends StatelessWidget {
  final String primary;
  final String secondary;
  final double size;

  const TeamColorsBadge({super.key, required this.primary, required this.secondary, this.size = AppSizes.s24});

  @override
  Widget build(BuildContext context) {
    final left = colorFromHex(primary) ?? colorFromHex(secondary);
    final right = colorFromHex(secondary) ?? left;
    if (left == null || right == null) return const SizedBox.shrink();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.greyLight),
        gradient: LinearGradient(colors: [left, left, right, right], stops: const [0, 0.5, 0.5, 1]),
      ),
      child: Icon(
        Icons.checkroom_rounded,
        size: size * 0.55,
        color: isLightColor(left) && isLightColor(right) ? AppColors.textPrimary : AppColors.white,
      ),
    );
  }
}
