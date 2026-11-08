import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_details_page.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/feed_card_parts.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Card automático "Vote no craque" (`tag: "votacao"`): degradê das cores dos
/// times, troféu dourado, os dois escudos, título, texto e o botão "Votar
/// agora". Com a votação encerrada, vira o [_ClosedVoteCard] (verde da marca,
/// com o craque eleito gravado pelas functions).
class VoteCallCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;

  const VoteCallCard({super.key, required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!news.votingOpen) return _ClosedVoteCard(news: news, trailing: trailing, onTap: onTap);
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

/// Votação encerrada: selo dourado, a partida e o painel do craque eleito
/// (troféu, nome, time, votos e %); sem eleito, "Sem craque eleito"; card
/// antigo (sem a apuração gravada), "Votação encerrada" + "Ver resultado".
class _ClosedVoteCard extends StatelessWidget {
  final NewsDTO news;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ClosedVoteCard({required this.news, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.cardRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
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
            onTap: onTap,
            child: Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _RaysPainter())),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s8, 0),
                      child: Row(
                        children: [
                          FeedCutBadge(label: l10n.voteCallClosedBadge, icon: Icons.lock_rounded),
                          const SizedBox(width: AppSizes.s10),
                          Expanded(
                            child: Text(
                              news.championshipTitle.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FeedCardFonts.condensed,
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.s14,
                                letterSpacing: 1.4,
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, 0),
                      child: Row(
                        children: [
                          FeedCrestBox(crest: news.homeCrest, size: AppSizes.s32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6),
                            child: Text(
                              '×',
                              style: TextStyle(
                                fontFamily: FeedCardFonts.condensed,
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.s16,
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          FeedCrestBox(crest: news.awayCrest, size: AppSizes.s32),
                          const SizedBox(width: AppSizes.s10),
                          Expanded(
                            child: Text(
                              '${news.homeTeam} × ${news.awayTeam}'.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: FeedCardFonts.condensed,
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.s16,
                                letterSpacing: 0.4,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, 0),
                      child: _BestPlayerPanel(news: news),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s16, AppSizes.s16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: onTap == null
                            ? const SizedBox.shrink()
                            : FeedActionPill(label: l10n.voteCallResult, icon: Icons.emoji_events_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Painel do resultado: o craque (troféu dourado, nome grande, time, votos
/// e %), "Sem craque eleito" (troféu apagado) ou, sem a apuração, o convite.
class _BestPlayerPanel extends StatelessWidget {
  final NewsDTO news;

  const _BestPlayerPanel({required this.news});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final elected = news.bestPlayerChecked && news.bestPlayerName.isNotEmpty;
    final noWinner = news.bestPlayerChecked && news.bestPlayerName.isEmpty;
    final muted = AppColors.white.withValues(alpha: 0.75);

    final Widget body;
    if (elected) {
      // Time e votos: na mesma linha se couberem; nome longo de time quebra.
      final details = [
        if (news.bestPlayerTeam.isNotEmpty) news.bestPlayerTeam.toUpperCase(),
        if (news.bestPlayerVotes > 0) l10n.voteClosedVotes(news.bestPlayerVotes, news.bestPlayerPercent),
      ];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.voteClosedBestPlayer,
            style: const TextStyle(
              fontFamily: FeedCardFonts.condensed,
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.s12,
              letterSpacing: 1.8,
              color: AppColors.gold,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              news.bestPlayerName.toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                fontFamily: FeedCardFonts.display,
                fontSize: AppSizes.s30,
                height: 1.15,
                letterSpacing: 0.5,
                color: AppColors.white,
                shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: const Offset(0, AppSizes.s2))],
              ),
            ),
          ),
          if (details.isNotEmpty)
            Wrap(
              spacing: AppSizes.s8,
              children: [
                for (final d in details)
                  Text(
                    d,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FeedCardFonts.condensed,
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.s14,
                      letterSpacing: 0.6,
                      color: muted,
                    ),
                  ),
              ],
            ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (noWinner ? l10n.voteClosedNoWinner : l10n.voteClosedTitle).toUpperCase(),
            style: const TextStyle(
              fontFamily: FeedCardFonts.display,
              fontSize: AppSizes.s22,
              height: 1.2,
              letterSpacing: 0.5,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSizes.s2),
          Text(
            noWinner ? l10n.voteClosedNoWinnerText : l10n.voteClosedText(news.homeTeam, news.awayTeam),
            style: AppTypography.body(color: muted).copyWith(fontSize: AppSizes.s14, height: 1.3),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.gold.withValues(alpha: noWinner ? 0.12 : 0.4)),
      ),
      child: Row(
        children: [
          _TrophyMedal(dimmed: noWinner),
          const SizedBox(width: AppSizes.s12),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Troféu num medalhão dourado (apagado quando não houve eleito).
class _TrophyMedal extends StatelessWidget {
  final bool dimmed;

  const _TrophyMedal({this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s56,
      height: AppSizes.s56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: dimmed
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE082), AppColors.gold, Color(0xFFB8860B)],
              ),
        color: dimmed ? AppColors.white.withValues(alpha: 0.12) : null,
        boxShadow: dimmed ? null : [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: AppSizes.s14)],
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        size: AppSizes.s30,
        color: dimmed ? AppColors.white.withValues(alpha: 0.5) : AppColors.primaryDark,
      ),
    );
  }
}

/// Raios dourados bem apagados saindo do canto do painel e um brilho diagonal.
class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.12, size.height * 0.62);
    final ray = Paint()..color = AppColors.gold.withValues(alpha: 0.06);
    const count = 14;
    final reach = size.longestSide * 1.4;
    for (var i = 0; i < count; i++) {
      final a = -1.5708 + (i - count / 2) * 0.16;
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + reach * _cos(a - 0.035), origin.dy + reach * _sin(a - 0.035))
        ..lineTo(origin.dx + reach * _cos(a + 0.035), origin.dy + reach * _sin(a + 0.035))
        ..close();
      canvas.drawPath(path, ray);
    }
    final beam = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0.05),
            AppColors.white.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  static double _cos(double a) => Offset.fromDirection(a).dx;
  static double _sin(double a) => Offset.fromDirection(a).dy;

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) => false;
}
