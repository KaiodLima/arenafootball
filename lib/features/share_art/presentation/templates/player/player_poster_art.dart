import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';

const _paper = Color(0xFFF3EEE4);
const _ink = Color(0xFF14171A);
const _muted = Color(0xFF8A8F94);

/// Atleta "Pôster" (editorial): papel creme, cabeçalho "{TIME} · ANÚNCIO
/// OFICIAL" com fio duplo, a foto alta em retrato com a faixa na cor do time
/// e, ao lado, o nome empilhado, a posição, o escudo e a competição.
class PlayerPosterArt extends StatelessWidget {
  final PlayerArtArgs args;

  const PlayerPosterArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _paper),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Body(args, scale: 0.62, wide: true) else _Body(args, scale: _scale(args)),
      ],
    );
  }

  static double _scale(PlayerArtArgs args) => args.story ? 1.12 : (args.square ? 0.8 : 1.0);
}

/// Faixa: na paleta "Times", a cor do time; senão, a base da paleta.
Color _band(PlayerArtArgs args) => args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;

class _Masthead extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Masthead({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                args.texts.team,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.displayStyle(16 * scale, _ink, spacing: 1),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text('·  ${args.texts.official}', style: ArtFonts.textStyle(10 * scale, _muted, spacing: 1.8)),
          ],
        ),
        SizedBox(height: 5 * scale),
        Container(height: 2.5 * scale, color: _ink),
        SizedBox(height: 2 * scale),
        Container(height: 0.8 * scale, color: _ink),
      ],
    );
  }
}

/// Foto alta em retrato com a faixa da cor do time embaixo.
class _Portrait extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Portrait({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150 * scale,
      height: 210 * scale,
      decoration: BoxDecoration(
        border: Border.all(color: _ink, width: 2 * scale),
        boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.18), offset: Offset(6 * scale, 6 * scale))],
      ),
      child: Column(
        children: [
          Expanded(
            child: ArtPlayerPhoto(url: args.data.photoUrl, initials: args.data.initials, color: args.teamColor),
          ),
          Container(height: 8 * scale, color: _band(args)),
        ],
      ),
    );
  }
}

/// Nome empilhado, posição, escudo e a competição.
class _Details extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Details({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final d = args.data;
    final words = d.name.trim().toUpperCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.headline, style: ArtFonts.textStyle(11 * scale, _band(args), spacing: 3)),
        SizedBox(height: 4 * scale),
        for (final word in words.take(3))
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(word, maxLines: 1, style: ArtFonts.displayStyle(36 * scale, _ink, height: 1.02)),
          ),
        Container(
          width: 40 * scale,
          height: 3.5 * scale,
          margin: EdgeInsets.symmetric(vertical: 8 * scale),
          color: args.colors.accent,
        ),
        if (t.position.isNotEmpty)
          Text(t.position, style: ArtFonts.textStyle(12 * scale, _muted, spacing: 2.4)),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            ArtTeamCrest(team: d.team, size: 40 * scale, color: args.teamColor),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                t.team,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(13 * scale, _ink, height: 1.05),
              ),
            ),
          ],
        ),
        if (t.championship.isNotEmpty) ...[
          SizedBox(height: 8 * scale),
          Row(
            children: [
              if (d.championshipLogoUrl.isNotEmpty) ...[
                ArtChampionshipLogo(url: d.championshipLogoUrl, height: 20 * scale),
                SizedBox(width: 6 * scale),
              ],
              Expanded(
                child: Text(
                  t.championship,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(10 * scale, _muted, spacing: 1.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;
  final bool wide;

  const _Body(this.args, {required this.scale, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, wide ? 12 : (args.story ? 54 : 20), 22, wide ? 10 : (args.story ? 40 : 14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(args: args, scale: wide ? 0.75 : s),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: wide ? 330 : args.size.width - 44,
                  // Story: a foto grande em cima e os dados embaixo.
                  child: args.story
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: _Portrait(args: args, scale: s * 1.45)),
                            SizedBox(height: 26 * s),
                            _Details(args: args, scale: s * 1.1),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _Portrait(args: args, scale: s),
                            SizedBox(width: 18 * s),
                            Expanded(child: _Details(args: args, scale: s)),
                          ],
                        ),
                ),
              ),
            ),
          ),
          Container(height: 0.8, color: _ink),
          const SizedBox(height: 6),
          ArtBranding(color: _ink, scale: wide ? 0.62 : s * 0.85, qrData: args.qr),
        ],
      ),
    );
  }
}
