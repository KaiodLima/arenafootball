import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Ações da AppBar de grupos/classificação: atalhos para a artilharia e
/// para os líderes de assistência da região/temporada.
List<Widget> statsShortcutActions(BuildContext context, {required String region, required String season}) {
  void open(StatsRankingType type) => Navigator.pushNamed(
        context,
        AppRoutes.statsRankingPage,
        arguments: {'type': type, 'region': region, 'season': season},
      );

  return [
    IconButton(
      color: AppColors.white,
      icon: const Icon(Icons.sports_soccer),
      onPressed: () => open(StatsRankingType.goals),
    ),
    IconButton(
      color: AppColors.white,
      icon: const Icon(Icons.star_border),
      onPressed: () => open(StatsRankingType.assists),
    ),
  ];
}
