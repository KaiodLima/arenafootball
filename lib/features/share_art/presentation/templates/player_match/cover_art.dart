import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Atleta na partida "Capa" (pôster oficial de dia de jogo): a foto ocupa a
/// arte inteira sob um véu na cor do time e o escuro no pé; o título do dia
/// gigante, vazado e na vertical na lateral; o selo da competição no alto;
/// embaixo, o nome em camadas e a barra de placar (escudos, horário, local).
class CoverArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const CoverArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final ground = _ground(args);
    final tint = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final p = args.data.player;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: ground),
        Positioned(
          left: 0,
          top: 0,
          bottom: args.wide ? 0 : null,
          right: args.wide ? size.width * 0.42 : 0,
          height: args.wide ? null : size.height * 0.86,
          child: ArtBleedPhoto(
            url: p.photoUrl,
            initials: p.initials,
            color: args.teamColor,
            ground: ground,
            tint: tint,
            horizontal: args.wide,
            fadeFrom: args.wide ? 0.55 : 0.5,
          ),
        ),
        // Véu na cor do time no topo.
        if (!args.wide)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.32],
                colors: [tint.withValues(alpha: 0.7), tint.withValues(alpha: 0)],
              ),
            ),
          ),
        _VerticalTitle(args),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

Color _ground(PlayerMatchArtArgs args) => args.teamColors
    ? Color.lerp(artHalfColor(args.teamColor), AppColors.black, 0.72)!
    : Color.lerp(args.colors.deep, AppColors.black, 0.35)!;

/// O título do dia ("DOMINGO", "É HOJE!") vazado e na vertical, de cima a
/// baixo na lateral esquerda (na paisagem, no lado do texto).
class _VerticalTitle extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const _VerticalTitle(this.args);

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final band = args.wide ? size.height * 0.24 : size.width * 0.2;
    return Positioned(
      left: args.wide ? size.width * 0.5 : -band * 0.08,
      top: args.wide ? 0 : size.height * 0.04,
      bottom: args.wide ? 0 : size.height * 0.36,
      width: band,
      child: Opacity(
        opacity: 0.55,
        child: RotatedBox(
          quarterTurns: 3,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
            child: Text(
              args.texts.match.headline,
              maxLines: 1,
              style: ArtFonts.outlineStyle(120, AppColors.white, stroke: 1.8, height: 1.05),
            ),
          ),
        ),
      ),
    );
  }
}

/// O nome em camadas: primeiro nome, SOBRENOME enorme e a posição.
class _Name extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Name({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final p = args.data.player;
    final position = args.texts.player.position;
    final first = p.firstName.toUpperCase();
    final shadow = [Shadow(color: AppColors.black.withValues(alpha: 0.55), blurRadius: 14 * scale)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first.isNotEmpty)
          Text(
            first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(22 * scale, AppColors.white, italic: true, height: 1).copyWith(shadows: shadow),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            p.highlightName.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(66 * scale, AppColors.white, spacing: 0.5, height: 1.04)
                .copyWith(shadows: shadow),
          ),
        ),
        if (position.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 18 * scale, height: 3 * scale, color: args.colors.accent),
              SizedBox(width: 8 * scale),
              Text(position, style: ArtFonts.textStyle(13 * scale, AppColors.white, spacing: 3)),
            ],
          ),
      ],
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
      padding: EdgeInsets.fromLTRB(20, args.story ? 50 : 16, 20, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerRight, child: PlayerMatchSeal(args: args, scale: s)),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: args.size.width - 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Name(args: args, scale: s),
                      SizedBox(height: 12 * s),
                      PlayerScoreBar(args: args, scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          Align(
            alignment: Alignment.centerRight,
            child: ArtBranding(color: AppColors.white, scale: s * 0.8, qrData: args.qr),
          ),
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
      padding: EdgeInsets.fromLTRB(args.size.width * 0.5 + args.size.height * 0.22, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayerMatchSeal(args: args, scale: 0.62),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 230,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Name(args: args, scale: 0.62),
                      const SizedBox(height: 8),
                      PlayerScoreBar(args: args, scale: 0.68),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: ArtBranding(color: AppColors.white, scale: 0.55, qrData: args.qr)),
        ],
      ),
    );
  }
}
