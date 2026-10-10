import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Card de uma partida: times, placar, data/hora/local e o ícone de votação
/// (votar quando aberta; ver o eleito quando fechada). Para o admin, também
/// abrir/fechar votação, editar placar e excluir.
class MatchCard extends StatelessWidget {
  final MatchDTO match;
  final bool isAdmin;

  /// Linha alternada da lista "todos os jogos" (fundo cinza, nomes brancos).
  final bool striped;
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
    this.striped = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teamColor = striped ? AppColors.white : AppColors.primaryStrong;
    final teamStyle = TextStyle(color: teamColor, fontWeight: FontWeight.bold, fontSize: AppSizes.s18);

    return Card(
      color: striped ? AppColors.blueGreyLight : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s30)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.s8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.s8),
                    child: Column(
                      children: [
                        AutoSizeText(match.homeTeam, textAlign: TextAlign.center, maxLines: 1, style: teamStyle),
                        const SizedBox(height: AppSizes.s4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ScoreBox(goals: match.homeGoals, striped: striped),
                            const SizedBox(width: AppSizes.s8),
                            Text(l10n.matchesVersus, style: teamStyle),
                            const SizedBox(width: AppSizes.s8),
                            _ScoreBox(goals: match.awayGoals, striped: striped),
                          ],
                        ),
                        const SizedBox(height: AppSizes.s4),
                        AutoSizeText(match.awayTeam, textAlign: TextAlign.center, maxLines: 1, style: teamStyle),
                        const SizedBox(height: AppSizes.s16),
                        AutoSizeText(
                          l10n.matchesSchedule(match.date, match.time, match.venue),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.s16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s8, right: AppSizes.s12),
                      child: IconButton(
                        icon: Icon(match.isVotingOpen ? Icons.how_to_vote : Icons.more_vert_outlined),
                        onPressed: onVotingTap,
                      ),
                    ),
                    if (isAdmin) _VotingToggle(isOpen: match.isVotingOpen, onTap: onToggleVoting),
                  ],
                ),
              ],
            ),
            if (isAdmin) ...[
              _AdminAction(icon: Icons.edit, label: l10n.matchesEditScore, onTap: onEditScore),
              _AdminAction(icon: Icons.delete, label: l10n.matchesDeleteMatch, onTap: onDelete),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final int goals;
  final bool striped;

  const _ScoreBox({required this.goals, required this.striped});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minWidth: AppSizes.s32, minHeight: AppSizes.s40),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
      decoration: BoxDecoration(
        color: striped ? AppColors.white : null,
        border: Border.all(color: striped ? AppColors.white : AppColors.primary),
        borderRadius: BorderRadius.circular(AppSizes.s4),
      ),
      child: Text(goals.toString(), style: const TextStyle(fontSize: AppSizes.s20, color: AppColors.black)),
    );
  }
}

/// Botão do admin que abre/fecha a votação (verde quando aberta).
class _VotingToggle extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const _VotingToggle({required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: AppSizes.s50,
        height: AppSizes.s40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOpen ? AppColors.primary : AppColors.white,
          border: const Border(top: BorderSide(width: AppSizes.s2, color: AppColors.black)),
        ),
        child: Icon(Icons.done_all, color: isOpen ? AppColors.white : AppColors.black),
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.s24),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: AppSizes.s2, color: AppColors.black)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.black),
            const SizedBox(width: AppSizes.s8),
            Text(
              label,
              style: const TextStyle(fontSize: AppSizes.s18, fontWeight: FontWeight.bold, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
