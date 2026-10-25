import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_details_page.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card automático "Vote no craque" (`tag: "votacao"`): degradê das cores dos
/// times, troféu dourado, os dois escudos, título, texto e o botão "Votar
/// agora". Com a votação encerrada, vira "Votação encerrada · Ver resultado".
class VoteCallCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;

  const VoteCallCard({super.key, required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final home = MatchDetailsPage.headerColor(colorFromHex(news.homeColor));
    final away = MatchDetailsPage.headerColor(colorFromHex(news.awayColor));
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final open = news.votingOpen;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4))
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [home, home, away, away],
            stops: const [0, 0.3, 0.7, 1],
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
                  right: -AppSizes.s24,
                  top: -AppSizes.s20,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: AppSizes.s150,
                    color: AppColors.gold.withValues(alpha: 0.16),
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
                              color: open ? AppColors.gold : AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.s12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  open ? Icons.how_to_vote_rounded : Icons.lock_outline_rounded,
                                  size: AppSizes.s14,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: AppSizes.s4),
                                Text(
                                  open ? l10n.voteCallBadge : l10n.voteCallClosedBadge,
                                  style: AppTypography.label(color: AppColors.primaryDark)
                                      .copyWith(fontSize: AppSizes.s12, letterSpacing: 1, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Expanded(
                            child: Text(
                              news.championshipTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.white.withValues(alpha: 0.85))
                                  .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      const SizedBox(height: AppSizes.s14),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Row(
                          children: [
                            _Crest(crest: news.homeCrest),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
                              child: Text(
                                '×',
                                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s22),
                              ),
                            ),
                            _Crest(crest: news.awayCrest),
                            const SizedBox(width: AppSizes.s12),
                            Expanded(
                              child: Text(
                                '${news.homeTeam} × ${news.awayTeam}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.s14),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
                            ),
                            if (news.description.isNotEmpty) ...[
                              const SizedBox(height: AppSizes.s6),
                              Text(
                                news.description,
                                style: AppTypography.body(color: AppColors.white.withValues(alpha: 0.9))
                                    .copyWith(fontSize: AppSizes.s14, height: 1.35),
                              ),
                            ],
                            const SizedBox(height: AppSizes.s14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s10),
                              decoration: BoxDecoration(
                                color: open ? AppColors.gold : AppColors.white,
                                borderRadius: BorderRadius.circular(AppSizes.s24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    open ? Icons.how_to_vote_rounded : Icons.emoji_events_rounded,
                                    size: AppSizes.s18,
                                    color: AppColors.primaryDark,
                                  ),
                                  const SizedBox(width: AppSizes.s6),
                                  Text(
                                    open ? l10n.voteCallAction : l10n.voteCallResult,
                                    style: AppTypography.label(color: AppColors.primaryDark).copyWith(
                                      fontSize: AppSizes.s14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

class _Crest extends StatelessWidget {
  final String crest;

  const _Crest({required this.crest});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.s4),
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: TeamCrest(imageUrl: crest.isEmpty ? null : crest, size: AppSizes.s36),
      );
}
