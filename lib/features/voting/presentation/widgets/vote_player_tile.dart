import 'package:flutter/material.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha de um jogador na votação: avatar, nome, selo "Seu voto" e o rádio de
/// seleção. Sem [onTap] (convidado) não mostra o rádio.
class VotePlayerTile extends StatelessWidget {
  final PlayerDTO player;
  final bool selected;
  final bool isMyVote;
  final VoidCallback? onTap;

  /// Atleta da própria conta: não pode receber o voto dela (esmaecido, com aviso).
  final bool isSelf;

  const VotePlayerTile({
    super.key,
    required this.player,
    required this.selected,
    required this.isMyVote,
    this.onTap,
    this.isSelf = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSizes.s8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.s16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.transparent, width: AppSizes.s2),
          boxShadow: selected
              ? null
              : const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s10, offset: Offset(0, AppSizes.s2))],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.s16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
              child: Row(
                children: [
                  PlayerAvatar(player: player, size: AppSizes.s44),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: isSelf ? AppColors.textSecondary : AppColors.textPrimary)
                              .copyWith(
                            fontSize: AppSizes.s16,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        if (isSelf)
                          Text(
                            l10n.votingSelfBlocked,
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                      ],
                    ),
                  ),
                  if (isMyVote) ...[
                    const SizedBox(width: AppSizes.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.s10),
                      ),
                      child: Text(
                        l10n.votingYourVote,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(width: AppSizes.s12),
                    _Radio(selected: selected),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;

  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: AppSizes.s24,
      height: AppSizes.s24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.transparent,
        border: Border.all(color: selected ? AppColors.primary : AppColors.greyLight, width: AppSizes.s2),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1 : 0,
        child: const Icon(Icons.check_rounded, size: AppSizes.s16, color: AppColors.white),
      ),
    );
  }
}
