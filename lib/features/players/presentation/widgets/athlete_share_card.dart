import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_colors_background.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card do atleta para compartilhar: cantos recortados nas cores do time (sem
/// time ou sem cores, nas do app), foto, nome, posição, time e as
/// estatísticas com a posição nos rankings da região.
class AthleteShareCard extends StatelessWidget {
  final PlayerDTO player;

  /// Dados do time (escudo e cores); nulo se o jogador está sem time.
  final TeamDTO? team;
  final String season;
  final int? goalsRank;
  final int? assistsRank;
  final int participations;

  const AthleteShareCard({
    super.key,
    required this.player,
    required this.team,
    required this.season,
    required this.goalsRank,
    required this.assistsRank,
    required this.participations,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = TeamPalette.orDefault(team?.primaryColor ?? '', team?.secondaryColor ?? '');
    final text = palette.onBackground;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final position = PlayerPosition.fromKey(player.position);
    final subtitle = [
      if (position != null) playerPositionLabel(l10n, position),
      if (season.isNotEmpty) l10n.athleteCardSeason(season),
    ].join('  ·  ');

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: TeamColorsBackground(
            palette: palette,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final photoSize = constraints.maxHeight * 0.27;
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // No alto à direita (o canto esquerdo é colorido).
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.athleteCardLabel,
                            style: AppTypography.label(color: text).copyWith(
                              fontSize: AppSizes.s12,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s20),
                        ],
                      ),
                      // Nome longo/fonte grande: encolhe o bloco em vez de estourar.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: constraints.maxWidth - AppSizes.s32,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(color: palette.ring, shape: BoxShape.circle),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                                    child: PlayerAvatar(player: player, size: photoSize),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.s10),
                                Text(
                                  player.name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.display(color: text).copyWith(fontSize: AppSizes.s22),
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: AppSizes.s2),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.subtitle(color: text.withValues(alpha: 0.75))
                                        .copyWith(fontSize: AppSizes.s12),
                                  ),
                                ],
                                if (player.team.isNotEmpty) ...[
                                  const SizedBox(height: AppSizes.s8),
                                  _TeamPill(name: player.team, crestUrl: team?.imageUrl, palette: palette),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBlock(
                              value: player.goals,
                              label: l10n.playersSummaryGoals,
                              rank: goalsRank == null ? l10n.athleteNoRank : l10n.athleteRankGoals(goalsRank!),
                              palette: palette,
                            ),
                          ),
                          const SizedBox(width: AppSizes.s10),
                          Expanded(
                            child: _StatBlock(
                              value: player.assists,
                              label: l10n.playersSummaryAssists,
                              rank: assistsRank == null ? l10n.athleteNoRank : l10n.athleteRankAssists(assistsRank!),
                              palette: palette,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.s10),
                      // Embaixo à esquerda (o canto direito é colorido).
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.athleteCardParticipations(participations),
                          maxLines: 1,
                          style: AppTypography.label(color: text).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamPill extends StatelessWidget {
  final String name;
  final String? crestUrl;
  final TeamPalette palette;

  const _TeamPill({required this.name, required this.crestUrl, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s4, AppSizes.s12, AppSizes.s4),
      decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TeamCrest(imageUrl: crestUrl, size: AppSizes.s24),
          const SizedBox(width: AppSizes.s6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: palette.onAccent).copyWith(fontSize: AppSizes.s14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Número grande, o nome da estatística e a posição no ranking.
class _StatBlock extends StatelessWidget {
  final int value;
  final String label;
  final String rank;
  final TeamPalette palette;

  const _StatBlock({required this.value, required this.label, required this.rank, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSizes.s12),
        border: Border.all(color: palette.ring, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label.toUpperCase(),
                maxLines: 1,
                style: AppTypography.label(color: AppColors.textSecondary)
                    .copyWith(fontSize: AppSizes.s10, letterSpacing: 1)),
          ),
          Text(
            '$value',
            style: AppTypography.display(color: palette.ring).copyWith(
              fontSize: AppSizes.s32,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(rank,
                maxLines: 1, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12)),
          ),
        ],
      ),
    );
  }
}
