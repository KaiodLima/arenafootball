import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fontes esportivas empacotadas (as mesmas dos cards e das artes).
const _display = 'Anton';
const _condensed = 'BarlowCondensed';

/// Cabeçalho dos detalhes: as cores dos dois times chapadas com o corte
/// diagonal branco e dourado, escudos em quadros brancos, nomes em caixa-alta
/// (fio dourado sob o vencedor), no meio o placar grande com "FIM DE JOGO" e o
/// 1º tempo (antes do jogo, o horário; ao vivo, o relógio), os autores dos
/// gols sob cada time e, no pé, local, horário e árbitro em pílulas.
class MatchDetailsHeader extends StatelessWidget {
  final MatchDTO match;
  final String? homeCrest;
  final String? awayCrest;
  final Color homeColor;
  final Color awayColor;

  /// Agora (só para teste).
  final DateTime? now;

  const MatchDetailsHeader({
    super.key,
    required this.match,
    required this.homeCrest,
    required this.awayCrest,
    required this.homeColor,
    required this.awayColor,
    this.now,
  });

  /// Autores de um lado, um por linha, na ordem do 1º gol:
  /// "DUDU 12', 78'" (sem minuto, só o nome; "DUDU (2)" sem nenhum minuto).
  static List<String> scorerLines(List<MatchGoal> goals, MatchSide side) {
    final byScorer = <String, List<int?>>{};
    final sorted = goals.where((g) => g.side == side && g.hasScorer && g.scorerName.trim().isNotEmpty).toList()
      ..sort((a, b) => (a.minute ?? 999).compareTo(b.minute ?? 999));
    for (final goal in sorted) {
      byScorer.putIfAbsent(goal.scorerName.trim(), () => []).add(goal.minute);
    }
    return [
      for (final entry in byScorer.entries)
        () {
          final minutes = entry.value.whereType<int>().map((m) => "$m'").toList();
          final name = entry.key.toUpperCase();
          if (minutes.isNotEmpty) return '$name ${minutes.join(', ')}';
          return entry.value.length > 1 ? '$name (${entry.value.length})' : name;
        }(),
    ];
  }

  /// Placar do 1º tempo: só quando todos os gols têm minuto.
  static (int, int)? halfTimeScore(MatchDTO match) {
    final goals = match.goals;
    if (goals.isEmpty || goals.any((g) => g.minute == null)) return null;
    final half = (match.durationMinutes / 2).round();
    int count(MatchSide side) => goals.where((g) => g.side == side && g.minute! <= half).length;
    return (count(MatchSide.home), count(MatchSide.away));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clock = now ?? DateTime.now();
    final status = MatchCardStatus.of(match, clock);
    final homeWon = !status.upcoming && match.homeGoals > match.awayGoals;
    final awayWon = !status.upcoming && match.awayGoals > match.homeGoals;
    final time = match.time.trim();
    final chip = status.waiting
        ? l10n.matchCardWaiting
        : status.upcoming && match.delayed
            ? '${l10n.matchCardDelayed} · ${l10n.matchCardWas(match.originalTime.trim())}'
            : status.upcoming
                ? switch (status.dayOffset) {
                    0 => l10n.matchCardToday,
                    1 => l10n.matchCardTomorrow,
                    _ => match.date.trim(),
                  }
                : time;
    final half = status.finished ? halfTimeScore(match) : null;
    final showScorers = !status.upcoming;
    final venue = match.venue.trim();
    final range = MatchCardStatus.timeRange(match);
    final referee = match.referee.trim();
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: ArtSplitPainter(home: homeColor, away: awayColor, wide: true)),
        // Sombra no alto (barra legível) e no pé (pílulas).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withValues(alpha: 0.35),
                AppColors.transparent,
                AppColors.black.withValues(alpha: 0.25),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(AppSizes.s12, topInset + AppSizes.s4, AppSizes.s12, AppSizes.s14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width - AppSizes.s24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HeaderTeam(
                          name: match.homeTeam,
                          crest: homeCrest,
                          won: homeWon,
                          dimmed: awayWon,
                          scorers: showScorers ? scorerLines(match.goals, MatchSide.home) : const [],
                        ),
                      ),
                      // Placar num "painel" escuro: o corte diagonal passa por trás.
                      Container(
                        width: AppSizes.s150,
                        margin: const EdgeInsets.only(top: AppSizes.s4),
                        padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s4, AppSizes.s8, AppSizes.s10),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(AppSizes.s16),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          children: [
                            if (status.upcoming)
                              Text(
                                time.isEmpty ? '--:--' : time,
                                style: _displayStyle(AppSizes.s44, AppColors.white),
                              )
                            else
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${match.homeGoals}', style: _displayStyle(AppSizes.s56, _digit(awayWon))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                                      child: Text(
                                        '×',
                                        style: TextStyle(
                                          fontFamily: _condensed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppSizes.s24,
                                          color: AppColors.white.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                    Text('${match.awayGoals}', style: _displayStyle(AppSizes.s56, _digit(homeWon))),
                                  ],
                                ),
                              ),
                            const SizedBox(height: AppSizes.s6),
                            if (status.live)
                              MatchClockBadge(match: match, onDark: true, now: now)
                            else if (status.finished)
                              _GoldBadge(label: l10n.liveFullTime.toUpperCase())
                            else if (chip.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: status.upcoming ? 0.95 : 0.18),
                                  borderRadius: BorderRadius.circular(AppSizes.s12),
                                ),
                                child: Text(
                                  chip,
                                  style: AppTypography.label(
                                    color: status.upcoming ? AppColors.primaryDark : AppColors.white,
                                  ).copyWith(fontSize: AppSizes.s12, letterSpacing: 1, fontWeight: FontWeight.w800),
                                ),
                              ),
                            if (half != null) ...[
                              const SizedBox(height: AppSizes.s6),
                              Text(
                                l10n.shareArtHalfTime('${half.$1} × ${half.$2}').toUpperCase(),
                                style: TextStyle(
                                  fontFamily: _condensed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.s12,
                                  letterSpacing: 1.4,
                                  color: AppColors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: _HeaderTeam(
                          name: match.awayTeam,
                          crest: awayCrest,
                          won: awayWon,
                          dimmed: homeWon,
                          scorers: showScorers ? scorerLines(match.goals, MatchSide.away) : const [],
                        ),
                      ),
                    ],
                  ),
                  if (venue.isNotEmpty || range.isNotEmpty || referee.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSizes.s6,
                      runSpacing: AppSizes.s6,
                      children: [
                        if (venue.isNotEmpty) _InfoPill(icon: Icons.place_rounded, label: venue),
                        if (range.isNotEmpty) _InfoPill(icon: Icons.schedule_rounded, label: range),
                        if (referee.isNotEmpty)
                          _InfoPill(icon: Icons.sports_rounded, label: l10n.matchDetailsReferee(referee)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Número do placar: o perdedor esmaecido.
  static Color _digit(bool lost) => AppColors.white.withValues(alpha: lost ? 0.5 : 1);

  static TextStyle _displayStyle(double size, Color color) => TextStyle(
        fontFamily: _display,
        fontSize: size,
        height: 1.1,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.35), offset: const Offset(0, AppSizes.s2))],
      );
}

