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

/// Prévia em que o usuário enquadra a foto do atleta: arrastar com um dedo
/// move a foto (ela acompanha o dedo) e a pinça dá zoom. Desligado
/// ([enabled] falso, sem foto), só mostra o [child].
class ArtFramingGesture extends StatefulWidget {
  final bool enabled;
  final void Function(double dx, double dy) onMove;
  final void Function(double factor) onZoom;
  final Widget child;

  const ArtFramingGesture({
    super.key,
    required this.enabled,
    required this.onMove,
    required this.onZoom,
    required this.child,
  });

  @override
  State<ArtFramingGesture> createState() => _ArtFramingGestureState();
}

class _ArtFramingGestureState extends State<ArtFramingGesture> {
  double _lastScale = 1;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (_) => _lastScale = 1,
      onScaleUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        final size = box?.size;
        if (size == null || size.isEmpty) return;
        // Arrastar para a direita mostra mais do lado esquerdo da foto.
        final delta = details.focalPointDelta;
        if (delta != Offset.zero) widget.onMove(-delta.dx / size.width * 2.4, -delta.dy / size.height * 2.4);
        if (details.pointerCount > 1 && details.scale != _lastScale) {
          widget.onZoom(details.scale / _lastScale);
          _lastScale = details.scale;
        }
      },
      child: widget.child,
    );
  }
}

/// Dica do enquadramento, o "Centralizar" (só quando a foto já saiu do
/// padrão) e "Usar foto da galeria" / "Voltar à foto do atleta" (a foto do
/// aparelho vale só para a arte).
class ArtFramingHint extends StatelessWidget {
  final String hint;
  final String resetLabel;
  final VoidCallback? onReset;

  /// Botão da foto do aparelho: [photoLabel] + [onPhoto] (nulo = sem botão).
  final String? photoLabel;
  final VoidCallback? onPhoto;
  final bool usingLocalPhoto;

  const ArtFramingHint({
    super.key,
    required this.hint,
    required this.resetLabel,
    this.onReset,
    this.photoLabel,
    this.onPhoto,
    this.usingLocalPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.open_with_rounded, size: AppSizes.s16, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSizes.s4,
            children: [
              if (photoLabel != null && onPhoto != null)
                TextButton.icon(
                  onPressed: onPhoto,
                  icon: Icon(
                    usingLocalPhoto ? Icons.undo_rounded : Icons.add_photo_alternate_outlined,
                    size: AppSizes.s16,
                  ),
                  label: Text(photoLabel!),
                  style: style,
                ),
              if (onReset != null)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.center_focus_strong_rounded, size: AppSizes.s16),
                  label: Text(resetLabel),
                  style: style,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
