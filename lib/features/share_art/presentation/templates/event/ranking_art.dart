import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Resultado "Ranking": todas as opções, da mais votada para a menos, cada
/// uma com a posição, a foto, o nome e a barra com o percentual; a vencedora
/// no destaque da paleta. Na paisagem, em duas colunas.
class RankingArt extends StatelessWidget {
  final EventArtArgs args;

  const RankingArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final entries = args.data.entries;

    Widget list(List<EventResultEntry> items, int slots) => Column(
          children: [
            for (var i = 0; i < slots; i++)
              Expanded(child: i < items.length ? _Row(args: args, entry: items[i]) : const SizedBox.shrink()),
          ],
        );

    if (args.wide) {
      final half = (entries.length / 2).ceil();
      final split = entries.length > 4;
      return Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, 12 * s),
        child: Column(
          children: [
            Row(
              children: [
                EventArtSeal(args),
                SizedBox(width: 10 * s),
                Expanded(child: EventArtTitle(args, size: 17, align: TextAlign.start, lines: 1)),
              ],
            ),
            SizedBox(height: 8 * s),
            Expanded(
              child: split
                  ? Row(
                      children: [
                        Expanded(child: list(entries.take(half).toList(), half)),
                        SizedBox(width: 14 * s),
                        Expanded(child: list(entries.skip(half).toList(), half)),
                      ],
                    )
                  : list(entries, entries.length.clamp(3, 4)),
            ),
            SizedBox(height: 6 * s),
            EventArtFooter(args),
          ],
        ),
      );
    }
    // Pelo menos 4 vagas: com poucas opções, as linhas não ficam enormes.
    final slots = entries.length < 4 ? 4 : entries.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, (args.story ? 46 : 22) * s, 20 * s, (args.story ? 34 : 14) * s),
      child: Column(
        children: [
          EventArtSeal(args),
          SizedBox(height: 8 * s),
          EventArtTitle(args, size: args.square ? 20 : 24),
          SizedBox(height: (args.story ? 22 : 12) * s),
          Expanded(child: list(entries, slots)),
          SizedBox(height: 8 * s),
          EventArtFooter(args),
        ],
      ),
    );
  }
}

/// Uma linha: posição, foto, nome com a barra e o percentual.
class _Row extends StatelessWidget {
  final EventArtArgs args;
  final EventResultEntry entry;

  const _Row({required this.args, required this.entry});

  @override
  Widget build(BuildContext context) {
    final s = args.s;
    final winner = entry.winner;
    final accent = args.colors.accent;
    return LayoutBuilder(
      builder: (context, constraints) {
        // A linha se ajusta à altura da vaga (até 8 opções).
        final h = constraints.maxHeight;
        final photo = (h * 0.78).clamp(18 * s, 58 * s);
        final nameSize = (h * 0.26).clamp(9 * s, 17 * s);
        return Container(
          margin: EdgeInsets.symmetric(vertical: (h * 0.06).clamp(1.0, 5 * s)),
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: BoxDecoration(
            color: winner ? accent.withValues(alpha: 0.16) : AppColors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: winner ? accent : AppColors.transparent, width: 1.2 * s),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22 * s,
                child: Text(
                  '${entry.position}',
                  textAlign: TextAlign.center,
                  style:
                      ArtFonts.displayStyle(nameSize * 1.2, winner ? accent : AppColors.white.withValues(alpha: 0.7)),
                ),
              ),
              SizedBox(width: 6 * s),
              EventArtPhoto(
                entry: entry,
                size: photo,
                ring: winner ? accent : AppColors.white.withValues(alpha: 0.5),
                ringWidth: 2 * s,
                colors: args.colors,
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.option.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ArtFonts.displayStyle(nameSize, AppColors.white, height: 1.1),
                    ),
                    SizedBox(height: (h * 0.06).clamp(1.0, 5 * s)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4 * s),
                      child: Stack(
                        children: [
                          Container(height: 6 * s, color: AppColors.white.withValues(alpha: 0.15)),
                          FractionallySizedBox(
                            widthFactor: entry.share.clamp(0.0, 1.0),
                            child: Container(
                              height: 6 * s,
                              color: winner ? accent : AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * s),
              Text(
                '${entry.percent}%',
                style: ArtFonts.displayStyle(nameSize * 1.25, winner ? accent : AppColors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
