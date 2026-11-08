import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Destaques do elenco (como o "top players" dos apps de futebol): artilheiro
/// e garçom da lista escolhida, lado a lado. Sem nenhum, não ocupa espaço.
class SquadSpotlight extends StatelessWidget {
  final PlayerDTO? topScorer;
  final int topScorerGoals;
  final PlayerDTO? topAssister;
  final int topAssisterAssists;
  final Color accent;
  final void Function(PlayerDTO) onTap;

  const SquadSpotlight({
    super.key,
    required this.topScorer,
    required this.topScorerGoals,
    required this.topAssister,
    required this.topAssisterAssists,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      if (topScorer != null)
        _SpotlightCard(
          label: l10n.squadTopScorer,
          icon: Icons.sports_soccer_rounded,
          player: topScorer!,
          value: topScorerGoals,
          accent: accent,
          onTap: () => onTap(topScorer!),
        ),
      if (topAssister != null)
        _SpotlightCard(
          label: l10n.squadTopAssister,
          icon: Icons.assistant_rounded,
          player: topAssister!,
          value: topAssisterAssists,
          accent: accent,
          onTap: () => onTap(topAssister!),
        ),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.s10),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final PlayerDTO player;
  final int value;
  final Color accent;
  final VoidCallback onTap;

  const _SpotlightCard({
    required this.label,
    required this.icon,
    required this.player,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSizes.s12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.s14, color: accent),
              const SizedBox(width: AppSizes.s4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: accent).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 2)),
                child: PlayerAvatar(player: player, size: AppSizes.s40),
              ),
              const Spacer(),
              Text('$value',
                  style: AppTypography.display(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s32)),
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
