import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Resultado "Campeão": a vencedora em destaque — foto grande com moldura no
/// destaque da paleta e coroa, "VENCEDOR", o nome em Anton, o percentual
/// gigante e os votos. Empate: "EMPATE" e as empatadas lado a lado (até 3).
class ChampionArt extends StatelessWidget {
  final EventArtArgs args;

  const ChampionArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final winners = args.data.winners.take(3).toList();
    if (args.wide) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22 * s, 18 * s, 22 * s, 14 * s),
        child: Row(
          children: [
            _Photos(args: args, winners: winners, size: winners.length > 1 ? 82 * s : 150 * s),
            SizedBox(width: 22 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventArtSeal(args),
                  SizedBox(height: 6 * s),
                  EventArtTitle(args, size: 18, align: TextAlign.start),
                  // O miolo encolhe para caber (nomes longos, empate).
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _WinnerText(args: args, winners: winners, align: CrossAxisAlignment.start, scale: 0.8),
                      ),
                    ),
                  ),
                  EventArtFooter(args, alignment: MainAxisAlignment.start),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final photo = winners.length > 1 ? (args.square ? 78 : 96) * s : (args.story ? 210 : (args.square ? 128 : 170)) * s;
    return Padding(
      padding: EdgeInsets.fromLTRB(22 * s, (args.story ? 46 : 22) * s, 22 * s, (args.story ? 34 : 16) * s),
      child: Column(
        children: [
          EventArtSeal(args),
          SizedBox(height: 8 * s),
          EventArtTitle(args, size: args.square ? 22 : 26),
          // O miolo encolhe para caber no formato (o quadrado é baixo).
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 44 * s,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Photos(args: args, winners: winners, size: photo),
                      SizedBox(height: (args.square ? 10 : 16) * s),
                      _WinnerText(args: args, winners: winners, scale: args.square ? 0.8 : (args.story ? 1.15 : 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          EventArtFooter(args),
        ],
      ),
    );
  }
}

/// A(s) foto(s) da(s) vencedora(s) com a coroa por cima.
class _Photos extends StatelessWidget {
  final EventArtArgs args;
  final List<EventResultEntry> winners;
  final double size;

  const _Photos({required this.args, required this.winners, required this.size});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(top: size * 0.16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < winners.length; i++) ...[
                if (i > 0) SizedBox(width: 10 * s),
                EventArtPhoto(
                  entry: winners[i],
                  size: size,
                  ring: args.colors.accent,
                  ringWidth: 4 * s,
                  colors: args.colors,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: -size * 0.04,
          child: Icon(
            Icons.workspace_premium_rounded,
            size: (winners.length > 1 ? 40 : size * 0.3) * (winners.length > 1 ? s : 1),
            color: args.colors.accent,
            shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 8 * s)],
          ),
        ),
      ],
    );
  }
}

/// "VENCEDOR"/"EMPATE", o nome, o detalhe, o percentual e os votos.
class _WinnerText extends StatelessWidget {
  final EventArtArgs args;
  final List<EventResultEntry> winners;
  final CrossAxisAlignment align;
  final double scale;

  const _WinnerText({
    required this.args,
    required this.winners,
    this.align = CrossAxisAlignment.center,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final s = args.s * scale;
    final l10n = AppLocalizations.of(context);
    final textAlign = align == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start;
    final tie = winners.length > 1;
    final first = winners.isEmpty ? null : winners.first;
    final name = winners.map((w) => w.option.title).join('  ·  ');
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tie ? l10n.eventPollTie : l10n.eventPollWinner,
          style: ArtFonts.textStyle(13 * s, args.colors.accent, weight: FontWeight.w800, spacing: 3 * s),
        ),
        SizedBox(height: 2 * s),
        Text(
          name.toUpperCase(),
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.displayStyle((tie ? 22 : 32) * s, AppColors.white, height: 1.05),
        ),
        if (!tie && first != null && first.option.subtitle.isNotEmpty) ...[
          SizedBox(height: 3 * s),
          Text(
            first.option.subtitle.toUpperCase(),
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(12 * s, AppColors.white.withValues(alpha: 0.75), spacing: 1 * s),
          ),
        ],
        if (first != null) ...[
          SizedBox(height: 6 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${first.percent}%', style: ArtFonts.displayStyle(46 * s, args.colors.accent, height: 0.95)),
              SizedBox(width: 8 * s),
              Padding(
                padding: EdgeInsets.only(bottom: 5 * s),
                child: Text(
                  l10n.eventPollVotesCount(first.votes).toUpperCase(),
                  style: ArtFonts.textStyle(12 * s, AppColors.white, spacing: 1 * s),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
