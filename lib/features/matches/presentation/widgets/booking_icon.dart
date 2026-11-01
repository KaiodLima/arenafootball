import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cartão amarelo/vermelho desenhado (retângulo arredondado).
class BookingIcon extends StatelessWidget {
  final BookingType type;
  final double size;

  const BookingIcon({super.key, required this.type, this.size = AppSizes.s18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.7,
      height: size,
      decoration: BoxDecoration(
        color: type == BookingType.yellow ? AppColors.gold : AppColors.danger,
        borderRadius: BorderRadius.circular(AppSizes.s2),
      ),
    );
  }
}
