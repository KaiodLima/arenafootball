import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/feed_card_parts.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

const _display = FeedCardFonts.display;
const _condensed = FeedCardFonts.condensed;

/// Card automático de campeão no feed (`tag: "campeao"`, gravado pelas
/// functions ao encerrar a competição): degradê nas cores do campeão com
/// filete dourado, selo "CAMPEÃO", escudo grande em quadro branco, o nome do
/// time em Anton, a competição (logo + temporada), o vice e "Ver competição".
class ChampionCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ChampionCard({super.key, required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = TeamPalette.orDefault(news.homeColor, '');
    final onAccent = palette.onAccent;
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final logo = news.imageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.s14, offset: Offset(0, AppSizes.s4)),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.accent, palette.accentDark],
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
                  right: -AppSizes.s32,
                  top: -AppSizes.s16,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: AppSizes.s120 + AppSizes.s40,
                    color: AppColors.gold.withValues(alpha: 0.16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s8, AppSizes.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FeedCutBadge(label: l10n.championshipChampionTitle, icon: Icons.emoji_events_rounded),
                          const Spacer(),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      const SizedBox(height: AppSizes.s14),
                      Row(
                        children: [
                          FeedCrestBox(crest: news.homeCrest, size: AppSizes.s72),
                          const SizedBox(width: AppSizes.s14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  news.homeTeam.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: _display,
                                    color: onAccent,
                                    fontSize: AppSizes.s28,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.s6),
                                Row(
                                  children: [
                                    if (logo.isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppSizes.s4),
                                        child: CachedNetworkImage(
                                          imageUrl: logo,
                                          width: AppSizes.s20,
                                          height: AppSizes.s20,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.s6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        news.championshipTitle.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: _condensed,
                                          fontWeight: FontWeight.w700,
                                          color: onAccent,
                                          fontSize: AppSizes.s16,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (news.season.isNotEmpty)
                                  Text(
                                    l10n.championCardSeason(news.season),
                                    style: AppTypography.label(color: onAccent.withValues(alpha: 0.8))
                                        .copyWith(fontSize: AppSizes.s12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (news.awayTeam.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.s12),
                        Text(
                          l10n.championshipRunnerUp(news.awayTeam),
                          style: AppTypography.label(color: onAccent.withValues(alpha: 0.85))
                              .copyWith(fontSize: AppSizes.s12),
                        ),
                      ],
                      if (onTap != null) ...[
                        const SizedBox(height: AppSizes.s12),
                        FeedActionPill(label: l10n.championCardAction, icon: Icons.emoji_events_rounded),
                      ],
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
