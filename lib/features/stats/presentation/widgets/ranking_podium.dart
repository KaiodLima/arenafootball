import 'package:flutter/material.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cor da medalha de uma posição do pódio.
Color medalColor(int position) => switch (position) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };

/// Pódio dos até 3 primeiros, na ordem visual 2º · 1º · 3º, para fundo
/// escuro. Os degraus têm alturas fixas pela ordem; a medalha segue a
/// posição (empatados levam a mesma).
class RankingPodium extends StatelessWidget {
  final List<RankingEntry> podium;
  final StatsRankingType type;
  final String? Function(String teamName) crestOf;
  final bool Function(RankingEntry entry) isFavorite;

  const RankingPodium({
    super.key,
    required this.podium,
    required this.type,
    required this.crestOf,
    required this.isFavorite,
  });

  static const List<double> _stepHeights = [AppSizes.s100, AppSizes.s72, AppSizes.s56];

  @override
  Widget build(BuildContext context) {
    // Índices em `podium` na ordem em que aparecem: 2º, 1º, 3º.
    final order = [if (podium.length > 1) 1, 0, if (podium.length > 2) 2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final index in order)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.s150),
              child: _PodiumPlace(
                entry: podium[index],
                type: type,
                crest: crestOf(podium[index].player.team),
                isFavorite: isFavorite(podium[index]),
                avatarSize: index == 0 ? AppSizes.s80 : AppSizes.s64,
                stepHeight: _stepHeights[index],
              ),
            ),
          ),
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final RankingEntry entry;
  final StatsRankingType type;
  final String? crest;
  final bool isFavorite;
  final double avatarSize;
  final double stepHeight;

  const _PodiumPlace({
    required this.entry,
    required this.type,
    required this.crest,
    required this.isFavorite,
    required this.avatarSize,
    required this.stepHeight,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = medalColor(entry.position);
    final unit = type == StatsRankingType.goals ? l10n.statsUnitGoals(entry.value) : l10n.statsUnitAssists(entry.value);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: medal, width: AppSizes.s4)),
                // Fundo branco: o avatar de iniciais é translúcido e sumiria no topo escuro.
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: PlayerAvatar(player: entry.player, size: avatarSize),
                ),
              ),
              Positioned(
                bottom: -AppSizes.s10,
                child: Container(
                  width: AppSizes.s24,
                  height: AppSizes.s24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: medal,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark, width: AppSizes.s2),
                  ),
                  child: Text(
                    '${entry.position}',
                    style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  entry.player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                ),
              ),
              if (isFavorite) ...[
                const SizedBox(width: AppSizes.s2),
                Tooltip(
                  message: l10n.standingsYourTeam,
                  child: const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s16),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.s4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s18),
              const SizedBox(width: AppSizes.s4),
              Flexible(
                child: Text(
                  entry.player.team,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s10),
          Container(
            height: stepHeight,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.white.withValues(alpha: 0.16), AppColors.white.withValues(alpha: 0.04)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s14)),
            ),
            child: Column(
              children: [
                // Faixa da medalha no topo do degrau.
                Container(height: AppSizes.s4, color: medal),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${entry.value}',
                        style: AppTypography.display(color: AppColors.white).copyWith(height: 1.0),
                      ),
                      Text(
                        unit,
                        style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
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
