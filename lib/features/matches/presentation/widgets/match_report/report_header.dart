import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Etapa do jogo na linha de etapas da súmula.
enum ReportStage { before, firstHalf, halfTime, secondHalf, finished }

/// Etapa atual pela situação do card e o relógio.
ReportStage reportStageOf(MatchDTO match, DateTime now) {
  final status = MatchCardStatus.of(match, now);
  if (status.finished) return ReportStage.finished;
  if (status.halfTime) return ReportStage.halfTime;
  if (status.live) {
    return MatchClock.of(match, now).phase == MatchClockPhase.secondHalf
        ? ReportStage.secondHalf
        : ReportStage.firstHalf;
  }
  return ReportStage.before;
}

/// Cabeçalho "match center" da súmula (estilo FotMob/SofaScore): gradiente
/// com o brilho da cor de cada time, escudos, placar grande, pílula de status,
/// a linha de etapas e o botão do próximo passo do jogo. Com o jogo rolando
/// (ou perto de começar), redesenha a cada segundo: o relógio corre e a etapa
/// (2º tempo automático) e o próximo passo acompanham sem outra ação.
class ReportHeader extends StatefulWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;
  final Color? homeColor;
  final Color? awayColor;
  final bool busy;
  final ValueChanged<MatchPhase> onPhase;
  final VoidCallback? onDelay;

  /// Hora fixa (testes); nula = relógio do aparelho.
  final DateTime? now;

  const ReportHeader({
    super.key,
    required this.match,
    required this.homeCrest,
    required this.awayCrest,
    required this.homeColor,
    required this.awayColor,
    required this.busy,
    required this.onPhase,
    this.onDelay,
    this.now,
  });

  @override
  State<ReportHeader> createState() => _ReportHeaderState();
}

class _ReportHeaderState extends State<ReportHeader> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(ReportHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match != widget.match || oldWidget.now != widget.now) _schedule();
  }

  /// Tique de 1 s só quando o relógio anda: jogo rolando ou antes do início
  /// (vira "ao vivo" sozinho no horário). Intervalo e encerrada: parado.
  void _schedule() {
    _tick?.cancel();
    _tick = null;
    if (widget.now != null) return;
    final stage = reportStageOf(widget.match, DateTime.now());
    if (stage == ReportStage.halfTime || stage == ReportStage.finished) return;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      // Encerrou sozinha (fim esperado) ou foi para o intervalo: para o tique.
      final now = reportStageOf(widget.match, DateTime.now());
      if (now == ReportStage.halfTime || now == ReportStage.finished) _schedule();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ReportHeaderView(
        match: widget.match,
        homeCrest: widget.homeCrest,
        awayCrest: widget.awayCrest,
        homeColor: widget.homeColor,
        awayColor: widget.awayColor,
        busy: widget.busy,
        onPhase: widget.onPhase,
        onDelay: widget.onDelay,
        now: widget.now ?? DateTime.now(),
      );
}

class _ReportHeaderView extends StatelessWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;
  final Color? homeColor;
  final Color? awayColor;
  final bool busy;
  final ValueChanged<MatchPhase> onPhase;

  /// "Atrasou" (novo horário); aparece só enquanto dá para atrasar.
  final VoidCallback? onDelay;

  const _ReportHeaderView({
    required this.match,
    required this.homeCrest,
    required this.awayCrest,
    required this.homeColor,
    required this.awayColor,
    required this.busy,
    required this.onPhase,
    this.onDelay,
    required this.now,
  });

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = MatchCardStatus.of(match, now);
    final stage = reportStageOf(match, now);
    final actions = matchPhaseActions(l10n, match, status, now);
    final home = match.goals.where((g) => g.side == MatchSide.home).length;
    final away = match.goals.where((g) => g.side == MatchSide.away).length;
    final info = [match.date, match.venue].where((s) => s.trim().isNotEmpty).join('  ·  ');

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(AppColors.primaryDark, homeColor ?? AppColors.primaryMedium, 0.45)!,
            AppColors.primaryDark,
            Color.lerp(AppColors.primaryDark, awayColor ?? AppColors.primaryMedium, 0.45)!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Team(name: match.homeTeam, crest: homeCrest)),
                Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween(begin: 1.4, end: 1.0)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        '$home – $away',
                        key: ValueKey('$home-$away'),
                        style: AppTypography.display(color: AppColors.white).copyWith(
                          fontSize: AppSizes.s44,
                          height: 1.1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s6),
                    _StatusPill(match: match, stage: stage, now: now),
                  ],
                ),
                Expanded(child: _Team(name: match.awayTeam, crest: awayCrest)),
              ],
            ),
            if (info.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.s10),
                child: Text(
                  info,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ),
            const SizedBox(height: AppSizes.s14),
            _Stages(stage: stage),
            if (onDelay != null && canDelayMatch(match, status))
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: busy ? null : onDelay,
                  style: TextButton.styleFrom(foregroundColor: AppColors.gold, visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.schedule_rounded, size: AppSizes.s18),
                  label: Text(match.delayed
                      ? '${l10n.matchDelay} · ${l10n.matchCardWas(match.originalTime.trim())}'
                      : l10n.matchDelay),
                ),
              ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              onPhase(actions.first.phase);
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size.fromHeight(AppSizes.s44),
                        shape: const StadiumBorder(),
                        textStyle: AppTypography.label().copyWith(fontSize: AppSizes.s16, fontWeight: FontWeight.w800),
                      ),
                      icon: Icon(actions.first.icon),
                      label: Text(actions.first.label),
                    ),
                  ),
                  // Último passo possível (encerrar durante o jogo), mais discreto.
                  for (final action in actions.length > 1
                      ? [actions.last]
                      : const <({IconData icon, String label, MatchPhase phase})>[])
                    Padding(
                      padding: const EdgeInsets.only(left: AppSizes.s8),
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : () => onPhase(action.phase),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: BorderSide(color: AppColors.white.withValues(alpha: 0.5)),
                          minimumSize: const Size(0, AppSizes.s44),
                          shape: const StadiumBorder(),
                        ),
                        icon: Icon(action.icon, size: AppSizes.s18),
                        label: Text(action.label),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String name;
  final String? crest;

  const _Team({required this.name, required this.crest});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.s4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: 0.12),
          ),
          child: TeamCrest(imageUrl: crest, size: AppSizes.s52),
        ),
        const SizedBox(height: AppSizes.s6),
        Text(
          name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
        ),
      ],
    );
  }
}

