import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card automático de resultado no feed (`tag: "resultado"`), sempre com o
/// visual padrão do app (verde da marca, sem as cores dos times): selo "FIM DE
/// JOGO", escudos, placar (vencedor em negrito, perdedor esmaecido), título e
/// texto da postagem.
class ResultCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;

  /// Toque no card (abre os detalhes da partida).
  final VoidCallback? onTap;

  const ResultCard({super.key, required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeGoals = int.tryParse(news.homeGoals) ?? 0;
    final awayGoals = int.tryParse(news.awayGoals) ?? 0;
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4))
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryStrong],
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -AppSizes.s30,
                  bottom: -AppSizes.s30,
                  child: Icon(
                    Icons.sports_soccer_rounded,
                    size: AppSizes.s150,
                    color: AppColors.white.withValues(alpha: 0.07),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s8, AppSizes.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.s12),
                            ),
                            child: Text(
                              l10n.resultCardFullTime,
                              style: AppTypography.label(color: AppColors.primaryDark)
                                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 1, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Expanded(
                            child: Text(
                              news.championshipTitle.isNotEmpty
                                  ? news.championshipTitle
                                  : (news.championshipId ?? 0) > 0
                                      ? ''
                                      : l10n.resultCardFriendly,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.85))
                                  .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      const SizedBox(height: AppSizes.s12),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _Team(
                                name: news.homeTeam,
                                crest: news.homeCrest,
                                won: homeGoals > awayGoals,
                                lost: homeGoals < awayGoals,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: AppSizes.s8),
                              child: Text(
                                '${news.homeGoals.isEmpty ? '0' : news.homeGoals} × '
                                '${news.awayGoals.isEmpty ? '0' : news.awayGoals}',
                                style: AppTypography.display(color: AppColors.white).copyWith(
                                  fontSize: AppSizes.s36,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 8)],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _Team(
                                name: news.awayTeam,
                                crest: news.awayCrest,
                                won: awayGoals > homeGoals,
                                lost: awayGoals < homeGoals,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.s12),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Divider(height: AppSizes.s1, color: AppColors.white.withValues(alpha: 0.2)),
                      ),
                      const SizedBox(height: AppSizes.s12),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                            ),
                            if (news.description.isNotEmpty) ...[
                              const SizedBox(height: AppSizes.s6),
                              Text(
                                news.description,
                                style: AppTypography.body(color: AppColors.white.withValues(alpha: 0.9))
                                    .copyWith(fontSize: AppSizes.s14, height: 1.35),
                              ),
                            ],
                            if (onTap != null) ...[
                              const SizedBox(height: AppSizes.s10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.resultCardSeeMatch,
                                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: AppSizes.s20),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Escudo num círculo branco e o nome embaixo.
class _Team extends StatelessWidget {
  final String name;
  final String crest;

  /// Vencedor em negrito, perdedor esmaecido (empate: os dois normais).
  final bool won;
  final bool lost;

  const _Team({required this.name, required this.crest, this.won = false, this.lost = false});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: lost ? 0.65 : 1,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s6),
              decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: AppSizes.s44),
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.white).copyWith(
                fontSize: AppSizes.s14,
                height: 1.2,
                fontWeight: won ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
