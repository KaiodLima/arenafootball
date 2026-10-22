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
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Momento da partida para o centro do card: antes do jogo (horário grande e
/// o dia) ou jogada (placar). Antes = sem gol e, se for hoje, antes da hora.
class MatchCardStatus {
  final bool upcoming;

  /// Dias até a partida (0 = hoje, 1 = amanhã); só vale antes do jogo.
  final int dayOffset;

  const MatchCardStatus._({required this.upcoming, this.dayOffset = 0});

  static const played = MatchCardStatus._(upcoming: false);

  static MatchCardStatus of(MatchDTO match, DateTime now) {
    if (match.homeGoals > 0 || match.awayGoals > 0 || match.goals.isNotEmpty) return played;
    final parts = match.date.split('/');
    final day = int.tryParse(parts.first.trim());
    final month = parts.length > 1 ? int.tryParse(parts[1].trim()) : null;
    if (day == null || month == null) return played;
    final year = parts.length > 2 ? int.tryParse(parts[2].trim()) : null;
    final today = DateTime.utc(now.year, now.month, now.day);
    var date = DateTime.utc(year ?? now.year, month, day);
    // Data sem ano: janeiro visto em dezembro é do ano que vem.
    if (year == null && date.difference(today).inDays < -180) date = DateTime.utc(now.year + 1, month, day);
    final offset = date.difference(today).inDays;
    if (offset < 0) return played;
    if (offset == 0) {
      final time = match.time.split(':');
      final hour = int.tryParse(time.first.trim());
      final minute = time.length > 1 ? int.tryParse(time[1].trim()) : 0;
      if (hour != null && minute != null && !now.isBefore(DateTime(now.year, now.month, now.day, hour, minute))) {
        return played;
      }
    }
    return MatchCardStatus._(upcoming: true, dayOffset: offset);
  }
}

/// Card de uma partida, com o placar no centro: escudos grandes e nomes
/// embaixo (vencedor em negrito, perdedor esmaecido), uma faixa na cor de cada
/// time nas laterais e, antes do jogo, o horário no lugar do placar. Em cima,
/// a competição e o menu do admin (abrir/fechar votação, editar placar,
/// excluir); embaixo, o local, os gols (expandem autores e passes) e a votação.
/// A data fica no cabeçalho do dia, fora do card.
class MatchCard extends StatefulWidget {
  final MatchDTO match;
  final bool isAdmin;
  final String? homeCrest;
  final String? awayCrest;

  /// Cor principal de cada time (faixa lateral e anel do escudo); nula = verde do app.
  final Color? homeColor;
  final Color? awayColor;

  /// Partida do time do coração do usuário (borda verde + ★).
  final bool isFavorite;

  /// Diz se o time é o do coração, para a ★ ir ao lado certo.
  final bool Function(String teamName) isFavoriteTeam;
  final VoidCallback onVotingTap;
  final VoidCallback onToggleVoting;
  final VoidCallback onEditScore;
  final VoidCallback onDelete;

  /// Mostra o botão de votação (falso na prévia do cadastro).
  final bool showVoting;

  /// Toque no card (abre os detalhes da partida).
  final VoidCallback? onTap;

  /// Nome da competição (lista de todas as competições); nulo = sem etiqueta.
  final String? championshipLabel;

  /// Admin: "Lançar card de gol" no menu (nulo = sem a ação).
  final VoidCallback? onGoalCard;

  /// Agora (só para teste).
  final DateTime? now;

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
    this.homeColor,
    this.awayColor,
    this.isFavorite = false,
    this.isFavoriteTeam = _none,
    this.showVoting = true,
    this.onTap,
    this.championshipLabel,
    this.onGoalCard,
    this.now,
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
    final championshipLabel = widget.championshipLabel;
    // Sem cor = verde do app; cor clara (branco) some no card e vira cinza.
    Color accent(Color? color) => color == null
        ? AppColors.primary
        : isLightColor(color)
            ? AppColors.greyLight
            : color;
    final homeColor = accent(widget.homeColor);
    final awayColor = accent(widget.awayColor);
    final hasScorers = match.goals.any((g) => g.hasScorer);
    final status = MatchCardStatus.of(match, widget.now ?? DateTime.now());
    final homeWon = !status.upcoming && match.homeGoals > match.awayGoals;
    final awayWon = !status.upcoming && match.awayGoals > match.homeGoals;
    final venue = match.venue.trim();
    final hasTop = championshipLabel != null || isAdmin;

    Widget stripe(Color color) => Container(
          width: AppSizes.s4,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.s2)),
        );

    final content = Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.s16, hasTop ? AppSizes.s4 : AppSizes.s16, AppSizes.s16, AppSizes.s12),
      child: Column(
        children: [
          if (hasTop)
            SizedBox(
              height: AppSizes.s40,
              child: Row(
                children: [
                  if (championshipLabel != null) ...[
                    const Icon(Icons.emoji_events_outlined, size: AppSizes.s14, color: AppColors.textSecondary),
                    const SizedBox(width: AppSizes.s4),
                    Expanded(
                      child: Text(
                        championshipLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (isAdmin)
                    CardMenuButton(
                      actions: [
                        CardMenuAction(
                          icon: match.isVotingOpen ? Icons.lock_outline_rounded : Icons.how_to_vote_outlined,
                          label: match.isVotingOpen ? l10n.matchesCloseVoting : l10n.matchesOpenVoting,
                          onSelected: widget.onToggleVoting,
                        ),
                        CardMenuAction(
                          icon: Icons.edit_outlined,
                          label: l10n.matchesEditScore,
                          onSelected: widget.onEditScore,
                        ),
                        if (widget.onGoalCard != null)
                          CardMenuAction(
                            icon: Icons.sports_soccer_rounded,
                            label: l10n.matchDetailsGoalCard,
                            onSelected: widget.onGoalCard!,
                          ),
                        CardMenuAction(
                          icon: Icons.delete_outline_rounded,
                          label: l10n.matchesDeleteMatch,
                          destructive: true,
                          onSelected: widget.onDelete,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Team(
                  name: match.homeTeam,
                  crest: widget.homeCrest,
                  color: homeColor,
                  won: homeWon,
                  lost: awayWon,
                  isFavorite: widget.isFavoriteTeam(match.homeTeam),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.s8),
                child: _Center(match: match, status: status),
              ),
              Expanded(
                child: _Team(
                  name: match.awayTeam,
                  crest: widget.awayCrest,
                  color: awayColor,
                  won: awayWon,
                  lost: homeWon,
                  isFavorite: widget.isFavoriteTeam(match.awayTeam),
                ),
              ),
            ],
          ),
          // Expandido: autores e assistências de cada lado.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded && hasScorers
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSizes.s10),
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
          Row(
            children: [
              if (venue.isNotEmpty) ...[
                const Icon(Icons.place_outlined, size: AppSizes.s14, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.s4),
              ],
              Expanded(
                child: Text(
                  venue,
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
              if (widget.showVoting) _VotingChip(isOpen: match.isVotingOpen, onTap: widget.onVotingTap),
            ],
          ),
        ],
      ),
    );

    return ArenaCard(
      onTap: widget.onTap,
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Container(
        foregroundDecoration: widget.isFavorite
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.primary, width: AppSizes.s2),
              )
            : null,
        child: Stack(
          children: [
            content,
            Positioned(left: AppSizes.s6, top: AppSizes.s16, bottom: AppSizes.s16, child: stripe(homeColor)),
            Positioned(right: AppSizes.s6, top: AppSizes.s16, bottom: AppSizes.s16, child: stripe(awayColor)),
          ],
        ),
      ),
    );
  }
}

/// Centro do card: placar grande com a hora embaixo ou, antes do jogo, a hora
/// grande com "HOJE"/"AMANHÃ"/a data.
class _Center extends StatelessWidget {
  final MatchDTO match;
  final MatchCardStatus status;

  const _Center({required this.match, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = match.time.trim();
    final big = status.upcoming ? (time.isEmpty ? '--:--' : time) : '${match.homeGoals} × ${match.awayGoals}';
    final small = status.upcoming
        ? switch (status.dayOffset) {
            0 => l10n.matchCardToday,
            1 => l10n.matchCardTomorrow,
            _ => match.date.trim(),
          }
        : time;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: AppSizes.s100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
        child: Column(
          children: [
            Text(
              big,
              maxLines: 1,
              style: AppTypography.display(color: status.upcoming ? AppColors.primaryDark : AppColors.textPrimary)
                  .copyWith(fontSize: AppSizes.s28, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            if (small.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                decoration: status.upcoming
                    ? BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s8))
                    : null,
                child: Text(
                  small,
                  style: AppTypography.label(color: status.upcoming ? AppColors.primaryDark : AppColors.textSecondary)
                      .copyWith(fontSize: AppSizes.s12, letterSpacing: status.upcoming ? 0.8 : 0),
                ),
              ),
            ],
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
      child: Material(
        color: expanded ? AppColors.primarySoft : AppColors.surface,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.greyLight)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.only(left: AppSizes.s10, right: AppSizes.s4, top: AppSizes.s4, bottom: AppSizes.s4),
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

/// Escudo grande num anel na cor do time e o nome embaixo (até 2 linhas).
class _Team extends StatelessWidget {
  final String name;
  final String? crest;
  final Color color;
  final bool won;
  final bool lost;
  final bool isFavorite;

  const _Team({
    required this.name,
    required this.crest,
    required this.color,
    required this.won,
    required this.lost,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.s4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.45), width: AppSizes.s2),
          ),
          child: TeamCrest(imageUrl: crest, size: AppSizes.s44),
        ),
        const SizedBox(height: AppSizes.s8),
        Text.rich(
          TextSpan(
            text: name,
            children: [
              if (isFavorite)
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(left: AppSizes.s2),
                    child: Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s14),
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: lost ? AppColors.textSecondary : AppColors.textPrimary).copyWith(
            fontSize: AppSizes.s14,
            height: 1.2,
            fontWeight: won ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
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
