import 'package:flutter/material.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_round_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// "Pódio": os três craques em degraus (o 1º no centro e mais alto), com foto,
/// nome, posição · time e os pontos; degraus em ouro, prata e bronze.
class FantasyPodiumArt extends StatelessWidget {
  final FantasyArtArgs args;

  const FantasyPodiumArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final top = args.data.athletes;
    // Ordem no pódio: 2º, 1º, 3º.
    final order = <FantasyNewsAthlete>[
      if (top.length > 1) top[1],
      if (top.isNotEmpty) top[0],
      if (top.length > 2) top[2],
    ];
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final athlete in order)
          Expanded(child: _Step(args: args, athlete: athlete, first: identical(athlete, top.first))),
      ],
    );
    final podium = LayoutBuilder(
      builder: (context, box) => Align(
        alignment: Alignment.bottomCenter,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomCenter,
          child: SizedBox(width: box.maxWidth, child: row),
        ),
      ),
    );

    if (args.wide) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22 * s, 16 * s, 22 * s, 0),
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
                  Padding(
                    padding: EdgeInsets.only(bottom: 14 * s),
                    child: FantasyArtFooter(args, alignment: MainAxisAlignment.start),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(child: podium),
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
          FantasyArtTitle(args, size: args.square ? 26 : 32),
          SizedBox(height: 8 * s),
          Expanded(child: podium),
          Container(
            color: AppColors.black.withValues(alpha: 0.35),
            padding: EdgeInsets.fromLTRB(0, 10 * s, 0, (args.story ? 30 : 12) * s),
            width: double.infinity,
            child: FantasyArtFooter(args),
          ),
        ],
      ),
    );
  }
}

/// Uma coluna do pódio: foto, nome, posição · time, pontos e o degrau.
class _Step extends StatelessWidget {
  final FantasyArtArgs args;
  final FantasyNewsAthlete athlete;
  final bool first;

  const _Step({required this.args, required this.athlete, required this.first});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final l10n = AppLocalizations.of(context);
    final medal = args.medalOf(athlete);
    final tall = args.story;
    final photo = (first ? (tall ? 104 : (args.wide ? 64 : 84)) : (tall ? 80 : (args.wide ? 50 : 64))) * s;
    final stepHeight = switch (athlete.rank) {
          1 => tall ? 150 : (args.wide ? 56 : (args.square ? 50 : 86)),
          2 => tall ? 110 : (args.wide ? 40 : (args.square ? 36 : 62)),
          _ => tall ? 80 : (args.wide ? 28 : (args.square ? 26 : 44)),
        } *
        s;
    final subtitle = fantasyArtSubtitle(l10n, athlete);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (athlete.rank == 1) Icon(Icons.workspace_premium_rounded, color: args.colors.accent, size: 28 * s),
          FantasyArtPhoto(athlete: athlete, size: photo, ring: medal, ringWidth: 3 * s, colors: args.colors),
          SizedBox(height: 6 * s),
          Text(
            athlete.name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.displayStyle((first ? 15 : 12.5) * s, AppColors.white, height: 1.05),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ArtFonts.textStyle(9 * s, AppColors.white.withValues(alpha: 0.75), weight: FontWeight.w700),
            ),
          SizedBox(height: 2 * s),
          Text(fantasyArtPoints(l10n, athlete), style: ArtFonts.displayStyle((first ? 22 : 17) * s, medal)),
          SizedBox(height: 6 * s),
          Container(
            height: stepHeight,
            width: double.infinity,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 6 * s),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [medal, Color.lerp(medal, AppColors.black, 0.45)!],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(6 * s)),
            ),
            child: Text(
              '${athlete.rank}',
              style: ArtFonts.displayStyle((first ? 34 : 26) * s, AppColors.black.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
