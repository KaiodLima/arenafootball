import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Times já cadastrados na região: escudo + nome curto, em grade.
class RegionTeamsStrip extends StatelessWidget {
  final List<TeamDTO> teams;

  /// Destacado (ex.: nome digitado que já existe).
  final String? highlightId;

  const RegionTeamsStrip({super.key, required this.teams, this.highlightId});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.s8,
      runSpacing: AppSizes.s12,
      children: [
        for (final team in teams)
          SizedBox(
            width: AppSizes.s72,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: team.id == highlightId ? AppColors.warning : AppColors.transparent,
                      width: AppSizes.s2,
                    ),
                  ),
                  child: TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s44),
                ),
                const SizedBox(height: AppSizes.s4),
                Text(
                  team.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
