import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Demais colocados (depois do pódio) num card: posição, avatar, nome,
/// escudo + time e o número. Como em tabelas oficiais, a posição só aparece
/// na primeira linha de um empate.
class RankingList extends StatelessWidget {
  final List<RankingEntry> entries;
  final StatsRankingType type;
  final String? Function(String teamName) crestOf;
  final bool Function(RankingEntry entry) isFavorite;

  const RankingList({
    super.key,
    required this.entries,
    required this.type,
    required this.crestOf,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.greyLight),
            _RankingRow(
              entry: entries[i],
              type: type,
              showPosition: i == 0 || entries[i - 1].position != entries[i].position,
              crest: crestOf(entries[i].player.team),
              isFavorite: isFavorite(entries[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final RankingEntry entry;
  final StatsRankingType type;
  final bool showPosition;
  final String? crest;
  final bool isFavorite;

  const _RankingRow({
    required this.entry,
    required this.type,
    required this.showPosition,
    required this.crest,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = type == StatsRankingType.goals ? l10n.statsUnitGoals(entry.value) : l10n.statsUnitAssists(entry.value);

    return Container(
      color: isFavorite ? AppColors.primarySoft : AppColors.transparent,
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s16, AppSizes.s10),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s28,
            child: Text(
              showPosition ? '${entry.position}' : '',
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s14),
            ),
          ),
          PlayerAvatar(player: entry.player, size: AppSizes.s44),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(
                          fontSize: AppSizes.s14,
                          fontWeight: isFavorite ? FontWeight.w800 : null,
                        ),
                      ),
                    ),
                    if (isFavorite) ...[
                      const SizedBox(width: AppSizes.s4),
                      Tooltip(
                        message: l10n.standingsYourTeam,
                        child: const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s16),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.s4),
                Row(
                  children: [
                    TeamCrest(imageUrl: crest, size: AppSizes.s18),
                    const SizedBox(width: AppSizes.s6),
                    Flexible(
                      child: Text(
                        entry.player.team,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.value}', style: AppTypography.title(color: AppColors.primaryDark).copyWith(height: 1.0)),
              Text(unit, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ],
          ),
        ],
      ),
    );
  }
}
