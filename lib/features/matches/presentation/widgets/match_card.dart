import 'dart:async';

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Momento da partida para o centro do card: antes do jogo (horário grande e
/// o dia), em andamento (do horário até horário + duração, ou iniciada na mão
/// pelo admin), encerrada ou só jogada (sem data para saber). O status manual
/// vale mais que o horário.
class MatchCardStatus {
  final bool upcoming;
  final bool live;

  /// Passou do fim, é de dia passado ou o admin encerrou.
  final bool finished;

  /// Intervalo marcado pelo admin (conta como em andamento, relógio parado).
  final bool halfTime;

  /// Dias até a partida (0 = hoje, 1 = amanhã); só vale antes do jogo.
  final int dayOffset;

  /// Próximo instante em que o status muda sozinho (início ou fim); nulo = não muda hoje.
  final DateTime? nextChange;

  const MatchCardStatus._({
    this.upcoming = false,
    this.live = false,
    this.finished = false,
    this.halfTime = false,
    this.dayOffset = 0,
    this.nextChange,
  });

  static const played = MatchCardStatus._();

  /// Dias de hoje até a data "dd/MM" (ou "dd/MM/aaaa") da partida; nulo sem data.
  static int? _dayOffset(MatchDTO match, DateTime now) {
    final parts = match.date.split('/');
    final day = int.tryParse(parts.first.trim());
    final month = parts.length > 1 ? int.tryParse(parts[1].trim()) : null;
    if (day == null || month == null) return null;
    final year = parts.length > 2 ? int.tryParse(parts[2].trim()) : null;
    final today = DateTime.utc(now.year, now.month, now.day);
    var date = DateTime.utc(year ?? now.year, month, day);
    // Data sem ano: janeiro visto em dezembro é do ano que vem.
    if (year == null && date.difference(today).inDays < -180) date = DateTime.utc(now.year + 1, month, day);
    return date.difference(today).inDays;
  }

  /// Hora "HH:mm" da partida no dia de [now]; nula se não der para ler.
  static DateTime? _kickoff(MatchDTO match, DateTime now) {
    final time = match.time.split(':');
    final hour = int.tryParse(time.first.trim());
    final minute = time.length > 1 ? int.tryParse(time[1].trim()) : 0;
    if (hour == null || minute == null) return null;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// "15:45 – 17:15" (horário até o fim pela duração); só o horário se não der para ler.
  static String timeRange(MatchDTO match) {
    final time = match.time.trim();
    final start = _kickoff(match, DateTime(2000));
    if (start == null) return time;
    final end = start.add(Duration(minutes: match.durationMinutes));
    String two(int n) => n.toString().padLeft(2, '0');
    return '$time – ${two(end.hour)}:${two(end.minute)}';
  }

  static MatchCardStatus of(MatchDTO match, DateTime now) {
    final offset = _dayOffset(match, now);
    switch (match.manualStatus) {
      case MatchManualStatus.finished:
        return const MatchCardStatus._(finished: true);
      case MatchManualStatus.live || MatchManualStatus.halfTime when offset == null || offset >= 0:
        // Esquecida em andamento/intervalo: encerra sozinha 30 min depois do fim esperado.
        final autoEnd = MatchClock.expectedEnd(match, now)?.add(MatchClock.autoFinishMargin);
        if (autoEnd != null && !now.isBefore(autoEnd)) return const MatchCardStatus._(finished: true);
        return MatchCardStatus._(
          live: true,
          halfTime: match.manualStatus == MatchManualStatus.halfTime,
          nextChange: autoEnd,
        );
      default:
        break;
    }
    if (offset == null) return played;
    if (offset < 0) return const MatchCardStatus._(finished: true);
    final hasGoals = match.homeGoals > 0 || match.awayGoals > 0 || match.goals.isNotEmpty;
    final kickoff = offset == 0 ? _kickoff(match, now) : null;
    if (kickoff == null || now.isBefore(kickoff)) {
      return hasGoals
          ? MatchCardStatus._(nextChange: kickoff)
          : MatchCardStatus._(upcoming: true, dayOffset: offset, nextChange: kickoff);
    }
    final end = kickoff.add(Duration(minutes: match.durationMinutes));
    if (now.isBefore(end)) return MatchCardStatus._(live: true, nextChange: end);
    return const MatchCardStatus._(finished: true);
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

  /// Admin: iniciar, intervalo, 2º tempo ou encerrar na mão (nulo = sem as ações).
  final ValueChanged<MatchPhase>? onSetPhase;

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
    this.onSetPhase,
    this.now,
  });

  static bool _none(String _) => false;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  /// Expandido: mostra os gols com autor e assistência.
  bool _expanded = false;

  /// Redesenha quando a partida começa ou termina pelo horário.
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _scheduleStatus();
  }

  @override
  void didUpdateWidget(covariant MatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) _scheduleStatus();
  }

  void _scheduleStatus() {
    _statusTimer?.cancel();
    // Com o relógio fixo (teste), o status não muda.
    if (widget.now != null) return;
    final now = DateTime.now();
    final next = MatchCardStatus.of(widget.match, now).nextChange;
    if (next == null) return;
    _statusTimer = Timer(next.difference(now) + const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {});
      _scheduleStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

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
    final now = widget.now ?? DateTime.now();
    final status = MatchCardStatus.of(match, now);
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
                        if (widget.onSetPhase != null)
                          for (final action in matchPhaseActions(l10n, match, status, now))
                            CardMenuAction(
                              icon: action.icon,
                              label: action.label,
                              onSelected: () => widget.onSetPhase!(action.phase),
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
                child: _Center(match: match, status: status, now: widget.now),
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

/// Centro do card: placar grande com "EM ANDAMENTO" durante a partida,
/// "ENCERRADA" depois do fim (ou a hora, sem data para saber) ou, antes do jogo, a hora grande com "HOJE"/"AMANHÃ"/a data.
class _Center extends StatelessWidget {
  final MatchDTO match;
  final MatchCardStatus status;

  /// Hora fixa (teste); nula = relógio de verdade.
  final DateTime? now;

  const _Center({required this.match, required this.status, this.now});

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
        : status.finished
            ? l10n.matchCardFinished
            : time;
    // Antes do jogo (verde) e encerrada (cinza) vão numa pílula.
    final pill = status.upcoming || status.finished;
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
            if (status.live) ...[
              const SizedBox(height: AppSizes.s4),
              MatchClockBadge(match: match, now: now),
            ] else if (small.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                decoration: pill
                    ? BoxDecoration(
                        color: status.upcoming ? AppColors.primarySoft : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(AppSizes.s8),
                      )
                    : null,
                child: Text(
                  small,
                  style: AppTypography.label(color: status.upcoming ? AppColors.primaryDark : AppColors.textSecondary)
                      .copyWith(fontSize: AppSizes.s12, letterSpacing: pill ? 0.8 : 0),
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

/// Pílula vermelha "EM ANDAMENTO" com um ponto pulsando.
class MatchLiveBadge extends StatefulWidget {
  /// Sobre fundo escuro (cabeçalho dos detalhes): pílula branca.
  final bool onDark;

  /// Texto da pílula ("1º TEMPO · 23'"); nulo = "EM ANDAMENTO".
  final String? label;

  /// Intervalo: pílula âmbar, sem o ponto pulsando.
  final bool paused;

  const MatchLiveBadge({super.key, this.onDark = false, this.label, this.paused = false});

  @override
  State<MatchLiveBadge> createState() => _MatchLiveBadgeState();
}

class _MatchLiveBadgeState extends State<MatchLiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = widget.paused ? AppColors.warning : AppColors.danger;
    final background = widget.onDark ? AppColors.white : accent;
    final foreground = widget.onDark ? accent : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSizes.s10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.paused)
            Icon(Icons.pause_rounded, size: AppSizes.s12, color: foreground)
          else
            FadeTransition(
              opacity: Tween<double>(begin: 0.3, end: 1).animate(_pulse),
              child: Container(
                width: AppSizes.s6,
                height: AppSizes.s6,
                decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
              ),
            ),
          const SizedBox(width: AppSizes.s4),
          Text(
            widget.label ?? l10n.matchCardLive,
            style: AppTypography.label(color: foreground)
                .copyWith(fontSize: AppSizes.s12, letterSpacing: 0.8, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Rótulo do relógio: "1º TEMPO · 23'", "INTERVALO" ou "2º TEMPO · 67'".
String matchClockLabel(AppLocalizations l10n, MatchClock clock) {
  final minute = clock.minuteLabel;
  final phase = switch (clock.phase) {
    MatchClockPhase.firstHalf => l10n.matchClockFirstHalf,
    MatchClockPhase.halfTime => l10n.matchClockHalfTime,
    MatchClockPhase.secondHalf => l10n.matchClockSecondHalf,
  };
  return minute == null || clock.phase == MatchClockPhase.halfTime ? phase : '$phase · $minute';
}

/// Ações do admin no andamento: iniciar; no 1º tempo, intervalo; no
/// intervalo, 2º tempo; e encerrar enquanto estiver em andamento.
List<({IconData icon, String label, MatchPhase phase})> matchPhaseActions(
  AppLocalizations l10n,
  MatchDTO match,
  MatchCardStatus status,
  DateTime now,
) {
  if (!status.live) {
    return [(icon: Icons.play_circle_outline_rounded, label: l10n.matchStart, phase: MatchPhase.start)];
  }
  final clock = MatchClock.of(match, now);
  return [
    if (status.halfTime)
      (icon: Icons.play_circle_outline_rounded, label: l10n.matchStartSecondHalf, phase: MatchPhase.secondHalf)
    else if (clock.phase == MatchClockPhase.firstHalf)
      (icon: Icons.pause_circle_outline_rounded, label: l10n.matchHalfTime, phase: MatchPhase.halfTime),
    (icon: Icons.stop_circle_outlined, label: l10n.matchFinish, phase: MatchPhase.finish),
  ];
}

/// Pílula do jogo em andamento com o relógio ("1º TEMPO · 23'"), que se
/// atualiza a cada 30 s (no intervalo fica parada). Com [now] fixo (teste),
/// não atualiza.
class MatchClockBadge extends StatefulWidget {
  final MatchDTO match;
  final bool onDark;
  final DateTime? now;

  const MatchClockBadge({super.key, required this.match, this.onDark = false, this.now});

  @override
  State<MatchClockBadge> createState() => _MatchClockBadgeState();
}

class _MatchClockBadgeState extends State<MatchClockBadge> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant MatchClockBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match) _schedule();
  }

  void _schedule() {
    _tick?.cancel();
    _tick = null;
    if (widget.now != null || widget.match.manualStatus == MatchManualStatus.halfTime) return;
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clock = MatchClock.of(widget.match, widget.now ?? DateTime.now());
    return MatchLiveBadge(
      onDark: widget.onDark,
      label: matchClockLabel(AppLocalizations.of(context), clock),
      paused: clock.phase == MatchClockPhase.halfTime,
    );
  }
}
