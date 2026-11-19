import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Arte do convite "Conheço esse jogador" (vai como imagem, com a logo do app
/// pelo `ShareImageFrame`, e o texto do convite como legenda): "Você está no
/// Arena Football!", a foto e o nome do atleta, o time/competição, os números
/// e a chamada para criar a conta.
class AthleteInviteCard extends StatelessWidget {
  final PlayerDTO player;
  final String team;
  final String teamCrest;
  final String championship;
  final int goals;
  final int assists;

  const AthleteInviteCard({
    super.key,
    required this.player,
    required this.team,
    this.teamCrest = '',
    this.championship = '',
    this.goals = 0,
    this.assists = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget stat(String value, String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSizes.s12),
          ),
          child: Column(
            children: [
              Text(value,
                  style:
                      const TextStyle(fontFamily: 'Anton', color: AppColors.gold, fontSize: AppSizes.s24, height: 1)),
              Text(label, style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10)),
            ],
          ),
        );
    return Container(
      key: const ValueKey('athlete-invite-card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryStrong],
        ),
        border: Border(top: BorderSide(color: AppColors.gold, width: 3)),
      ),
      child: Column(
        children: [
          Text(
            l10n.athleteInviteCardTitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Anton', color: AppColors.white, fontSize: AppSizes.s24, height: 1.1),
          ),
          const SizedBox(height: AppSizes.s16),
          Container(
            padding: const EdgeInsets.all(AppSizes.s4),
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: PlayerAvatar(player: player, size: AppSizes.s80),
          ),
          const SizedBox(height: AppSizes.s10),
          Text(
            player.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
          ),
          const SizedBox(height: AppSizes.s6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TeamCrest(imageUrl: teamCrest.isEmpty ? null : teamCrest, size: AppSizes.s24),
              const SizedBox(width: AppSizes.s6),
              Flexible(
                child: Text(
                  championship.isEmpty ? team : '$team · $championship',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            ],
          ),
          if (goals > 0 || assists > 0) ...[
            const SizedBox(height: AppSizes.s12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                stat('$goals', l10n.athleteInviteCardGoals),
                const SizedBox(width: AppSizes.s10),
                stat('$assists', l10n.athleteInviteCardAssists),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.s16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s8),
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s20)),
            child: Text(
              l10n.athleteInviteCardCta,
              textAlign: TextAlign.center,
              style: AppTypography.label(color: AppColors.primaryDark)
                  .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
