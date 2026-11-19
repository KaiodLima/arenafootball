import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_ranking_view.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
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

/// Linha de um craque da rodada: posição (medalha no pódio, "empate" quando
/// divide), foto, nome, selo da vaga e time, e os pontos. Toque = pontuação
/// detalhada. [boxed] = cartão próprio (lista da aba Atletas).
class FantasyTopAthleteRow extends StatelessWidget {
  final FantasyAthleteScoreDTO athlete;
  final int position;
  final bool tied;
  final bool boxed;
  final VoidCallback? onTap;

  const FantasyTopAthleteRow({
    super.key,
    required this.athlete,
    required this.position,
    this.tied = false,
    this.boxed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = fantasyMedalColor(position);
    final ring = fantasyPodiumColor(position);
    final slot = athlete.position == null ? null : FantasySlot.fromKey(athlete.position!);
    final avatar = boxed ? AppSizes.s48 : AppSizes.s36;
    final content = Row(
      children: [
        SizedBox(
          width: AppSizes.s40,
          child: FantasyPositionLabel(position: position, tied: tied, size: AppSizes.s18, color: medal),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            FantasyAvatar(name: athlete.name, photoUrl: athlete.photoUrl, size: avatar, ring: ring),
            if (ring != null && boxed)
              Positioned(
                right: -AppSizes.s4,
                bottom: -AppSizes.s4,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.s2),
                  decoration: BoxDecoration(
                      color: ring, shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 1.5)),
                  child: const Icon(Icons.workspace_premium_rounded, size: AppSizes.s14, color: AppColors.primaryDark),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSizes.s12),
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
              if (slot != null || athlete.team.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s4),
                Row(
                  children: [
                    if (slot != null) ...[FantasySlotBadge(slot: slot), const SizedBox(width: AppSizes.s6)],
                    if (athlete.team.isNotEmpty)
                      Flexible(
                        child: Text(
                          athlete.team,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSizes.s8),
        FantasyPointsColumn(points: athlete.total, size: boxed ? AppSizes.s22 : AppSizes.s20),
        if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: AppSizes.s20),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(bottom: boxed ? AppSizes.s8 : 0),
      child: Material(
        color: boxed ? AppColors.surface : AppColors.transparent,
        shape: boxed
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.s16),
                side: BorderSide(color: ring ?? AppColors.greyLight, width: ring == null ? 1 : 1.5),
              )
            : null,
        child: InkWell(
          key: ValueKey('fantasy-top-${athlete.athleteId}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(boxed ? AppSizes.s16 : AppSizes.s12),
          child: Padding(
            padding: boxed
                ? const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s6, AppSizes.s10)
                : const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s4),
            child: content,
          ),
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
              FantasyTopAthleteRow(
                athlete: top[i],
                position: positions[i],
                tied: FantasyRankingView.isTied(positions, i),
                onTap: () => onAthleteTap(top[i]),
              ),
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
