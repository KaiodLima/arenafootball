import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Card de gol do feed: placar + imagem da bola na rede.
class GoalCard extends StatelessWidget {
  final NewsDTO news;

  const GoalCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height * 0.12;
    final border = Border.all(color: AppColors.primary, width: AppSizes.s2);
    const left = BorderRadius.horizontal(left: Radius.circular(AppSizes.s24));
    const right = BorderRadius.horizontal(right: Radius.circular(AppSizes.s24));

    return Row(
      children: [
        Expanded(
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
            decoration: BoxDecoration(color: AppColors.whiteMuted, border: border, borderRadius: left),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${news.homeTeam} ${news.homeGoals} x ${news.awayGoals} ${news.awayTeam}',
                style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Container(
          height: height,
          width: size.width * 0.18,
          decoration: BoxDecoration(
            image: const DecorationImage(image: AssetImage(AppImages.ballInNet), fit: BoxFit.cover),
            border: border,
            borderRadius: right,
          ),
        ),
      ],
    );
  }
}
