import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Destaque do eleito: foto com anel dourado e troféu, nome, time, gols e
/// assistências na temporada e os votos recebidos.
class ElectedPlayerCard extends StatelessWidget {
  final ElectedPlayer elected;

  /// Fração dos votos (0–1) que o eleito recebeu.
  final double share;

  const ElectedPlayerCard({super.key, required this.elected, required this.share});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = PlayerDTO(name: elected.playerName, team: elected.team, imageUrl: elected.playerImageUrl);
    final hasStats = elected.goals > 0 || elected.assists > 0;

    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s24, AppSizes.s20, AppSizes.s20),
      child: Column(
        children: [
          Text(
            l10n.votingElectedTitle.toUpperCase(),
            style: AppTypography.label(color: AppColors.textSecondary).copyWith(
              fontSize: AppSizes.s12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.s16),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: AppSizes.s4),
                  boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: AppSizes.s24)],
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: PlayerAvatar(player: player, size: AppSizes.s120),
                ),
              ),
              Positioned(
                bottom: -AppSizes.s14,
                child: Container(
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: AppSizes.s4),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: AppSizes.s18),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s24),
          Text(
            elected.playerName,
            textAlign: TextAlign.center,
            style: AppTypography.display().copyWith(fontSize: AppSizes.s24),
          ),
          if (elected.team.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TeamCrest(imageUrl: elected.teamImageUrl, size: AppSizes.s22),
                const SizedBox(width: AppSizes.s6),
                Flexible(
                  child: Text(
                    elected.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14),
                  ),
                ),
              ],
            ),
          ],
          if (hasStats) ...[
            const SizedBox(height: AppSizes.s12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatPill(icon: Icons.sports_soccer_rounded, value: elected.goals),
                const SizedBox(width: AppSizes.s8),
                StatPill(icon: Icons.assistant_rounded, value: elected.assists),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.s16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSizes.s20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.how_to_vote_rounded, size: AppSizes.s18, color: AppColors.textPrimary),
                const SizedBox(width: AppSizes.s6),
                Text(
                  l10n.votingVotes(elected.votes),
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                ),
                Text(
                  '  ·  ${l10n.votingShareOfVotes((share * 100).round())}',
                  style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
