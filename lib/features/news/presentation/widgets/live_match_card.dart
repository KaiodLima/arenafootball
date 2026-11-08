import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
import 'package:arena_soccer/features/news/data/dtos/live_event.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card "ao vivo" da partida no feed (estilo dos cards ao vivo do FotMob /
/// OneFootball): card claro com as cores dos times como acento — faixa no
/// topo, escudos com anel, placar grande —, o último lance em destaque (gol,
/// cartão ou substituição) e os anteriores numa mini linha do tempo. Um por
/// partida: cada lance novo atualiza este card e o leva ao topo do feed.
class LiveMatchCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Toque no atleta do lance em destaque (abre a tela dele).
  final void Function(String playerId, String name)? onPlayerTap;

  const LiveMatchCard({super.key, required this.news, this.trailing, this.onTap, this.onPlayerTap});

  /// Quantos lances anteriores aparecem na mini linha do tempo.
  static const int previousCount = 3;

  /// Cor de acento do time: a dele; clara demais (ex.: branco) ou sem cor, um
  /// tom que aparece no fundo claro.
  static Color accentOf(String hex) {
    final color = colorFromHex(hex);
    if (color == null) return AppColors.primary;
    return isLightColor(color) ? AppColors.textSecondary : color;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeAccent = accentOf(news.homeColor);
    final awayAccent = accentOf(news.awayColor);
    final last = news.lastEvent;
    final finished = news.matchStatus == NewsDTO.matchStatusFinished;
    final halfTime = news.matchStatus == NewsDTO.matchStatusHalfTime;
    final previous = [
      for (final e in news.liveEvents.reversed)
        if (e.id != last?.id) e,
    ].take(previousCount).toList();
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4)),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Faixa com as cores dos dois times.
                SizedBox(
                  height: AppSizes.s4,
                  child: Row(
                    children: [
                      Expanded(child: ColoredBox(color: homeAccent)),
                      Expanded(child: ColoredBox(color: awayAccent)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s6, 0),
                  child: Row(
                    children: [
                      if (finished)
                        _StatusPill(label: l10n.liveFullTime, color: AppColors.textPrimary)
                      else if (halfTime)
                        _StatusPill(
                            label: l10n.reportHalfTime, color: AppColors.gold, foreground: AppColors.textPrimary)
                      else
                        const _LivePill(),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(
                        child: Text(
                          l10n.liveEventsTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12),
                        ),
                      ),
                      if (trailing != null) trailing! else const SizedBox(height: AppSizes.s36),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s6, AppSizes.s16, AppSizes.s14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _Team(name: news.homeTeam, crest: news.homeCrest, accent: homeAccent)),
                      _Score(home: news.homeGoals, away: news.awayGoals, minute: finished ? null : last?.minute),
                      Expanded(child: _Team(name: news.awayTeam, crest: news.awayCrest, accent: awayAccent)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                  child: last == null
                      ? _EmptyHighlight(label: l10n.liveNoEvents)
                      : _Highlight(
                          event: last,
                          team: last.home ? news.homeTeam : news.awayTeam,
                          crest: last.home ? news.homeCrest : news.awayCrest,
                          accent: last.home ? homeAccent : awayAccent,
                          onPlayerTap: onPlayerTap,
                        ),
                ),
                if (previous.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s12, 0),
                    child: Column(
                      children: [
                        for (var i = 0; i < previous.length; i++)
                          _MiniTimelineRow(
                            event: previous[i],
                            accent: previous[i].home ? homeAccent : awayAccent,
                            isFirst: i == 0,
                            isLast: i == previous.length - 1,
                          ),
                      ],
                    ),
                  ),
                if (onTap != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s12, AppSizes.s12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.liveSeeMatch,
                          style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s14),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark, size: AppSizes.s20),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: AppSizes.s14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "● AO VIVO" vermelho, com o ponto pulsando.
class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _blink
        ..stop()
        ..value = 1;
    } else if (!_blink.isAnimating) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _blink,
            child: Container(
              width: AppSizes.s6,
              height: AppSizes.s6,
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSizes.s6),
          Text(
            AppLocalizations.of(context).liveLabel.toUpperCase(),
            style: AppTypography.label(color: AppColors.white)
                .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.8, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Pílula parada da fase (intervalo, fim de jogo).
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color foreground;

  const _StatusPill({required this.label, required this.color, this.foreground = AppColors.white});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.s20)),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.label(color: foreground)
              .copyWith(fontSize: AppSizes.s10, letterSpacing: 0.8, fontWeight: FontWeight.w800),
        ),
      );
}

/// Escudo num círculo branco com anel na cor do time, nome embaixo.
class _Team extends StatelessWidget {
  final String name;
  final String crest;
  final Color accent;

  const _Team({required this.name, required this.crest, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.s4),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: AppSizes.s2),
          ),
          child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: AppSizes.s44),
        ),
        const SizedBox(height: AppSizes.s6),
        Text(
          name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12, height: 1.2),
        ),
      ],
    );
  }
}

/// Placar grande e, embaixo, o minuto do último lance.
class _Score extends StatelessWidget {
  final String home;
  final String away;
  final int? minute;

