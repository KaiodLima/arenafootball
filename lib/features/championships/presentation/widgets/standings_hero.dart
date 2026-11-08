import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/group_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Destaque do topo da classificação: selo da letra, "GRUPO A" e os números
/// do grupo (times, jogos, gols) e o líder (escudo, nome, pontos, campanha e
/// saldo). Sem jogos ainda, a frase "a bola ainda não rolou".
class StandingsHero extends StatelessWidget {
  final String group;
  final List<StandingDTO> standings;

  /// O líder é o time do coração? (★)
  final bool leaderIsFavorite;

  const StandingsHero({super.key, required this.group, required this.standings, this.leaderIsFavorite = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = standings.fold<int>(0, (sum, s) => sum + s.games) ~/ 2;
    final goals = standings.fold<int>(0, (sum, s) => sum + s.goalsFor);
    final leader = standings.isEmpty || games == 0 ? null : standings.first;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryStrong],
        ),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, 4))],
      ),
      child: Stack(
        children: [
          // Círculo central do campo, bem apagado.
          Positioned(
            right: -AppSizes.s40,
            bottom: -AppSizes.s50,
            child: Container(
              width: AppSizes.s200,
              height: AppSizes.s200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white.withValues(alpha: 0.07), width: 2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: AppSizes.s40,
                      height: AppSizes.s40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(AppSizes.s10),
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: Text(
                        GroupCard.badgeOf(group),
                        style: const TextStyle(
                          fontFamily: _display,
                          fontSize: AppSizes.s22,
                          color: AppColors.gold,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: Text(
                        l10n.championshipsGroupTitle(group).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: _condensed,
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.s22,
                          letterSpacing: 1.2,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s10),
                Wrap(
                  spacing: AppSizes.s6,
                  runSpacing: AppSizes.s6,
                  children: [
                    _Pill(icon: Icons.shield_rounded, label: l10n.groupsTeamsCount(standings.length)),
                    _Pill(icon: Icons.sports_rounded, label: l10n.groupsGamesCount(games)),
                    _Pill(icon: Icons.sports_soccer_rounded, label: l10n.standingsGoalsCount(goals)),
                  ],
                ),
                const SizedBox(height: AppSizes.s14),
                if (leader == null)
                  Row(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, color: AppColors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(
                        child: Text(
                          l10n.standingsNoGamesYet,
                          style: TextStyle(
                            fontFamily: _condensed,
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.s18,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _Leader(leader: leader, favorite: leaderIsFavorite),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Leader extends StatelessWidget {
  final StandingDTO leader;
  final bool favorite;

  const _Leader({required this.leader, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diff = leader.goalDifference;
    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.s64,
            height: AppSizes.s64,
            padding: const EdgeInsets.all(AppSizes.s6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.s16),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: AppSizes.s10)],
            ),
            child: TeamCrest(imageUrl: leader.imageUrl, size: AppSizes.s50),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s14),
                    const SizedBox(width: AppSizes.s4),
                    Text(
                      l10n.standingsLeader.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: _condensed,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.s12,
                        letterSpacing: 1.8,
                        color: AppColors.gold,
                      ),
                    ),
                    if (favorite) ...[
                      const SizedBox(width: AppSizes.s6),
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s14),
                    ],
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    leader.teamName.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: _display,
                      fontSize: AppSizes.s24,
                      height: 1.2,
                      letterSpacing: 0.5,
                      color: AppColors.white,
                      shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, 2))],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s4),
                Wrap(
                  spacing: AppSizes.s6,
                  runSpacing: AppSizes.s4,
                  children: [
                    _Chip(label: '${leader.points} PTS', strong: true),
                    _Chip(label: l10n.standingsRecord(leader.wins, leader.draws, leader.losses)),
                    _Chip(label: '${l10n.championshipsStandingsGoalDifference} ${diff > 0 ? '+$diff' : '$diff'}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s12, color: AppColors.gold),
          const SizedBox(width: AppSizes.s4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: _condensed,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.s12,
              letterSpacing: 1,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool strong;

  const _Chip({required this.label, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        color: strong ? AppColors.gold : AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.s6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: _condensed,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.s14,
          letterSpacing: 0.6,
          color: strong ? AppColors.textPrimary : AppColors.white,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
