import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Atleta "Reforço" (anúncio de contratação): metades na cor do time com o
/// corte diagonal, o escudo gigante apagado, a foto grande num quadro
/// inclinado de borda branca, a tarja "REFORÇO", "{TIME} ANUNCIA", o nome
/// (primeiro nome menor, o destaque gigante), a posição e a competição.
class SigningArt extends StatelessWidget {
  final PlayerArtArgs args;

  const SigningArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = args.colors;
    final home = args.teamColors ? artHalfColor(args.teamColor) : c.base;
    final away = args.teamColors ? Color.lerp(artHalfColor(args.teamColor), AppColors.black, 0.55)! : c.deep;
    final size = args.size;
    final giant = (args.wide ? size.height : size.width) * 1.05;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: ArtSplitPainter(home: home, away: away, wide: args.wide, accent: c.accent)),
        if (args.data.team.crestUrl.isNotEmpty)
          Positioned(
            right: -giant * 0.35,
            top: args.wide ? -giant * 0.1 : size.height * 0.02,
            child: Opacity(
              opacity: 0.12,
              child: ArtTeamCrest(team: args.data.team, size: giant, color: args.teamColor, plain: true),
            ),
          ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Foto num quadro inclinado com borda branca e sombra dura.
class _Photo extends StatelessWidget {
  final PlayerArtArgs args;
  final double width;
  final double height;

  const _Photo({required this.args, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.045,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(width * 0.04, width * 0.04)),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ArtPlayerPhoto(url: args.data.photoUrl, initials: args.data.initials, color: args.teamColor),
            // Escurece o pé da foto: os títulos ficam por cima dela.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.55, 1],
                  colors: [Color(0x00000000), Color(0x8C000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarja "REFORÇO", "{TIME} ANUNCIA", o nome e a posição.
class _Titles extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Titles({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final accent = args.colors.accent;
    final first = args.data.firstName.toUpperCase();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 3 * scale),
          color: accent,
          child: Text(t.headline, style: ArtFonts.displayStyle(18 * scale, artOn(accent), spacing: 2, height: 1.2)),
        ),
        SizedBox(height: 4 * scale),
        // Tarja escura: a linha cai sobre o corte diagonal e fica legível.
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
          color: AppColors.black.withValues(alpha: 0.55),
          child: Text(
            t.welcome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(13 * scale, AppColors.white, spacing: 2.4),
          ),
        ),
        SizedBox(height: 7 * scale),
        if (first.isNotEmpty)
          Text(first, maxLines: 1, overflow: TextOverflow.ellipsis, style: ArtFonts.textStyle(22 * scale, AppColors.white, italic: true, height: 1)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              args.data.highlightName.toUpperCase(),
              maxLines: 1,
              style: ArtFonts.displayStyle(58 * scale, AppColors.white, spacing: 0.5, height: 1.05).copyWith(
                shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(0, 3 * scale))],
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Wrap(
          spacing: 8 * scale,
          runSpacing: 6 * scale,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (t.position.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 1.5 * scale),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(t.position, style: ArtFonts.textStyle(12 * scale, AppColors.white, spacing: 2)),
              ),
            if (t.championship.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (args.data.championshipLogoUrl.isNotEmpty) ...[
                    ArtChampionshipLogo(url: args.data.championshipLogoUrl, height: 22 * scale),
                    SizedBox(width: 6 * scale),
                  ],
                  Flexible(
                    child: Text(
                      t.championship,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ArtFonts.textStyle(11 * scale, accent, spacing: 1.8),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Faixa de baixo: o escudo do time com o nome.
class _TeamStrip extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _TeamStrip({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtTeamCrest(team: args.data.team, size: 40 * scale, color: args.teamColor),
        SizedBox(width: 10 * scale),
        Flexible(
          child: Text(
            args.texts.team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.displayStyle(20 * scale, AppColors.white, spacing: 1, height: 1.1),
          ),
        ),
      ],
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    // Parte da área que a foto ocupa; os títulos sobem por cima do pé dela.
    final photoShare = args.story ? 0.72 : (args.square ? 0.74 : 0.76);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, args.story ? 50 : 16, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final photoH = c.maxHeight * photoShare;
              final photoW = (c.maxWidth * 0.9).clamp(0.0, photoH * 0.95);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 4,
                    left: (c.maxWidth - photoW) / 2,
                    child: _Photo(args: args, width: photoW, height: photoH),
                  ),
                  Positioned(
                    left: 4,
                    right: 0,
                    bottom: 0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(width: c.maxWidth - 4, child: _Titles(args: args, scale: s)),
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 12 * s),
          _TeamStrip(args: args, scale: s),
          SizedBox(height: 8 * s),
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
  final PlayerArtArgs args;

  const _Wide(this.args);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A foto na altura toda, à esquerda.
          LayoutBuilder(builder: (context, c) {
            final h = c.maxHeight;
            return Center(child: _Photo(args: args, width: h * 0.82, height: h));
          }),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: 210, child: _Titles(args: args, scale: 0.72)),
                  ),
                ),
                const SizedBox(height: 6),
                _TeamStrip(args: args, scale: 0.6),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: ArtBranding(color: AppColors.white, scale: 0.58, qrData: args.qr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
