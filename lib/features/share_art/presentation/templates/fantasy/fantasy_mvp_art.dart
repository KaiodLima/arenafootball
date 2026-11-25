import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_round_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// "Craque": o 1º em destaque (foto grande, nome e os pontos gigantes) e o 2º
/// e o 3º numa faixa embaixo.
class FantasyMvpArt extends StatelessWidget {
  final FantasyArtArgs args;

  const FantasyMvpArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    final athletes = args.data.athletes;
    final best = athletes.isEmpty ? null : athletes.first;
    final others = athletes.skip(1).toList();

    Widget hero(double photo, double nameSize, double pointsSize, {bool start = false}) {
      if (best == null) return const SizedBox.shrink();
      final subtitle = fantasyArtSubtitle(l10n, best);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: start ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          FantasyArtPhoto(
            athlete: best,
            size: photo * s,
            ring: args.medalOf(best),
            ringWidth: 4 * s,
            colors: args.colors,
          ),
          SizedBox(height: 8 * s),
          Text(
            best.name.toUpperCase(),
            textAlign: start ? TextAlign.start : TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.displayStyle(nameSize * s, AppColors.white, height: 1.02),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ArtFonts.textStyle(11 * s, AppColors.white.withValues(alpha: 0.8), weight: FontWeight.w700),
            ),
          Text(
            fantasyArtPoints(l10n, best),
            style: ArtFonts.displayStyle(pointsSize * s, args.colors.accent, height: 1.1).copyWith(
              shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.4), offset: Offset(0, 3 * s))],
            ),
          ),
        ],
      );
    }

    final strip = Row(
      children: [
        for (final athlete in others) Expanded(child: _Mini(args: args, athlete: athlete)),
      ],
    );

    if (args.wide) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22 * s, 16 * s, 22 * s, 14 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: args.size.width * 0.34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FantasyArtSeal(args),
                  SizedBox(height: 8 * s),
                  FantasyArtTitle(args, size: 24, align: TextAlign.start),
                  const Spacer(),
                  FantasyArtFooter(args, alignment: MainAxisAlignment.start),
                ],
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width * 0.55,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      hero(92, 18, 34),
                      if (others.isNotEmpty) ...[SizedBox(height: 8 * s), strip],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, (args.story ? 46 : 22) * s, 18 * s, 0),
      child: Column(
        children: [
          FantasyArtSeal(args),
          SizedBox(height: 8 * s),
          FantasyArtTitle(args, size: args.square ? 24 : 30),
          SizedBox(height: 10 * s),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: args.size.width - 36 * s,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    hero(args.story ? 170 : 130, args.story ? 30 : 24, args.story ? 64 : 50),
                    if (others.isNotEmpty) ...[SizedBox(height: 12 * s), strip],
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: AppColors.black.withValues(alpha: 0.35),
            margin: EdgeInsets.only(top: 10 * s),
            padding: EdgeInsets.fromLTRB(0, 10 * s, 0, (args.story ? 30 : 12) * s),
            width: double.infinity,
            child: FantasyArtFooter(args),
          ),
        ],
      ),
    );
  }
}

/// 2º/3º na faixa: posição na medalha, foto, nome e os pontos.
class _Mini extends StatelessWidget {
  final FantasyArtArgs args;
  final FantasyNewsAthlete athlete;

  const _Mini({required this.args, required this.athlete});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    final medal = args.medalOf(athlete);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4 * s),
      padding: EdgeInsets.all(6 * s),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(color: medal.withValues(alpha: 0.8), width: 1.2 * s),
      ),
      child: Row(
        children: [
          Text('${athlete.rank}º', style: ArtFonts.displayStyle(16 * s, medal)),
          SizedBox(width: 6 * s),
          FantasyArtPhoto(athlete: athlete, size: 34 * s, ring: medal, ringWidth: 2 * s, colors: args.colors),
          SizedBox(width: 6 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  athlete.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.displayStyle(11 * s, AppColors.white),
                ),
                Text(fantasyArtPoints(l10n, athlete), style: ArtFonts.displayStyle(12 * s, medal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
