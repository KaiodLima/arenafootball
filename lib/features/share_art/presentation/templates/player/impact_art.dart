import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Atleta "Impacto" (tipográfico): o sobrenome repetido em linhas gigantes no
/// fundo, alternando cheio e vazado; na frente, a foto num quadro alto de
/// cantos cortados com sombra dura, o escudo no alto, a tarja "NOVO REFORÇO"
/// na diagonal e a placa com o nome e a posição.
class ImpactArt extends StatelessWidget {
  final PlayerArtArgs args;

  const ImpactArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: _ground(args)),
        _Typography(args),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

Color _ground(PlayerArtArgs args) => args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;

/// Linhas gigantes do sobrenome, levemente inclinadas, cobrindo a arte.
class _Typography extends StatelessWidget {
  final PlayerArtArgs args;

  const _Typography(this.args);

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final ground = _ground(args);
    final on = artOn(ground);
    final word = args.data.highlightName.toUpperCase();
    final rows = args.wide ? 4 : (args.story ? 9 : 7);
    final rowHeight = size.height * 1.3 / rows;
    return OverflowBox(
      maxWidth: size.width * 1.6,
      maxHeight: size.height * 1.3,
      child: Transform.rotate(
        angle: -0.1,
        child: Column(
          children: [
            for (var i = 0; i < rows; i++)
              SizedBox(
                height: rowHeight,
                child: Transform.translate(
                  offset: Offset(i.isEven ? -size.width * 0.08 : size.width * 0.06, 0),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      '$word  $word',
                      maxLines: 1,
                      style: i.isEven
                          ? ArtFonts.outlineStyle(100, on.withValues(alpha: 0.32), stroke: 1.4, height: 1.05)
                          : ArtFonts.displayStyle(100, Color.lerp(ground, AppColors.black, 0.22)!, height: 1.05),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cantos de cima à esquerda e de baixo à direita cortados.
class _ChamferClipper extends CustomClipper<Path> {
  final double cut;

  const _ChamferClipper(this.cut);

  @override
  Path getClip(Size size) => Path()
    ..moveTo(cut, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height - cut)
    ..lineTo(size.width - cut, size.height)
    ..lineTo(0, size.height)
    ..lineTo(0, cut)
    ..close();

  @override
  bool shouldReclip(covariant _ChamferClipper oldClipper) => oldClipper.cut != cut;
}

/// A foto no quadro de cantos cortados, com borda branca e sombra dura.
class _Frame extends StatelessWidget {
  final PlayerArtArgs args;
  final double width;
  final double height;

  const _Frame({required this.args, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final cut = width * 0.14;
    final border = width * 0.025;
    return SizedBox(
      width: width + width * 0.05,
      height: height + width * 0.05,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.05,
            top: width * 0.05,
            child: ClipPath(
              clipper: _ChamferClipper(cut),
              child: Container(width: width, height: height, color: AppColors.black.withValues(alpha: 0.55)),
            ),
          ),
          ClipPath(
            clipper: _ChamferClipper(cut),
            child: Container(
              width: width,
              height: height,
              color: AppColors.white,
              padding: EdgeInsets.all(border),
              child: ClipPath(
                clipper: _ChamferClipper(cut - border),
                child: ArtPlayerPhoto(url: args.data.photoUrl, initials: args.data.initials, color: args.teamColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarja "NOVO REFORÇO" na diagonal.
class _Tag extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Tag({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 3 * scale),
        decoration: BoxDecoration(
          color: accent,
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(3 * scale, 3 * scale))],
        ),
        child: Text(args.texts.newSigning,
            style: ArtFonts.displayStyle(22 * scale, artOn(accent), spacing: 1.5, height: 1.2)),
      ),
    );
  }
}

/// Escudo + nome do time no alto.
class _Header extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Header({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final on = artOn(_ground(args));
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
            style: ArtFonts.displayStyle(20 * scale, on, spacing: 1, height: 1.1),
          ),
        ),
      ],
    );
  }
}

/// Placa preta com o nome completo, a posição e a competição.
class _Plate extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Plate({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final d = args.data;
    final accent = args.colors.accent;
    final meta = [if (t.position.isNotEmpty) t.position, if (t.championship.isNotEmpty) t.championship].join('  ·  ');
    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 10 * scale, 16 * scale, 10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F12),
        border: Border(left: BorderSide(color: accent, width: 6 * scale)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(d.name.toUpperCase(),
                maxLines: 1, style: ArtFonts.displayStyle(38 * scale, AppColors.white, height: 1.1)),
          ),
          if (meta.isNotEmpty) ...[
            SizedBox(height: 4 * scale),
            Row(
              children: [
                if (d.championshipLogoUrl.isNotEmpty) ...[
                  ArtChampionshipLogo(url: d.championshipLogoUrl, height: 18 * scale),
                  SizedBox(width: 6 * scale),
                ],
                Expanded(
                  child: Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(12 * scale, accent, spacing: 2),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.78 : 1.0);
    final on = artOn(_ground(args));
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 52 : 18, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: _Header(args: args, scale: s)),
          SizedBox(height: 10 * s),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final h = c.maxHeight * 0.9;
              final w = (c.maxWidth * 0.74).clamp(0.0, h * 0.8);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(alignment: Alignment.topCenter, child: _Frame(args: args, width: w, height: h)),
                  Positioned(
                    right: 0,
                    top: h * 0.08,
                    child: _Tag(args: args, scale: s),
                  ),
                  Positioned(
                    left: 0,
                    right: c.maxWidth * 0.08,
                    bottom: 0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(width: c.maxWidth * 0.92, child: _Plate(args: args, scale: s)),
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 12 * s),
          Align(alignment: Alignment.centerRight, child: ArtBranding(color: on, scale: s * 0.85, qrData: args.qr)),
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
    final on = artOn(_ground(args));
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, c) {
            final h = c.maxHeight * 0.95;
            return Center(child: _Frame(args: args, width: h * 0.78, height: h));
          }),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(args: args, scale: 0.62),
                const Spacer(),
                _Tag(args: args, scale: 0.65),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(width: 230, child: _Plate(args: args, scale: 0.65)),
                ),
                const Spacer(),
                Align(alignment: Alignment.centerRight, child: ArtBranding(color: on, scale: 0.58, qrData: args.qr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
