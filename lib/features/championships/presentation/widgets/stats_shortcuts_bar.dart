import 'package:flutter/material.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_chip_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Rodapé de grupos/classificação com o atalho para a artilharia e as
/// assistências da região/temporada (mesma tela, com o seletor lá dentro).
class StatsShortcutsBar extends StatelessWidget {
  final String region;
  final String season;

  const StatsShortcutsBar({super.key, required this.region, required this.season});

  void _open(BuildContext context, StatsRankingType type) => Navigator.pushNamed(
        context,
        AppRoutes.statsRankingPage,
        arguments: {'type': type, 'region': region, 'season': season},
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s20, offset: Offset(0, -AppSizes.s2))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArenaChipButton(
                title: l10n.statsShortcut,
                icon: Icons.sports_soccer_rounded,
                onPressed: () => _open(context, StatsRankingType.goals),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
