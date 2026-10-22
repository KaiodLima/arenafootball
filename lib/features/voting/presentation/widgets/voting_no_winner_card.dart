import 'package:flutter/material.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/voting_outcome.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Votação sem eleito: o motivo (mínimo de votos, porcentagem ou empate) e as
/// regras para eleger, no lugar do cartão do eleito.
class VotingNoWinnerCard extends StatelessWidget {
  final VotingOutcome? outcome;

  const VotingNoWinnerCard({super.key, required this.outcome});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final outcome = this.outcome;
    final rules = outcome?.rules ?? const VotingRulesDTO();
    final reason = switch (outcome?.reason) {
      VotingOutcomeReason.noMajority => l10n.votingNoWinnerNoMajority(rules.minPercent, outcome!.leaderPercent),
      VotingOutcomeReason.tie => l10n.votingNoWinnerTie,
      _ => l10n.votingNoWinnerNotEnough(rules.minVotes, outcome?.totalVotes ?? 0),
    };

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSizes.s20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.how_to_vote_outlined, color: AppColors.primaryDark, size: AppSizes.s32),
          ),
          const SizedBox(height: AppSizes.s12),
          Text(
            l10n.votingNoWinnerTitle,
            textAlign: TextAlign.center,
            style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
          ),
          const SizedBox(height: AppSizes.s6),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
          ),
          const SizedBox(height: AppSizes.s10),
          Text(
            l10n.votingRulesHint(rules.minVotes, rules.minPercent),
            textAlign: TextAlign.center,
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}
