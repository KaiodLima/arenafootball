import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Placar da partida para fundo escuro: escudo e nome de cada time com o
/// placar no meio; o perdedor fica esmaecido.
class MatchScoreHeader extends StatelessWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;

  const MatchScoreHeader({super.key, required this.match, this.homeCrest, this.awayCrest});

  @override
  Widget build(BuildContext context) {
    final homeLost = match.homeGoals < match.awayGoals;
    final awayLost = match.awayGoals < match.homeGoals;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _Team(name: match.homeTeam, crest: homeCrest, lost: homeLost)),
        Padding(
          padding: const EdgeInsets.only(top: AppSizes.s10),
          child: Text(
            '${match.homeGoals} – ${match.awayGoals}',
            style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s36),
          ),
        ),
        Expanded(child: _Team(name: match.awayTeam, crest: awayCrest, lost: awayLost)),
      ],
    );
  }
}

class _Team extends StatelessWidget {
  final String name;
  final String? crest;
  final bool lost;

  const _Team({required this.name, required this.crest, required this.lost});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamCrest(imageUrl: crest, size: AppSizes.s56),
        const SizedBox(height: AppSizes.s8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: lost ? AppColors.whiteSoft : AppColors.white).copyWith(
            fontSize: AppSizes.s14,
            fontWeight: lost ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
