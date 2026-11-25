import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/feed_card_parts.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

const _display = FeedCardFonts.display;
const _condensed = FeedCardFonts.condensed;

/// Ordem do pódio na tela: 2º · 1º · 3º (com menos atletas, 2º · 1º ou só o 1º).
List<int> fantasyPodiumOrder(int count) => switch (count) {
      >= 3 => const [1, 0, 2],
      2 => const [1, 0],
      1 => const [0],
      _ => const [],
    };

/// Card automático "Craques da rodada" do Arena Fantasy (`tag: "fantasy"`,
/// gravado pelas functions quando a rodada fica finalizada): verde da marca
/// com filete dourado, selo da rodada, título em Anton, a competição e o
/// pódio dos 3 atletas que mais pontuaram (foto com anel ouro/prata/bronze,
/// coroa no 1º, posição, time e pontos). Toque no atleta = perfil dele; no
/// card = escalação do Fantasy.
class FantasyRoundCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ValueChanged<FantasyNewsAthlete>? onAthleteTap;

  /// "Compartilhar": a arte dos craques com o link do Fantasy (nulo = sem o botão).
  final VoidCallback? onShare;

  const FantasyRoundCard({
    super.key,
    required this.news,
    this.trailing,
    this.onTap,
    this.onAthleteTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    final athletes = news.fantasyAthletes.take(3).toList();
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
          gradient: feedCardGradient,
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('fantasy-card-${news.id}'),
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -AppSizes.s24,
                  top: -AppSizes.s20,
                  child: Icon(
                    Icons.star_rounded,
                    size: AppSizes.s120 + AppSizes.s40,
                    color: AppColors.gold.withValues(alpha: 0.12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s8, AppSizes.s16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: FeedCutBadge(
                                  label: l10n.fantasyCardBadge(news.fantasyRound),
                                  icon: Icons.star_rounded,
                                ),
                              ),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      const SizedBox(height: AppSizes.s10),
                      Text(
                        l10n.fantasyCardTitle.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: _display,
                          color: AppColors.white,
                          fontSize: AppSizes.s28,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: AppSizes.s4),
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
                              style: const TextStyle(
                                fontFamily: _condensed,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteSoft,
                                fontSize: AppSizes.s16,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.s16),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final i in fantasyPodiumOrder(athletes.length))
                              Expanded(
                                child: _PodiumSpot(
                                  athlete: athletes[i],
                                  onTap: onAthleteTap == null ? null : () => onAthleteTap!(athletes[i]),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onTap != null || onShare != null) ...[
                        const SizedBox(height: AppSizes.s14),
                        Wrap(
                          spacing: AppSizes.s8,
                          runSpacing: AppSizes.s8,
                          children: [
                            if (onTap != null)
                              FeedActionPill(label: l10n.fantasyCardAction, icon: Icons.sports_soccer_rounded),
                            if (onShare != null)
                              GestureDetector(
                                key: ValueKey('fantasy-card-share-${news.id}'),
                                onTap: onShare,
                                child: FeedActionPill(label: l10n.fantasyCardShare, icon: Icons.ios_share_rounded),
                              ),
                          ],
                        ),
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

/// Um lugar do pódio: coroa (1º), foto com o anel da medalha, nome, posição ·
/// time, pontos e o degrau com a colocação.
class _PodiumSpot extends StatelessWidget {
  final FantasyNewsAthlete athlete;
  final VoidCallback? onTap;

  const _PodiumSpot({required this.athlete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rank = athlete.rank;
    final (medal, step) = switch (rank) {
      1 => (AppColors.medalGoldLight, AppSizes.s40),
      2 => (AppColors.medalSilverLight, AppSizes.s28),
      _ => (AppColors.medalBronzeLight, AppSizes.s20),
    };
    final first = rank == 1;
    final position = fantasyPositionLabelOfKey(l10n, athlete.position);
    final detail = [if (position.isNotEmpty) position, if (athlete.team.isNotEmpty) athlete.team].join(' · ');
    return GestureDetector(
      key: ValueKey('fantasy-card-athlete-${athlete.id}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (first) const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: AppSizes.s24),
            FantasyAvatar(
              name: athlete.name,
              photoUrl: athlete.photoUrl,
              size: first ? AppSizes.s72 : AppSizes.s56,
              ring: medal,
            ),
            const SizedBox(height: AppSizes.s6),
            Text(
              athlete.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12, height: 1.15),
            ),
            if (detail.isNotEmpty)
              Text(
                detail,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10),
              ),
            const SizedBox(height: AppSizes.s4),
            Text(
              l10n.fantasyCardPoints(fantasyPointsLabel(athlete.points)),
              style: TextStyle(fontFamily: _display, color: medal, fontSize: first ? AppSizes.s22 : AppSizes.s18),
            ),
            const SizedBox(height: AppSizes.s4),
            // Degrau do pódio com a colocação.
            Container(
              height: step,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: medal.withValues(alpha: 0.22),
                border: Border(top: BorderSide(color: medal, width: 2)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.s6)),
              ),
              child: Text(
                '$rankº',
                style: TextStyle(fontFamily: _display, color: medal, fontSize: AppSizes.s16, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
