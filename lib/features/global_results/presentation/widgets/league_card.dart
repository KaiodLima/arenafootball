import 'package:flutter/material.dart';
import 'package:arena_soccer/features/global_results/domain/entities/league_group.dart';
import 'package:arena_soccer/features/global_results/presentation/widgets/global_match_row.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de uma liga: bandeira + "País · Liga" e as partidas.
class LeagueCard extends StatelessWidget {
  final LeagueGroup group;

  const LeagueCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // O site escreve "England - Premier League".
    final parts = group.league.split(' - ');
    final country = parts.length > 1 ? parts.first.trim() : '';
    final league = parts.length > 1 ? parts.sublist(1).join(' - ').trim() : group.league;

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      child: Column(
        children: [
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s10, AppSizes.s14, AppSizes.s10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s2),
                  child: group.flag != null
                      ? Image.memory(
                          group.flag!,
                          width: AppSizes.s22,
                          height: AppSizes.s16,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => const _Globe(),
                        )
                      : const _Globe(),
                ),
                const SizedBox(width: AppSizes.s10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (country.isNotEmpty)
                          TextSpan(
                              text: '$country · ', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                        TextSpan(
                            text: league,
                            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < group.matches.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.greyLight),
            GlobalMatchRow(
              key: ValueKey('${group.matches[i].homeTeam}|${group.matches[i].awayTeam}'),
              match: group.matches[i],
            ),
          ],
        ],
      ),
    );
  }
}

class _Globe extends StatelessWidget {
  const _Globe();

  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.public_rounded, size: AppSizes.s18, color: AppColors.textSecondary);
}
