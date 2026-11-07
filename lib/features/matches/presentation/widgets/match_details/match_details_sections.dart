import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
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

    // Gols e cartões da súmula em ordem de minuto; os gols levam o placar.
    final events = MatchReport.timeline(goals, match.bookings, match.substitutions);
    var home = 0;
    var away = 0;
    final rows = <Widget>[];
    for (var i = 0; i < events.length; i++) {
      final event = events[i];
      String? score;
      if (event.isGoal) {
        event.side == MatchSide.home ? home++ : away++;
        score = '$home-$away';
      }
      rows.add(_TimelineRow(event: event, score: score, isFirst: i == 0, isLast: i == events.length - 1));
    }

    return ArenaCard(
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.sports_soccer_rounded,
            title: match.bookings.isEmpty ? l10n.matchCardGoals : l10n.matchReportTabEvents,
          ),
          if (events.isEmpty)
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
  final ReportEvent event;

  /// Placar depois do gol; nulo nos cartões (o meio mostra o cartão).
  final String? score;
  final bool isFirst;
  final bool isLast;

  const _TimelineRow({required this.event, required this.score, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isHome = event.side == MatchSide.home;
    final score = this.score;
    final booking = event.booking;
    final sub = event.substitution;
    Widget text(bool alignEnd) => sub != null
        ? _SubstitutionText(substitution: sub, alignEnd: alignEnd)
        : booking == null
            ? _GoalText(goal: event.goal!, alignEnd: alignEnd)
            : _BookingText(booking: booking, alignEnd: alignEnd);
    Widget line(bool visible) => Expanded(
          child: Container(width: AppSizes.s2, color: visible ? AppColors.greyLight : AppColors.transparent),
        );
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: isHome ? text(true) : const SizedBox.shrink()),
          SizedBox(
            width: AppSizes.s64,
            child: Column(
              children: [
                line(!isFirst),
                if (sub != null)
                  const Icon(Icons.swap_vert_rounded, size: AppSizes.s20, color: AppColors.primaryDark)
                else if (score == null)
                  BookingIcon(type: booking!.type, size: AppSizes.s20)
                else
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
          Expanded(child: isHome ? const SizedBox.shrink() : text(false)),
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
    final minute = goal.minute == null ? '' : "${goal.minute}' ";
    final name = Flexible(
      child: Text(
        '$minute${goal.hasScorer ? goal.scorerName : l10n.matchDetailsUnknownScorer}',
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

/// Cartão na linha do tempo: "34' Fulano" e, no vermelho de 2º amarelo, o aviso.
class _BookingText extends StatelessWidget {
  final MatchBooking booking;
  final bool alignEnd;

  const _BookingText({required this.booking, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final minute = booking.minute == null ? '' : "${booking.minute}' ";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$minute${booking.playerName}',
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
          ),
          if (booking.secondYellow)
            Text(l10n.matchReportSecondYellow, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
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
    // Encerrada (partida acabou): a apuração mostra o eleito ou por que não houve.
    final closed = !open && MatchCardStatus.of(match, DateTime.now()).finished;
    final canTap = open || hasResult || closed;

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
                              : closed
                                  ? l10n.matchDetailsVotingEnded
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
                    open ? l10n.matchesVoteAction : l10n.votingSeeResult,
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
          else if (match.lineup.of(selectedSide).isNotEmpty)
            // Escalação da súmula: titulares e reservas, com o número.
            for (final starters in [true, false]) ...[
              if (match.lineup.of(selectedSide).any((e) => e.starter == starters))
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.s8, bottom: AppSizes.s4),
                  child: Text(
                    (starters ? l10n.matchDetailsStarters : l10n.matchDetailsSubs).toUpperCase(),
                    style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
              for (final entry in match.lineup.of(selectedSide).where((e) => e.starter == starters))
                for (final line in lines.where((l) => l.player.id == entry.playerId))
                  _PlayerRow(line: line, number: entry.number, onTap: () => onPlayerTap(line.player)),
            ]
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

  /// Número da camisa na escalação da súmula.
  final int? number;

  const _PlayerRow({required this.line, required this.onTap, this.number});

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
            if (number != null)
              SizedBox(
                width: AppSizes.s28,
                child: Text(
                  '$number',
                  style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s16),
                ),
              ),
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

/// Substituição na linha do tempo do detalhe: quem entra (com o minuto) e
/// quem sai.
class _SubstitutionText extends StatelessWidget {
  final MatchSubstitution substitution;
  final bool alignEnd;

  const _SubstitutionText({required this.substitution, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final minute = substitution.minute == null ? '' : "${substitution.minute}' ";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$minute${l10n.reportEntering(substitution.inName)}',
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
          ),
          Text(
            l10n.reportLeaving(substitution.outName),
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
          ),
        ],
      ),
    );
  }
}
