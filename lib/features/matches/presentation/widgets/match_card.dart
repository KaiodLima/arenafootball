import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de uma partida: escudo + time | placar | time + escudo (vencedor em
/// negrito, perdedor esmaecido) e, no rodapé, horário · local e a votação
/// (votar quando aberta; ver o eleito quando fechada). A data fica no
/// cabeçalho do dia, fora do card. Para o admin, um menu com abrir/fechar
/// votação, editar placar e excluir.
class MatchCard extends StatefulWidget {
  final MatchDTO match;
  final bool isAdmin;
  final String? homeCrest;
  final String? awayCrest;

  /// Partida do time do coração do usuário (fundo verde suave + ★).
  final bool isFavorite;

  /// Diz se o time é o do coração, para a ★ ir ao lado certo.
  final bool Function(String teamName) isFavoriteTeam;
  final VoidCallback onVotingTap;
  final VoidCallback onToggleVoting;
  final VoidCallback onEditScore;
  final VoidCallback onDelete;

  /// Mostra o botão de votação (falso na prévia do cadastro).
  final bool showVoting;

  /// Toque no card (admin: abre o "Card de gol" com esta partida).
  final VoidCallback? onTap;

  /// Nome da competição (lista de todas as competições); nulo = sem etiqueta.
  final String? championshipLabel;

  const MatchCard({
    super.key,
    required this.match,
    required this.isAdmin,
    required this.onVotingTap,
    required this.onToggleVoting,
    required this.onEditScore,
    required this.onDelete,
    this.homeCrest,
    this.awayCrest,
    this.isFavorite = false,
    this.isFavoriteTeam = _none,
    this.showVoting = true,
    this.onTap,
    this.championshipLabel,
  });

  static bool _none(String _) => false;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  /// Expandido: mostra os gols com autor e assistência.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final match = widget.match;
    final isAdmin = widget.isAdmin;
    final homeCrest = widget.homeCrest;
    final awayCrest = widget.awayCrest;
    final isFavorite = widget.isFavorite;
    final isFavoriteTeam = widget.isFavoriteTeam;
    final onVotingTap = widget.onVotingTap;
    final onToggleVoting = widget.onToggleVoting;
    final onEditScore = widget.onEditScore;
    final onDelete = widget.onDelete;
    final showVoting = widget.showVoting;
    final onTap = widget.onTap;
    final championshipLabel = widget.championshipLabel;
    final hasScorers = match.goals.any((g) => g.hasScorer);
    final info = [match.time, match.venue].where((part) => part.trim().isNotEmpty).join('  ·  ');
    final homeWon = match.homeGoals > match.awayGoals;
    final awayWon = match.awayGoals > match.homeGoals;

    return ArenaCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Container(
        color: isFavorite ? AppColors.primarySoft : AppColors.transparent,
        padding: EdgeInsets.fromLTRB(AppSizes.s12, isAdmin ? AppSizes.s4 : AppSizes.s16, AppSizes.s4, AppSizes.s12),
        child: Column(
          children: [
            if (championshipLabel != null)
              Padding(
                padding: EdgeInsets.only(top: isAdmin ? AppSizes.s8 : 0, right: AppSizes.s8),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: AppSizes.s14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.s4),
                    Flexible(
                      child: Text(
                        championshipLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
              ),
            if (isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: CardMenuButton(
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
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.s8),
              child: Row(
                children: [
                  Expanded(
                    child: _Team(
                      name: match.homeTeam,
                      crest: homeCrest,
                      lost: awayWon,
                      won: homeWon,
                      isFavorite: isFavoriteTeam(match.homeTeam),
                      alignEnd: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(AppSizes.s10),
                    ),
                    child: Text(
                      '${match.homeGoals} – ${match.awayGoals}',
                      style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                    ),
                  ),
                  Expanded(
                    child: _Team(
                      name: match.awayTeam,
                      crest: awayCrest,
                      lost: homeWon,
                      won: awayWon,
                      isFavorite: isFavoriteTeam(match.awayTeam),
                      alignEnd: false,
                    ),
                  ),
                ],
              ),
            ),
            // Expandido: autores e assistências de cada lado.
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded && hasScorers
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s10, right: AppSizes.s8),
                      child: Column(
                        children: [
                          const Divider(height: 1, color: AppColors.greyLight),
                          const SizedBox(height: AppSizes.s8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _SideGoals(goals: match.goals, side: MatchSide.home, alignEnd: true)),
                              const SizedBox(width: AppSizes.s24),
                              Expanded(child: _SideGoals(goals: match.goals, side: MatchSide.away, alignEnd: false)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: AppSizes.s12),
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.s4, right: AppSizes.s8),
              child: Row(
                children: [
                  if (info.isNotEmpty) ...[
                    const Icon(Icons.schedule_rounded, size: AppSizes.s14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.s4),
                  ],
                  Expanded(
                    child: Text(
                      info,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ),
                  const SizedBox(width: AppSizes.s8),
                  if (hasScorers) ...[
                    _GoalsToggle(expanded: _expanded, onTap: () => setState(() => _expanded = !_expanded)),
                    const SizedBox(width: AppSizes.s6),
                  ],
                  if (showVoting) _VotingChip(isOpen: match.isVotingOpen, onTap: onVotingTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão "Gols ▾/▴" do rodapé: abre/fecha os autores e passes.
class _GoalsToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _GoalsToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: expanded ? l10n.matchCardHideGoals : l10n.matchCardGoals,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_soccer_rounded, size: AppSizes.s14, color: AppColors.primaryDark),
              const SizedBox(width: AppSizes.s4),
              Text(
                l10n.matchCardGoals,
                style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12),
              ),
              Icon(
                expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: AppSizes.s18,
                color: AppColors.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gols de um lado: autor (com "(2)" se repetiu) e as assistências embaixo.
class _SideGoals extends StatelessWidget {
  final List<MatchGoal> goals;
  final MatchSide side;
  final bool alignEnd;

  const _SideGoals({required this.goals, required this.side, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = MatchGoal.summaryOf(goals, side);
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: align,
      children: [
        for (final line in summary)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.s6),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_soccer_rounded, size: AppSizes.s14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.s4),
                    Flexible(
                      child: Text(
                        line.count > 1 ? '${line.scorer} (${line.count})' : line.scorer,
                        textAlign: textAlign,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                      ),
                    ),
                  ],
                ),
                if (line.assists.isNotEmpty)
                  Text(
                    l10n.matchGoalsAssist(line.assists.join(', ')),
                    textAlign: textAlign,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Escudo + nome; do lado da casa o escudo fica junto ao placar.
class _Team extends StatelessWidget {
  final String name;
  final String? crest;
  final bool won;
  final bool lost;
  final bool isFavorite;
  final bool alignEnd;

  const _Team({
    required this.name,
    required this.crest,
    required this.won,
    required this.lost,
    required this.isFavorite,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final text = Flexible(
      child: Text(
        name,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.label(color: lost ? AppColors.textSecondary : AppColors.textPrimary).copyWith(
          fontSize: AppSizes.s14,
          fontWeight: won ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
    final star = isFavorite
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.s2),
            child: Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s14),
          )
        : null;
    final crestWidget = TeamCrest(imageUrl: crest, size: AppSizes.s28);
    const gap = SizedBox(width: AppSizes.s8);

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [if (star != null) star, text, gap, crestWidget]
          : [crestWidget, gap, text, if (star != null) star],
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
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.how_to_vote_rounded : Icons.workspace_premium_outlined,
                size: AppSizes.s16,
                color: foreground,
              ),
              const SizedBox(width: AppSizes.s4),
              Text(
                isOpen ? l10n.matchesVoteAction : l10n.matchesSeeElected,
                style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
