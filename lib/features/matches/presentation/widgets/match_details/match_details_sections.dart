import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Título das seções dos detalhes: ícone num quadradinho verde + texto.
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s6),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s10)),
            child: Icon(icon, size: AppSizes.s18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSizes.s10),
          Text(title, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
        child: Text(text, textAlign: TextAlign.center, style: AppTypography.subtitle()),
      );
}

/// Gols em linha do tempo: os do mandante à esquerda, os do visitante à
/// direita e, no meio, o placar parcial depois de cada gol. Partida antiga sem
/// a lista de gols completa ganha "gols sem autor" até fechar o placar.
class MatchGoalsTimeline extends StatelessWidget {
  final MatchDTO match;

  /// Agora (só para teste).
  final DateTime? now;

  const MatchGoalsTimeline({super.key, required this.match, this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var counter = 0;
    final goals = MatchGoal.forEditing(
      saved: match.goals,
      homeGoals: match.homeGoals,
      awayGoals: match.awayGoals,
      newId: () => 'placeholder${counter++}',
    );
    final upcoming = MatchCardStatus.of(match, now ?? DateTime.now()).upcoming;
    final hasScorers = goals.any((g) => g.hasScorer);

    var home = 0;
    var away = 0;
    final rows = <Widget>[];
    for (var i = 0; i < goals.length; i++) {
      final goal = goals[i];
      goal.side == MatchSide.home ? home++ : away++;
      rows.add(_TimelineRow(goal: goal, score: '$home-$away', isFirst: i == 0, isLast: i == goals.length - 1));
    }

    return ArenaCard(
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(icon: Icons.sports_soccer_rounded, title: l10n.matchCardGoals),
          if (goals.isEmpty)
            _Hint(upcoming ? l10n.matchDetailsNotStarted : l10n.matchDetailsNoGoals)
          else ...[
            ...rows,
            if (!hasScorers) _Hint(l10n.matchDetailsNoScorers),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final MatchGoal goal;
  final String score;
  final bool isFirst;
  final bool isLast;

  const _TimelineRow({required this.goal, required this.score, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isHome = goal.side == MatchSide.home;
    Widget line(bool visible) => Expanded(
          child: Container(width: AppSizes.s2, color: visible ? AppColors.greyLight : AppColors.transparent),
        );
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: isHome ? _GoalText(goal: goal, alignEnd: true) : const SizedBox.shrink()),
          SizedBox(
            width: AppSizes.s64,
            child: Column(
              children: [
                line(!isFirst),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(AppSizes.s12),
                  ),
                  child: Text(
                    score,
                    style: AppTypography.label(color: AppColors.white).copyWith(
                      fontSize: AppSizes.s12,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                line(!isLast),
              ],
            ),
          ),
          Expanded(child: isHome ? const SizedBox.shrink() : _GoalText(goal: goal, alignEnd: false)),
        ],
      ),
    );
  }
}

class _GoalText extends StatelessWidget {
  final MatchGoal goal;
  final bool alignEnd;

  const _GoalText({required this.goal, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    final name = Flexible(
      child: Text(
        goal.hasScorer ? goal.scorerName : l10n.matchDetailsUnknownScorer,
        textAlign: textAlign,
        style: AppTypography.label(color: goal.hasScorer ? AppColors.textPrimary : AppColors.textSecondary)
            .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w700),
      ),
    );
    const ball = Icon(Icons.sports_soccer_rounded, size: AppSizes.s16, color: AppColors.primaryDark);
    const gap = SizedBox(width: AppSizes.s6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: alignEnd ? [name, gap, ball] : [ball, gap, name],
          ),
          if (goal.hasAssistant)
            Text(
              l10n.matchGoalsAssist(goal.assistantName),
              textAlign: textAlign,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
        ],
      ),
    );
  }
}

/// "Melhor da partida": o eleito (foto, nome e votos), a votação aberta com o
/// botão de votar ou o aviso de que ainda não abriu.
class MatchBestPlayerCard extends StatelessWidget {
  final MatchDTO match;

  /// Eleito achado num dos elencos (para a foto); nulo = só o nome.
  final PlayerDTO? player;
  final VoidCallback onTap;

