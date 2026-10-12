import 'package:flutter/material.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Pódio da premiação: 2º à esquerda, 1º no centro (mais alto), 3º à direita,
/// cada um com a cor da medalha e o prêmio. Prêmio vazio aparece como "—".
class PrizePodium extends StatelessWidget {
  final String first;
  final String second;
  final String third;

  /// Rótulos "1º lugar", "2º lugar", "3º lugar".
  final List<String> labels;

  const PrizePodium({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Step(place: 2, label: labels[1], prize: second, color: AppColors.silver, height: AppSizes.s64),
        const SizedBox(width: AppSizes.s8),
        _Step(place: 1, label: labels[0], prize: first, color: AppColors.gold, height: AppSizes.s100),
        const SizedBox(width: AppSizes.s8),
        _Step(place: 3, label: labels[2], prize: third, color: AppColors.bronze, height: AppSizes.s48),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int place;
  final String label;
  final String prize;
  final Color color;
  final double height;

  const _Step({
    required this.place,
    required this.label,
    required this.prize,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final winner = place == 1;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: winner ? AppSizes.s56 : AppSizes.s48,
            height: winner ? AppSizes.s56 : AppSizes.s48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: AppSizes.s2),
            ),
            child: Icon(
              winner ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
              color: color,
              size: winner ? AppSizes.s30 : AppSizes.s24,
            ),
          ),
          const SizedBox(height: AppSizes.s6),
          Text(label, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          const SizedBox(height: AppSizes.s2),
          Text(
            prize.trim().isEmpty ? '—' : prize,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body().copyWith(
              fontSize: winner ? AppSizes.s14 : AppSizes.s12,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withValues(alpha: 0.55)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s10)),
            ),
            child: Text(
              '$place',
              style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
            ),
          ),
        ],
      ),
    );
  }
}
