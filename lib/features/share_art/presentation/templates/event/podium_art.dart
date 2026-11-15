import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Resultado "Pódio": as três primeiras em degraus (a 1ª no centro e mais
/// alta), cada uma com foto, nome e percentual; o degrau com a posição em
/// ouro, prata e bronze.
class PodiumArt extends StatelessWidget {
  final EventArtArgs args;

  const PodiumArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final top = args.data.entries.take(3).toList();
    // Ordem no pódio: 2º, 1º, 3º.
    final order = <EventResultEntry>[
      if (top.length > 1) top[1],
      if (top.isNotEmpty) top[0],
      if (top.length > 2) top[2],
    ];
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final entry in order) Expanded(child: _Step(args: args, entry: entry, first: identical(entry, top.first))),
      ],
    );
    // O pódio encolhe por inteiro para caber na altura (apoiado no chão).
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
                  EventArtSeal(args),
                  SizedBox(height: 8 * s),
                  EventArtTitle(args, size: 20, align: TextAlign.start, lines: 3),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 14 * s),
                    child: EventArtFooter(args, alignment: MainAxisAlignment.start),
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
          EventArtSeal(args),
          SizedBox(height: 8 * s),
          EventArtTitle(args, size: args.square ? 22 : 26),
          SizedBox(height: 8 * s),
          Expanded(child: podium),
          Container(
            color: AppColors.black.withValues(alpha: 0.35),
            padding: EdgeInsets.fromLTRB(0, 10 * s, 0, (args.story ? 30 : 12) * s),
            width: double.infinity,
            child: EventArtFooter(args),
          ),
        ],
      ),
    );
  }
}

/// Uma coluna do pódio: foto, nome, percentual e o degrau.
class _Step extends StatelessWidget {
  final EventArtArgs args;
  final EventResultEntry entry;
  final bool first;

  const _Step({required this.args, required this.entry, required this.first});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final medal = eventMedalColors[(entry.position - 1).clamp(0, 2)];
    final tall = args.story;
    final photo = (first ? (tall ? 104 : (args.wide ? 64 : 84)) : (tall ? 80 : (args.wide ? 50 : 64))) * s;
    final stepHeight = switch (entry.position) {
          1 => tall ? 150 : (args.wide ? 62 : (args.square ? 56 : 92)),
          2 => tall ? 110 : (args.wide ? 44 : (args.square ? 40 : 66)),
          _ => tall ? 80 : (args.wide ? 30 : (args.square ? 28 : 46)),
        } *
        s;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.position == 1) Icon(Icons.workspace_premium_rounded, color: args.colors.accent, size: 28 * s),
          EventArtPhoto(entry: entry, size: photo, ring: medal, ringWidth: 3 * s, colors: args.colors),
          SizedBox(height: 6 * s),
          Text(
            entry.option.title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.displayStyle((first ? 15 : 12.5) * s, AppColors.white, height: 1.05),
          ),
          SizedBox(height: 2 * s),
          Text('${entry.percent}%', style: ArtFonts.displayStyle((first ? 24 : 18) * s, medal)),
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
              '${entry.position}',
              style: ArtFonts.displayStyle((first ? 34 : 26) * s, AppColors.black.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
