import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Atleta na partida "Contagem" (contagem regressiva de dia de jogo): fundo
/// escuro da cor do time com meia-tela e brilho; o número gigante metálico
/// ("2" + "DIAS PARA O JOGO", "HOJE" no dia) com o nome; a foto num recorte
/// alto de topo inclinado na borda da cor do time; embaixo, o confronto.
class CountdownArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const CountdownArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final base = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: args.wide ? const Alignment(0.2, -0.2) : const Alignment(0.5, -0.35),
              radius: 1.1,
              colors: [Color.lerp(base, AppColors.black, 0.25)!, Color.lerp(base, AppColors.black, 0.82)!],
            ),
          ),
        ),
        ArtHalftone(color: AppColors.white.withValues(alpha: 0.07), from: Alignment.topRight, to: Alignment.bottomLeft),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Topo inclinado (sobe da esquerda para a direita).
class _SlantClipper extends CustomClipper<Path> {
  final double slant;

  const _SlantClipper(this.slant);

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, slant)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant _SlantClipper oldClipper) => oldClipper.slant != slant;
}

/// A foto no recorte alto com a borda da cor do time.
class _Photo extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double width;
  final double height;

  const _Photo({required this.args, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final p = args.data.player;
    final slant = height * 0.12;
    final border = width * 0.03;
    final ring = args.teamColors ? artHalfColor(args.teamColor) : args.colors.accent;
    return ClipPath(
      clipper: _SlantClipper(slant),
      child: Container(
        width: width,
        height: height,
        color: ring,
        padding: EdgeInsets.fromLTRB(border, border, border, 0),
        child: ClipPath(
          clipper: _SlantClipper(slant - border),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArtPlayerPhoto(url: p.photoUrl, initials: p.initials, color: args.teamColor),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.6, 1],
                    colors: [Color(0x00000000), Color(0x99000000)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O número gigante metálico e o rótulo; embaixo, o nome e a posição.
class _Count extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Count({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final p = args.data.player;
    final accent = args.colors.accent;
    final metal = [Color.lerp(accent, AppColors.white, 0.55)!, accent, Color.lerp(accent, AppColors.black, 0.3)!];
    final number = Text(
      t.countdownNumber,
      maxLines: 1,
      style: ArtFonts.displayStyle(t.countdownIsNumber ? 190 * scale : 76 * scale, AppColors.white, height: 1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) =>
                LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: metal)
                    .createShader(rect),
            child: number,
          ),
        ),
        Text(
          t.countdownLabel,
          maxLines: 2,
          style: ArtFonts.displayStyle(22 * scale, AppColors.white, spacing: 0.8, height: 1.1),
        ),
        Container(
          width: 46 * scale,
          height: 4 * scale,
          margin: EdgeInsets.symmetric(vertical: 12 * scale),
          color: accent,
        ),
        if (p.firstName.isNotEmpty)
          Text(
            p.firstName.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(16 * scale, AppColors.white.withValues(alpha: 0.85), italic: true, height: 1),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            p.highlightName.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(34 * scale, AppColors.white, height: 1.08),
          ),
        ),
        if (t.player.position.isNotEmpty)
          Text(t.player.position, style: ArtFonts.textStyle(11 * scale, accent, spacing: 2.6)),
      ],
    );
  }
}

/// Painel do confronto com dia · horário · local e a competição.
class _Matchup extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Matchup({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final m = args.texts.match;
    final when = [if (m.shortDate.isNotEmpty) m.shortDate, args.texts.whenWhere].join('  ·  ');
    return Container(
      padding: EdgeInsets.fromLTRB(12 * scale, 10 * scale, 12 * scale, 10 * scale),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerMatchup(args: args, scale: scale * 0.85),
          SizedBox(height: 8 * scale),
          Text(
            when,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.displayStyle(14 * scale, AppColors.white, spacing: 0.5, height: 1.2),
          ),
          SizedBox(height: 3 * scale),
          PlayerMatchCompetition(args: args, scale: scale * 0.85, color: args.colors.accent),
        ],
      ),
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.74 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, args.story ? 52 : 18, 20, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayerMatchSeal(args: args, scale: s),
          SizedBox(height: 10 * s),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final photoW = c.maxWidth * 0.5;
              final photoH = (c.maxHeight * 0.98).clamp(0.0, photoW * 1.75);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(width: c.maxWidth * 0.5, child: _Count(args: args, scale: s)),
                      ),
                    ),
                  ),
                  _Photo(args: args, width: photoW, height: photoH),
                ],
              );
            }),
          ),
          SizedBox(height: 12 * s),
          _Matchup(args: args, scale: s),
          SizedBox(height: 10 * s),
          Align(
              alignment: Alignment.centerRight,
              child: ArtBranding(color: AppColors.white, scale: s * 0.8, qrData: args.qr)),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const _Wide(this.args);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerMatchSeal(args: args, scale: 0.6),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(width: 150, child: _Count(args: args, scale: 0.6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(builder: (context, c) {
            final h = c.maxHeight;
            return Align(alignment: Alignment.bottomCenter, child: _Photo(args: args, width: h * 0.62, height: h));
          }),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(width: 190, child: _Matchup(args: args, scale: 0.7)),
                    ),
                  ),
                ),
                ArtBranding(color: AppColors.white, scale: 0.55, qrData: args.qr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
