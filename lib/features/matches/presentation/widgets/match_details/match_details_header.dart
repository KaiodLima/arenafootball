import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cabeçalho dos detalhes: degradê da cor do mandante para a do visitante,
/// bola em marca d'água, escudos em círculos brancos e, no meio, o placar
/// (antes do jogo, o horário) com o status embaixo.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clock = now ?? DateTime.now();
    final status = MatchCardStatus.of(match, clock);
    final homeWon = !status.upcoming && match.homeGoals > match.awayGoals;
    final awayWon = !status.upcoming && match.awayGoals > match.homeGoals;
    final time = match.time.trim();
    final isToday = match.date.trim() == WatchMatchesUseCase.formatMatchDate(clock);
    final chip = status.upcoming
        ? switch (status.dayOffset) {
            0 => l10n.matchCardToday,
            1 => l10n.matchCardTomorrow,
            _ => match.date.trim(),
          }
        : isToday
            ? l10n.matchCardToday
            : l10n.matchDetailsFinished;
    final venue = match.venue.trim();
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [homeColor, homeColor, awayColor, awayColor],
              stops: const [0, 0.3, 0.7, 1],
            ),
          ),
        ),
        // Sombra no alto (barra legível) e no pé (texto do local).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withValues(alpha: 0.25),
                AppColors.transparent,
                AppColors.black.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        Positioned(
          right: -AppSizes.s40,
          bottom: -AppSizes.s40,
          child: Icon(
            Icons.sports_soccer_rounded,
            size: AppSizes.s200,
            color: AppColors.white.withValues(alpha: 0.07),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(AppSizes.s16, topInset + AppSizes.s8, AppSizes.s16, AppSizes.s16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width - AppSizes.s32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _HeaderTeam(name: match.homeTeam, crest: homeCrest, dimmed: awayWon)),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s12),
                        child: Column(
                          children: [
                            Text(
                              status.upcoming
                                  ? (time.isEmpty ? '--:--' : time)
                                  : '${match.homeGoals} × ${match.awayGoals}',
                              style: AppTypography.display(color: AppColors.white).copyWith(
                                fontSize: AppSizes.s40,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(height: AppSizes.s6),
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
                          ],
                        ),
                      ),
                      Expanded(child: _HeaderTeam(name: match.awayTeam, crest: awayCrest, dimmed: homeWon)),
                    ],
                  ),
                  if (venue.isNotEmpty || (!status.upcoming && time.isNotEmpty)) ...[
                    const SizedBox(height: AppSizes.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.place_outlined, size: AppSizes.s16, color: AppColors.white.withValues(alpha: 0.85)),
                        const SizedBox(width: AppSizes.s4),
                        Flexible(
                          child: Text(
                            [venue, if (!status.upcoming) time].where((p) => p.isNotEmpty).join('  ·  '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.9))
                                .copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w500),
                          ),
                        ),
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
}

/// Escudo num círculo branco com sombra e o nome embaixo (perdedor esmaecido).
class _HeaderTeam extends StatelessWidget {
  final String name;
  final String? crest;
  final bool dimmed;

  const _HeaderTeam({required this.name, required this.crest, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.7 : 1,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: TeamCrest(imageUrl: crest, size: AppSizes.s56),
          ),
          const SizedBox(height: AppSizes.s10),
          Text(
            name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.white).copyWith(
              fontSize: AppSizes.s16,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
