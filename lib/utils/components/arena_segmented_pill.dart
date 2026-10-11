import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Um segmento da [ArenaSegmentedPill]: rótulo e, opcional, um ícone ou
/// widget à esquerda (ex.: escudo).
class ArenaSegment {
  final String label;
  final IconData? icon;
  final Widget? leading;

  const ArenaSegment({required this.label, this.icon, this.leading});
}

/// Seletor em pílula para fundo escuro: o segmento escolhido fica branco com
/// texto escuro; os outros, transparentes com texto branco.
class ArenaSegmentedPill extends StatelessWidget {
  final List<ArenaSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ArenaSegmentedPill({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.whiteMuted, borderRadius: BorderRadius.circular(AppSizes.s24)),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            _Segment(segment: segments[i], selected: i == selectedIndex, onTap: () => onChanged(i)),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final ArenaSegment segment;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({required this.segment, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.white;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: AppSizes.s40,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
            decoration: BoxDecoration(
              color: selected ? AppColors.white : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.s20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (segment.leading != null) ...[segment.leading!, const SizedBox(width: AppSizes.s6)],
                if (segment.icon != null) ...[
                  Icon(segment.icon, size: AppSizes.s18, color: color),
                  const SizedBox(width: AppSizes.s6),
                ],
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: color).copyWith(fontSize: AppSizes.s14),
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
