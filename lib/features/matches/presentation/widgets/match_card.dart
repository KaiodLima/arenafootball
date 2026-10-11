import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de uma partida: data/hora/local, times com o placar no meio e a
/// votação (votar quando aberta; ver o eleito quando fechada). Para o admin,
/// um menu com abrir/fechar votação, editar placar e excluir.
class MatchCard extends StatelessWidget {
  final MatchDTO match;
  final bool isAdmin;
  final VoidCallback onVotingTap;
  final VoidCallback onToggleVoting;
  final VoidCallback onEditScore;
  final VoidCallback onDelete;

  const MatchCard({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.onVotingTap,
    required this.onToggleVoting,
    required this.onEditScore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teamStyle = AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16);
    final info = [match.date, match.time, match.venue].where((part) => part.trim().isNotEmpty).join('  ·  ');

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s8, AppSizes.s14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.event_rounded, size: AppSizes.s14, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.s6),
              Expanded(
                child: Text(
                  info,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
              ),
              if (isAdmin)
                CardMenuButton(
                  actions: [
                    CardMenuAction(
                      icon: match.isVotingOpen ? Icons.lock_outline_rounded : Icons.how_to_vote_outlined,
                      label: match.isVotingOpen ? l10n.matchesCloseVoting : l10n.matchesOpenVoting,
                      onSelected: onToggleVoting,
                    ),
                    CardMenuAction(icon: Icons.edit_outlined, label: l10n.matchesEditScore, onSelected: onEditScore),
                    CardMenuAction(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.matchesDeleteMatch,
                      destructive: true,
                      onSelected: onDelete,
                    ),
                  ],
                )
              else
                const SizedBox(height: AppSizes.s40),
            ],
          ),
          const SizedBox(height: AppSizes.s4),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.s8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    match.homeTeam,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: teamStyle,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                  ),
                  child: Text(
                    '${match.homeGoals}  –  ${match.awayGoals}',
                    style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                  ),
                ),
                Expanded(
                  child: Text(match.awayTeam, maxLines: 2, overflow: TextOverflow.ellipsis, style: teamStyle),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s14),
          _VotingChip(isOpen: match.isVotingOpen, onTap: onVotingTap),
        ],
      ),
    );
  }
}

/// "Votar no melhor" (verde, votação aberta) ou "Ver eleito" (contorno).
class _VotingChip extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const _VotingChip({required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final foreground = isOpen ? AppColors.white : AppColors.primaryDark;

    return Material(
      color: isOpen ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: isOpen ? AppColors.primary : AppColors.greyLight)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.how_to_vote_rounded : Icons.workspace_premium_outlined,
                size: AppSizes.s18,
                color: foreground,
              ),
              const SizedBox(width: AppSizes.s6),
              Text(
                isOpen ? l10n.matchesVoteAction : l10n.matchesSeeElected,
                style: AppTypography.label(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
