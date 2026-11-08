import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Modelo "Fim de jogo" (pôster): fundo escuro com grão e "FIM DE JOGO"
/// gigante vazado na diagonal, escudos enormes apagados sangrando das
/// laterais com faixas nas cores dos times, placar gigante em Anton (o
/// vencedor em dourado), autores dos gols, faixa de ingresso e a marca.
class PosterArt extends StatelessWidget {
  final ResultArtArgs args;

  const PosterArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final theme = args.theme;
    final w = size.width;
    final h = size.height;
    final giant = (args.wide ? h * 1.1 : w * 0.95);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(theme.brandDark, AppColors.black, 0.35)!,
                Color.lerp(theme.brandDark, AppColors.black, 0.75)!,
              ],
            ),
          ),
        ),
        // Escudos gigantes apagados, sangrando das laterais.
        Positioned(
          left: -giant * 0.42,
          top: args.wide ? -giant * 0.05 : h * 0.12,
          child: Opacity(
            opacity: 0.13,
            child: ArtTeamCrest(team: args.data.home, size: giant, color: theme.home, plain: true),
          ),
        ),
        Positioned(
          right: -giant * 0.42,
          bottom: args.wide ? -giant * 0.05 : h * 0.12,
          child: Opacity(
            opacity: 0.13,
            child: ArtTeamCrest(team: args.data.away, size: giant, color: theme.away, plain: true),
          ),
        ),
        // Faixas diagonais nas cores dos times (cantos opostos).
        // Só nos cantos (recortadas), longe do placar e dos gols.
        Positioned(
          left: 0,
          top: 0,
          width: w * (args.wide ? 0.32 : 0.42),
          height: h * (args.wide ? 0.42 : 0.2),
          child: ClipRect(
            child: ArtSpeedStripes(color: theme.home.withValues(alpha: 0.75), width: w * 0.022, gap: w * 0.018),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          width: w * (args.wide ? 0.32 : 0.42),
          height: h * (args.wide ? 0.42 : 0.2),
          child: ClipRect(
            child: ArtSpeedStripes(color: theme.away.withValues(alpha: 0.75), width: w * 0.022, gap: w * 0.018),
          ),
        ),
        // "FIM DE JOGO" gigante vazado, inclinado.
        Center(
          child: Transform.rotate(
            angle: -0.16,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < (args.wide ? 2 : 4); i++)
                    ArtOutlineText(
                      text: '${args.texts.status}  ${args.texts.status}',
                      size: (args.wide ? h : w) * 0.3,
                      color: AppColors.white.withValues(alpha: 0.07),
                    ),
                ],
              ),
            ),
          ),
        ),
        const ArtGrain(opacity: 0.07),
        if (args.wide) _PosterWide(args) else _PosterTall(args),
      ],
    );
  }
}

/// Placar com o vencedor em dourado e o perdedor apagado.
class _PosterScore extends StatelessWidget {
  final ResultArtData data;
  final double size;

  const _PosterScore({required this.data, required this.size});

  Color _color(ArtSide side) {
    final winner = data.winner;
    if (winner == null) return AppColors.white;
    return winner == side ? AppColors.gold : AppColors.white.withValues(alpha: 0.55);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${data.homeGoals}', style: ArtFonts.displayStyle(size, _color(ArtSide.home))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.12),
            child: Container(width: size * 0.22, height: size * 0.07, color: AppColors.white.withValues(alpha: 0.8)),
          ),
          Text('${data.awayGoals}', style: ArtFonts.displayStyle(size, _color(ArtSide.away))),
        ],
      ),
    );
  }
}

class _PosterTeam extends StatelessWidget {
  final ArtTeam team;
  final Color color;
  final double crest;
  final double font;
  final bool winner;

  const _PosterTeam({
    required this.team,
    required this.color,
    required this.crest,
    required this.font,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ArtTeamCrest(team: team, size: crest, color: color),
        ),
        SizedBox(height: font * 0.5),
        Text(
          team.name.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(font, AppColors.white, italic: true, spacing: 0.3, height: 1),
        ),
        SizedBox(height: font * 0.35),
        Container(height: 3, width: crest * 0.45, color: winner ? AppColors.gold : color),
      ],
    );
  }
}

