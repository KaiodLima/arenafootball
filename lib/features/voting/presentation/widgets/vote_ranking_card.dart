import 'package:flutter/material.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Todos os votados, com a barra da fatia de votos (o eleito em dourado).
class VoteRankingCard extends StatelessWidget {
  final VotingResult result;

  const VoteRankingCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ranking = result.ranking;

    return ArenaCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < ranking.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.greyLight),
            _Row(position: i + 1, tally: ranking[i], share: result.shareOf(ranking[i].votes), isWinner: i == 0),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int position;
  final VoteTally tally;
  final double share;
  final bool isWinner;

  const _Row({required this.position, required this.tally, required this.share, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s16, AppSizes.s12),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s28,
            child: isWinner
                ? const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s20)
                : Text(
                    '$position',
                    textAlign: TextAlign.center,
                    style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s14),
                  ),
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        tally.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Text(
                      '${(share * 100).round()}%',
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                    ),
                    Text(
                      '  ·  ${l10n.votingVotes(tally.votes)}',
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
                if (tally.team.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    tally.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
                ],
                const SizedBox(height: AppSizes.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: AppSizes.s8,
                    backgroundColor: AppColors.background,
                    color: isWinner ? AppColors.gold : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