  const _Score({required this.home, required this.away, required this.minute});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.s100,
      child: Column(
        children: [
          const SizedBox(height: AppSizes.s6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${home.isEmpty ? '0' : home} – ${away.isEmpty ? '0' : away}',
              style: AppTypography.display(color: AppColors.textPrimary).copyWith(
                fontSize: AppSizes.s36,
                height: 1.1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (minute != null) ...[
            const SizedBox(height: AppSizes.s4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              child: Text(
                "$minute'",
                style: AppTypography.label(color: AppColors.danger).copyWith(fontSize: AppSizes.s12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ícone do lance: bola, cartão desenhado ou setas de troca.
Widget _eventIcon(LiveEvent event, double size) => switch (event.type) {
      LiveEventType.goal => Icon(Icons.sports_soccer_rounded, size: size, color: AppColors.textPrimary),
      LiveEventType.yellow => BookingIcon(type: BookingType.yellow, size: size * 0.8),
      LiveEventType.red => BookingIcon(type: BookingType.red, size: size * 0.8),
      LiveEventType.substitution => Icon(Icons.swap_vert_rounded, size: size, color: AppColors.primary),
    };

/// O último lance em destaque: fundo claro na cor do time do lance, barra
/// lateral sólida, ícone grande e o texto em hierarquia.
class _Highlight extends StatelessWidget {
  final LiveEvent event;
  final String team;
  final String crest;
  final Color accent;
  final void Function(String playerId, String name)? onPlayerTap;

  const _Highlight({
    required this.event,
    required this.team,
    required this.crest,
    required this.accent,
    this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (event.type) {
      LiveEventType.goal => '${l10n.newsGoalLabel}!',
      LiveEventType.yellow => l10n.liveYellowCard,
      LiveEventType.red =>
        event.secondYellow ? '${l10n.liveSentOff} · ${l10n.matchReportSecondYellow}' : l10n.liveSentOff,
      LiveEventType.substitution => l10n.reportSubstitution,
    };
    final labelColor = switch (event.type) {
      LiveEventType.red => AppColors.danger,
      LiveEventType.yellow => AppColors.textPrimary,
      _ => AppColors.primaryDark,
    };
    final (playerId, playerName) =
        event.type == LiveEventType.substitution ? (event.playerInId, event.playerIn) : (event.playerId, event.player);
    final canOpen = onPlayerTap != null && playerId.isNotEmpty;
    final nameStyle = AppTypography.title(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16, height: 1.2);
    final detailStyle = AppTypography.subtitle().copyWith(fontSize: AppSizes.s12);

    final List<Widget> lines = switch (event.type) {
      LiveEventType.substitution => [
          _ArrowLine(
              icon: Icons.arrow_upward_rounded, color: AppColors.primary, text: event.playerIn, style: nameStyle),
          _ArrowLine(
              icon: Icons.arrow_downward_rounded, color: AppColors.danger, text: event.playerOut, style: detailStyle),
        ],
      LiveEventType.goal => [
          Text(
            event.player.isEmpty ? l10n.reportGoalNoScorer : event.player,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle,
          ),
          if (event.assistant.isNotEmpty)
            Text(l10n.matchReportAssist(event.assistant),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: detailStyle),
        ],
      _ => [Text(event.player, maxLines: 1, overflow: TextOverflow.ellipsis, style: nameStyle)],
    };

    return Material(
      color: accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.s12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canOpen ? () => onPlayerTap!(playerId, playerName) : null,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: AppSizes.s4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s10, AppSizes.s8, AppSizes.s10),
                  child: Row(
                    children: [
                      Container(
                        width: AppSizes.s44,
                        height: AppSizes.s44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: _eventIcon(event, AppSizes.s24),
                      ),
                      const SizedBox(width: AppSizes.s10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: labelColor)
                                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: AppSizes.s2),
                            ...lines,
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.s6),
                      Tooltip(
                        message: team,
                        child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: AppSizes.s28),
                      ),
                      if (canOpen) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final TextStyle style;

  const _ArrowLine({required this.icon, required this.color, required this.text, required this.style});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: AppSizes.s14, color: color),
          const SizedBox(width: AppSizes.s4),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
        ],
      );
}

class _EmptyHighlight extends StatelessWidget {
  final String label;

  const _EmptyHighlight({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.s12)),
        child:
            Text(label, textAlign: TextAlign.center, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
      );
}

/// Lance anterior na mini linha do tempo: minuto num círculo no centro, a
/// casa à esquerda e o visitante à direita.
class _MiniTimelineRow extends StatelessWidget {
  final LiveEvent event;
  final Color accent;
  final bool isFirst;
  final bool isLast;

  const _MiniTimelineRow({required this.event, required this.accent, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (event.type) {
      LiveEventType.substitution => '${event.playerIn} ↔ ${event.playerOut}',
      LiveEventType.goal => event.player.isEmpty ? l10n.reportGoalNoScorer : event.player,
      _ => event.player,
    };
    final content = Row(
      mainAxisAlignment: event.home ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!event.home) ...[_eventIcon(event, AppSizes.s16), const SizedBox(width: AppSizes.s6)],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: event.home ? TextAlign.end : TextAlign.start,
            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
          ),
        ),
        if (event.home) ...[const SizedBox(width: AppSizes.s6), _eventIcon(event, AppSizes.s16)],
      ],
    );
    Widget line(bool visible) => Expanded(
          child: Container(width: 1.5, color: visible ? AppColors.greyLight : AppColors.transparent),
        );
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: event.home ? content : const SizedBox.shrink()),
          SizedBox(
            width: AppSizes.s48,
            child: Column(
              children: [
                line(!isFirst),
                Container(
                  width: AppSizes.s32,
                  height: AppSizes.s24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.s12),
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Text(
                    event.minute == null ? '–' : "${event.minute}'",
                    style: AppTypography.label(color: AppColors.textPrimary)
                        .copyWith(fontSize: AppSizes.s10, fontWeight: FontWeight.w800),
                  ),
                ),
                line(!isLast),
              ],
            ),
          ),
          Expanded(child: event.home ? const SizedBox.shrink() : content),
        ],
      ),
    );
  }
}
