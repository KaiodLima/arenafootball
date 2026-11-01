import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha do tempo da súmula (estilo FotMob): linha no centro com o minuto
/// num círculo, os lances da casa à esquerda e os do visitante à direita, o
/// placar parcial nos gols e os separadores 1º TEMPO / 2º TEMPO (pela metade
/// da duração). Tocar num lance pede editar/apagar.
class ReportTimeline extends StatelessWidget {
  final List<ReportEvent> events;
  final int duration;
  final Color homeColor;
  final Color awayColor;
  final ValueChanged<ReportEvent> onTap;

  const ReportTimeline({
    super.key,
    required this.events,
    required this.duration,
    required this.homeColor,
    required this.awayColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s40, horizontal: AppSizes.s24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s16),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: AppSizes.s36),
            ),
            const SizedBox(height: AppSizes.s12),
            Text(l10n.reportNoEvents, textAlign: TextAlign.center, style: AppTypography.subtitle()),
          ],
        ),
      );
    }

    final half = duration ~/ 2;
    final rows = <Widget>[];
    String? section;
    var home = 0;
    var away = 0;
    for (final event in events) {
      final minute = event.minute;
      final next = minute == null
          ? l10n.reportNoMinute
          : minute <= half
              ? l10n.reportFirstHalf
              : l10n.reportSecondHalf;
      if (next != section) {
        section = next;
        rows.add(_Separator(label: next));
      }
      String? score;
      if (event.isGoal) {
        event.side == MatchSide.home ? home++ : away++;
        score = '$home–$away';
      }
      rows.add(_EventRow(
        event: event,
        score: score,
        color: event.side == MatchSide.home ? homeColor : awayColor,
        onTap: () => onTap(event),
      ));
    }
    return Column(children: rows);
  }
}

class _Separator extends StatelessWidget {
  final String label;

  const _Separator({required this.label});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Container(height: 1, color: AppColors.greyLight));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s10, letterSpacing: 1),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final ReportEvent event;
  final String? score;
  final Color color;
  final VoidCallback onTap;

  const _EventRow({required this.event, required this.score, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final home = event.side == MatchSide.home;
    final content = _EventContent(event: event, score: score, alignEnd: home);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.s12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: home ? content : const SizedBox.shrink()),
            SizedBox(
              width: AppSizes.s56,
              child: Column(
                children: [
                  Expanded(child: Container(width: AppSizes.s2, color: AppColors.greyLight)),
                  Container(
                    width: AppSizes.s40,
                    height: AppSizes.s40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: AppSizes.s2),
                    ),
                    child: Text(
                      event.minute == null ? '–' : "${event.minute}'",
                      style: AppTypography.label(color: AppColors.textPrimary)
                          .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(child: Container(width: AppSizes.s2, color: AppColors.greyLight)),
                ],
              ),
            ),
            Expanded(child: home ? const SizedBox.shrink() : content),
          ],
        ),
      ),
    );
  }
}

class _EventContent extends StatelessWidget {
  final ReportEvent event;
  final String? score;
  final bool alignEnd;

  const _EventContent({required this.event, required this.score, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goal = event.goal;
    final booking = event.booking;
    final Widget icon = goal != null
        ? const Icon(Icons.sports_soccer_rounded, size: AppSizes.s18, color: AppColors.primaryDark)
        : BookingIcon(type: booking!.type, size: AppSizes.s16);
    final title = goal != null ? (goal.hasScorer ? goal.scorerName : l10n.reportGoalNoScorer) : booking!.playerName;
    final subtitle = goal != null
        ? (goal.hasAssistant ? l10n.matchReportAssist(goal.assistantName) : '')
        : (booking!.secondYellow ? l10n.matchReportSecondYellow : '');
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final titleRow = <Widget>[
      icon,
      const SizedBox(width: AppSizes.s6),
      Flexible(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s8, horizontal: AppSizes.s4),
      child: Column(
        crossAxisAlignment: align,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: alignEnd ? titleRow.reversed.toList() : titleRow,
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          if (score != null)
            Container(
              margin: const EdgeInsets.only(top: AppSizes.s4),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
              decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(AppSizes.s10)),
              child: Text(
                score!,
                style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
