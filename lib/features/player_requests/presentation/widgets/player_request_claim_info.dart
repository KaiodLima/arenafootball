import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Faixa "diz ser o atleta X · N gols" dos pedidos de vínculo (painel do admin
/// e pedidos do dono do time). [player] nulo = atleta fora da lista carregada.
class PlayerRequestClaimInfo extends StatelessWidget {
  final PlayerRequestDTO request;
  final PlayerDTO? player;

  const PlayerRequestClaimInfo({super.key, required this.request, this.player});

  /// Atleta reivindicado pelo [request] em [players].
  static PlayerDTO? find(PlayerRequestDTO request, List<PlayerDTO> players) {
    if (!request.isClaim) return null;
    for (final p in players) {
      if (p.id == request.claimedPlayerId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s10),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s12)),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.primaryDark, size: AppSizes.s20),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Text(
              l10n.playerRequestsClaimBadge(player?.name ?? request.name, player?.goals ?? 0),
              style: AppTypography.body(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
            ),
          ),
        ],
      ),
    );
  }
}