/// Escudo num quadro branco, nome em caixa-alta, fio dourado sob o vencedor
/// (perdedor esmaecido) e os autores dos gols.
class _HeaderTeam extends StatelessWidget {
  final String name;
  final String? crest;
  final bool won;
  final bool dimmed;
  final List<String> scorers;

  const _HeaderTeam({
    required this.name,
    required this.crest,
    required this.won,
    required this.dimmed,
    this.scorers = const [],
  });

  static const _maxScorers = 3;

  @override
  Widget build(BuildContext context) {
    final shown = scorers.take(_maxScorers).toList();
    final more = scorers.length - shown.length;
    return Column(
      children: [
        Opacity(
          opacity: dimmed ? 0.7 : 1,
          child: Column(
            children: [
              Container(
                width: AppSizes.s72,
                height: AppSizes.s72,
                padding: const EdgeInsets.all(AppSizes.s8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.s18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.3),
                      blurRadius: AppSizes.s12,
                      offset: const Offset(0, AppSizes.s4),
                    ),
                  ],
                ),
                child: TeamCrest(imageUrl: crest, size: AppSizes.s56),
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                name.toUpperCase(),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _condensed,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.s18,
                  height: 1.05,
                  letterSpacing: 0.4,
                  color: AppColors.white,
                  shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, 1))],
                ),
              ),
              const SizedBox(height: AppSizes.s4),
              Container(
                width: AppSizes.s24,
                height: 3,
                color: won ? AppColors.gold : AppColors.transparent,
              ),
            ],
          ),
        ),
        for (final line in shown)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer_rounded, size: AppSizes.s12, color: AppColors.white.withValues(alpha: 0.8)),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      line,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: _condensed,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.s14,
                        letterSpacing: 0.3,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (more > 0)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.s2),
            child: Text(
              '+$more',
              style: TextStyle(
                fontFamily: _condensed,
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.s12,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
      ],
    );
  }
}

/// "FIM DE JOGO" dourado num selo escuro com o canto cortado.
class _GoldBadge extends StatelessWidget {
  final String label;

  const _GoldBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CutCornerClipper(),
      child: Container(
        color: AppColors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.fromLTRB(AppSizes.s10, AppSizes.s4, AppSizes.s14, AppSizes.s4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: _display,
            fontSize: AppSizes.s14,
            letterSpacing: 1.2,
            height: 1.3,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper();

  @override
  Path getClip(Size size) {
    final cut = size.height * 0.5;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Pílula translúcida escura com ícone (local, horário, árbitro).
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.gold),
          const SizedBox(width: AppSizes.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
            ),
          ),
        ],
      ),
    );
  }
}
