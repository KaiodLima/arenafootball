import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Elenco atual do time: foto/iniciais + nome curto, em grade. O jogador de
/// [highlightId] (nome repetido) ganha contorno âmbar.
class SquadStrip extends StatelessWidget {
  final List<PlayerDTO> players;
  final String? highlightId;

  const SquadStrip({super.key, required this.players, this.highlightId});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.s8,
      runSpacing: AppSizes.s12,
      children: [
        for (final player in players)
          SizedBox(
            width: AppSizes.s72,
            child: Column(
              children: [
                DecoratedBox(
                  // Por cima: a foto/escudo cobriria uma borda desenhada atrás.
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          player.id.isNotEmpty && player.id == highlightId ? AppColors.warning : AppColors.transparent,
                      width: AppSizes.s2,
                    ),
                  ),
                  child: PlayerAvatar(player: player, size: AppSizes.s44),
                ),
                const SizedBox(height: AppSizes.s4),
                Text(
                  player.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