  const MatchBestPlayerCard({super.key, required this.match, required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final elected = match.bestPlayer.trim();
    final votes = match.votesCount.trim();
    final hasResult = elected.isNotEmpty;
    final open = match.isVotingOpen;
    final canTap = open || hasResult;

    final Widget avatar = player != null
        ? PlayerAvatar(player: player!, size: AppSizes.s52)
        : Container(
            width: AppSizes.s52,
            height: AppSizes.s52,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(
              open ? Icons.how_to_vote_rounded : Icons.workspace_premium_rounded,
              color: hasResult ? AppColors.gold : AppColors.primaryDark,
              size: AppSizes.s28,
            ),
          );

    return ArenaCard(
      onTap: canTap ? onTap : null,
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(icon: Icons.workspace_premium_rounded, title: l10n.matchDetailsBestPlayer),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  avatar,
                  if (hasResult)
                    const Positioned(
                      right: -AppSizes.s4,
                      bottom: -AppSizes.s4,
                      child: Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s22),
                    ),
                ],
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasResult
                          ? elected
                          : open
                              ? l10n.matchDetailsVotingOpen
                              : l10n.matchDetailsVotingClosed,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: hasResult
                          ? AppTypography.title().copyWith(fontSize: AppSizes.s18)
                          : AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                    ),
                    if (votes.isNotEmpty && votes != '0')
                      Text(l10n.matchDetailsVotes(votes),
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                  ],
                ),
              ),
              if (canTap) ...[
                const SizedBox(width: AppSizes.s8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
                  decoration: BoxDecoration(
                    color: open ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.s20),
                    border: Border.all(color: open ? AppColors.primary : AppColors.greyLight),
                  ),
                  child: Text(
                    open ? l10n.matchesVoteAction : l10n.matchesSeeElected,
                    style: AppTypography.label(color: open ? AppColors.white : AppColors.primaryDark)
                        .copyWith(fontSize: AppSizes.s12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// "Elencos": abas com os dois times e a lista do escolhido, com os gols e
/// assistências de cada atleta nesta partida (toque abre o perfil).
class MatchSquadsCard extends StatelessWidget {
  final MatchDTO match;
  final MatchSide selectedSide;
  final List<MatchPlayerLine> lines;
  final bool loading;
  final String? homeCrest;
  final String? awayCrest;
  final ValueChanged<MatchSide> onSideChanged;
  final ValueChanged<PlayerDTO> onPlayerTap;

  const MatchSquadsCard({
    super.key,
    required this.match,
    required this.selectedSide,
    required this.lines,
    required this.loading,
    required this.homeCrest,
    required this.awayCrest,
    required this.onSideChanged,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ArenaCard(
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(icon: Icons.groups_rounded, title: l10n.matchDetailsSquads),
          Container(
            padding: const EdgeInsets.all(AppSizes.s4),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s16)),
            child: Row(
              children: [
                for (final side in MatchSide.values)
                  Expanded(
                    child: _SideTab(
                      name: side == MatchSide.home ? match.homeTeam : match.awayTeam,
                      crest: side == MatchSide.home ? homeCrest : awayCrest,
                      selected: side == selectedSide,
                      onTap: () => onSideChanged(side),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(AppSizes.s16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (lines.isEmpty)
            _Hint(l10n.matchDetailsNoSquad)
          else
            for (final line in lines) _PlayerRow(line: line, onTap: () => onPlayerTap(line.player)),
        ],
      ),
    );
  }
}

class _SideTab extends StatelessWidget {
  final String name;
  final String? crest;
  final bool selected;
  final VoidCallback onTap;

  const _SideTab({required this.name, required this.crest, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.s12),
        boxShadow: selected
            ? const [BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s8, offset: Offset(0, AppSizes.s2))]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TeamCrest(imageUrl: crest, size: AppSizes.s22),
              const SizedBox(width: AppSizes.s6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: selected ? AppColors.textPrimary : AppColors.textSecondary)
                      .copyWith(fontSize: AppSizes.s14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final MatchPlayerLine line;
  final VoidCallback onTap;

  const _PlayerRow({required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = line.player;
    final position = PlayerPosition.fromKey(player.position);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.s12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
        child: Row(
          children: [
            PlayerAvatar(player: player, size: AppSizes.s40),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                  ),
                  if (position != null)
                    Text(
                      playerPositionLabel(l10n, position),
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                ],
              ),
            ),
            if (line.goals > 0) _StatBadge(icon: Icons.sports_soccer_rounded, value: line.goals),
            if (line.assists > 0) ...[
              const SizedBox(width: AppSizes.s6),
              _StatBadge(icon: Icons.assistant_rounded, value: line.assists),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int value;

  const _StatBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.s4),
          Text('$value', style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