class _PosterScorers extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;
  final int maxLines;

  const _PosterScorers({required this.args, required this.scale, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    if (data.goals.isEmpty) return const SizedBox.shrink();
    Widget side(ArtSide s, bool end) {
      final goals = data.goalsOf(s);
      final shown = goals.take(maxLines).toList();
      return Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          for (final g in shown)
            ArtScorerLine(
              goal: g,
              noScorer: args.texts.noScorer,
              color: AppColors.white,
              pill: args.theme.sideColor(s),
              scale: scale,
              alignEnd: end,
            ),
          if (goals.length > shown.length)
            Text('+${goals.length - shown.length}', style: ArtFonts.textStyle(10 * scale, AppColors.whiteSoft)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: side(ArtSide.home, false)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          child: Icon(Icons.sports_soccer_rounded, size: 14 * scale, color: AppColors.gold),
        ),
        Expanded(child: side(ArtSide.away, true)),
      ],
    );
  }
}

class _PosterTall extends StatelessWidget {
  final ResultArtArgs args;

  const _PosterTall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    final data = args.data;
    final theme = args.theme;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 54 : 20, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (args.logoUrl.isNotEmpty) ...[
                ArtChampionshipLogo(url: args.logoUrl, height: 26 * s),
                SizedBox(width: 8 * s),
              ],
              Expanded(
                child: Text(
                  args.texts.championship,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(11 * s, AppColors.gold, spacing: 2.4),
                ),
              ),
            ],
          ),
          SizedBox(height: 2 * s),
          // Título grande com o fio dourado.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(args.texts.status, style: ArtFonts.displayStyle(44 * s, AppColors.white, spacing: 1)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(width: 64 * s, height: 4 * s, color: AppColors.gold),
          ),
          const Spacer(flex: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _PosterTeam(
                  team: data.home,
                  color: theme.home,
                  crest: 86 * s,
                  font: 15 * s,
                  winner: data.winner == ArtSide.home,
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(top: 6 * s),
                  child: Column(
                    children: [
                      _PosterScore(data: data, size: 84 * s),
                      if (args.texts.halfTime != null)
                        Text(
                          args.texts.halfTime!,
                          style: ArtFonts.textStyle(9.5 * s, AppColors.whiteSoft, weight: FontWeight.w600, spacing: 1),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: _PosterTeam(
                  team: data.away,
                  color: theme.away,
                  crest: 86 * s,
                  font: 15 * s,
                  winner: data.winner == ArtSide.away,
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * s),
          _PosterScorers(args: args, scale: s, maxLines: args.square ? 2 : (args.story ? 7 : 4)),
          const Spacer(flex: 2),
          // Ingresso com data · horário · local (a competição já está no topo).
          if (args.texts.info.isNotEmpty) ...[
            ArtTicketStrip(
                left: args.texts.info, right: '', background: AppColors.white, foreground: theme.brandDark, scale: s),
            SizedBox(height: 10 * s),
          ],
          ArtBranding(color: AppColors.white, scale: s, qrData: args.qr),
        ],
      ),
    );
  }
}

class _PosterWide extends StatelessWidget {
  final ResultArtArgs args;

  const _PosterWide(this.args);

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final theme = args.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (args.logoUrl.isNotEmpty) ...[
                  ArtChampionshipLogo(url: args.logoUrl, height: 24),
                  const SizedBox(height: 5),
                ],
                Text(
                  args.texts.championship,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(9.5, AppColors.gold, spacing: 1.8),
                ),
                const SizedBox(height: 2),
                Text(args.texts.status, maxLines: 2, style: ArtFonts.displayStyle(30, AppColors.white, height: 0.95)),
                Container(margin: const EdgeInsets.only(top: 4), width: 44, height: 3, color: AppColors.gold),
                const Spacer(),
                if (args.texts.info.isNotEmpty)
                  Text(
                    args.texts.info,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(8.5, AppColors.whiteSoft, weight: FontWeight.w600, spacing: 0.4),
                  ),
                const SizedBox(height: 6),
                ArtBranding(color: AppColors.white, scale: 0.75, qrData: args.qr, alignment: MainAxisAlignment.start),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PosterTeam(
                        team: data.home,
                        color: theme.home,
                        crest: 58,
                        font: 11,
                        winner: data.winner == ArtSide.home,
                      ),
                    ),
                    Expanded(flex: 4, child: _PosterScore(data: data, size: 62)),
                    Expanded(
                      flex: 3,
                      child: _PosterTeam(
                        team: data.away,
                        color: theme.away,
                        crest: 58,
                        font: 11,
                        winner: data.winner == ArtSide.away,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _PosterScorers(args: args, scale: 0.8, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
