import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cor da medalha do [position]º (1º ouro, 2º prata, 3º bronze; nula = sem).
Color? fantasyMedalColor(int position) => switch (position) {
      1 => AppColors.medalGoldDark,
      2 => AppColors.medalSilverDark,
      3 => AppColors.medalBronzeDark,
      _ => null,
    };

/// Posições da lista de atletas: empate no total = mesma posição.
List<int> fantasyAthletePositions(List<FantasyAthleteScoreDTO> athletes) {
  final positions = <int>[];
  for (var i = 0; i < athletes.length; i++) {
    positions.add(i > 0 && athletes[i].total == athletes[i - 1].total ? positions[i - 1] : i + 1);
  }
  return positions;
}

/// Linha de um craque da rodada: posição (medalha no pódio), foto, nome,
/// vaga e time, e os pontos. Toque = pontuação detalhada.
class FantasyTopAthleteRow extends StatelessWidget {
  final FantasyAthleteScoreDTO athlete;
  final int position;
  final VoidCallback? onTap;

  const FantasyTopAthleteRow({super.key, required this.athlete, required this.position, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = fantasyMedalColor(position);
    final slot = athlete.position == null ? '' : fantasyPositionLabelOfKey(l10n, athlete.position!);
    final subtitle = [if (slot.isNotEmpty) slot, if (athlete.team.isNotEmpty) athlete.team].join(' · ');
    return InkWell(
      key: ValueKey('fantasy-top-${athlete.athleteId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.s12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s4),
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.s32,
              child: Text('$positionº', style: hubDisplay(AppSizes.s16, medal ?? AppColors.textSecondary)),
            ),
            FantasyAvatar(name: athlete.name, photoUrl: athlete.photoUrl, size: AppSizes.s36, ring: medal),
            const SizedBox(width: AppSizes.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athlete.name.isEmpty ? l10n.fantasyUnknownAthlete : athlete.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                ],
              ),
            ),
            Text(fantasyPointsLabel(athlete.total), style: hubDisplay(AppSizes.s20, AppColors.primaryDark)),
            const SizedBox(width: AppSizes.s4),
            Text('pts', style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s10)),
          ],
        ),
      ),
    );
  }
}

/// Card "Craques da rodada N" (tela de escalação): os 5 primeiros e "Ver todos".
class FantasyTopAthletesCard extends StatelessWidget {
  final int round;
  final List<FantasyAthleteScoreDTO> athletes;
  final ValueChanged<FantasyAthleteScoreDTO> onAthleteTap;
  final VoidCallback onSeeAll;

  const FantasyTopAthletesCard({
    super.key,
    required this.round,
    required this.athletes,
    required this.onAthleteTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = athletes.take(5).toList();
    final positions = fantasyAthletePositions(top);
    return Container(
      key: const ValueKey('fantasy-top-athletes'),
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.medalGoldDark),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(l10n.fantasyTopAthletesTitle(round),
                    style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
              child: Text(l10n.fantasyTopAthletesEmpty, style: AppTypography.subtitle()),
            )
          else
            for (var i = 0; i < top.length; i++)
              FantasyTopAthleteRow(athlete: top[i], position: positions[i], onTap: () => onAthleteTap(top[i])),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('fantasy-top-see-all'),
              onPressed: onSeeAll,
              child: Text(l10n.fantasySeeAll),
            ),
          ),
        ],
      ),
    );
  }
}
