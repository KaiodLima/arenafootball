import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

// Peças de controle das telas de arte (resultado, divulgação, atleta):
// painel de baixo, linha de chips, bolinha de paleta e botão de ação.

class ArtControlsPanel extends StatelessWidget {
  final List<Widget> children;

  const ArtControlsPanel({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s16, AppSizes.s16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14)],
        ),
        child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: children)),
      );
}

class ArtChipRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const ArtChipRow({super.key, required this.label, required this.children});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: AppSizes.s72,
            child: Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final child in children)
                    Padding(padding: const EdgeInsets.only(right: AppSizes.s6), child: child),
                ],
              ),
            ),
          ),
        ],
      );
}

class ArtShareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const ArtShareAction({super.key, required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.s12),
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.4 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s6),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: AppSizes.s20,
                    backgroundColor: color,
                    child: Icon(icon, color: AppColors.white, size: AppSizes.s20),
                  ),
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Bolinha de paleta: metade na cor de fundo, metade no destaque (no
/// "Times", as duas cores dos times), com o anel quando escolhida.
class ArtPaletteDot extends StatelessWidget {
  final ArtPalette palette;
  final ArtTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ArtPaletteDot({
    super.key,
    required this.palette,
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = palette.resolve(theme);
    final (a, b) = palette == ArtPalette.teams ? (theme.home, theme.away) : (colors.base, colors.accent);
    return Tooltip(
      message: label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: AppSizes.s36,
          height: AppSizes.s36,
          padding: const EdgeInsets.all(AppSizes.s2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.greyLight,
              width: selected ? AppSizes.s2 + 1 : 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [a, a, b, b],
                stops: const [0, 0.5, 0.5, 1],
              ),
            ),
            child: selected ? const Icon(Icons.check_rounded, color: AppColors.white, size: AppSizes.s18) : null,
          ),
        ),
      ),
    );
  }
}