/// "AO VIVO · 34'" (ponto vermelho piscando), "INTERVALO", "ENCERRADO" ou o horário.
class _StatusPill extends StatefulWidget {
  final MatchDTO match;
  final ReportStage stage;
  final DateTime now;

  const _StatusPill({required this.match, required this.stage, required this.now});

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  bool get _live => widget.stage == ReportStage.firstHalf || widget.stage == ReportStage.secondHalf;

  /// Pisca só com o jogo rolando.
  void _sync() {
    final animate = _live && !MediaQuery.of(context).disableAnimations;
    if (animate && !_blink.isAnimating) {
      _blink.repeat(reverse: true);
    } else if (!animate && _blink.isAnimating) {
      _blink
        ..stop()
        ..value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_StatusPill old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final live = widget.stage == ReportStage.firstHalf || widget.stage == ReportStage.secondHalf;
    // Súmula: relógio corrido com segundos ("23:41").
    final minute = MatchClock.runningLabel(widget.match, widget.now);
    final label = switch (widget.stage) {
      ReportStage.firstHalf ||
      ReportStage.secondHalf =>
        minute == null ? l10n.reportLive : '${l10n.reportLive} · $minute',
      ReportStage.halfTime => l10n.reportHalfTime,
      ReportStage.finished => l10n.reportFinished,
      ReportStage.before => widget.match.manualStatus == MatchManualStatus.waiting
          ? l10n.matchCardWaiting
          : widget.match.time.isEmpty
              ? l10n.reportNotStarted
              : widget.match.time,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: live ? AppColors.danger.withValues(alpha: 0.9) : AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            FadeTransition(
              opacity: _blink,
              child: Container(
                width: AppSizes.s8,
                height: AppSizes.s8,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: AppSizes.s6),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

/// Linha de etapas: Antes ── 1º T ── Intervalo ── 2º T ── Fim.
class _Stages extends StatelessWidget {
  final ReportStage stage;

  const _Stages({required this.stage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.reportStageBefore,
      l10n.reportStageFirstHalf,
      l10n.reportStageHalfTime,
      l10n.reportStageSecondHalf,
      l10n.reportStageEnd,
    ];
    final current = stage.index;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: AppSizes.s2,
                margin: const EdgeInsets.only(bottom: AppSizes.s16),
                color: i <= current ? AppColors.gold : AppColors.white.withValues(alpha: 0.25),
              ),
            ),
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == current ? AppSizes.s14 : AppSizes.s10,
                height: i == current ? AppSizes.s14 : AppSizes.s10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current
                      ? AppColors.gold
                      : i == current
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.25),
                  border: i == current ? Border.all(color: AppColors.gold, width: AppSizes.s2 + 1) : null,
                ),
              ),
              const SizedBox(height: AppSizes.s4),
              Text(
                labels[i],
                style: AppTypography.label(color: i == current ? AppColors.white : AppColors.whiteSoft).copyWith(
                  fontSize: AppSizes.s10,
                  fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
