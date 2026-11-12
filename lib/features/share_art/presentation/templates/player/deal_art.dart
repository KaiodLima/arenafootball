import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player/player_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Atleta "Fechado!" (foto sangrada dos anúncios oficiais): a foto de borda a
/// borda se funde no fundo da cor do time, o sobrenome gigante vazado por
/// cima e, embaixo, o selo do escudo, o carimbo "FECHADO!", "AGORA É
/// {TIME}!", o nome, posição · competição e os números (só os > 0).
class DealArt extends StatelessWidget {
  final PlayerArtArgs args;

  const DealArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final ground = _ground(args);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: ground),
        if (args.wide)
          Positioned(left: 0, top: 0, bottom: 0, width: size.width * 0.5, child: _BleedPhoto(args, horizontal: true))
        else
          Positioned(
              left: 0, right: 0, top: 0, height: size.height * (args.story ? 0.62 : 0.64), child: _BleedPhoto(args)),
        _GhostName(args),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Fundo: na paleta "Times", a cor do time bem escura; senão, a base escura.
Color _ground(PlayerArtArgs args) => args.teamColors
    ? Color.lerp(artHalfColor(args.teamColor), AppColors.black, 0.62)!
    : Color.lerp(args.colors.deep, AppColors.black, 0.25)!;

/// A foto sangrada, sumindo no fundo (para baixo ou, na paisagem, à direita).
class _BleedPhoto extends StatelessWidget {
  final PlayerArtArgs args;
  final bool horizontal;

  const _BleedPhoto(this.args, {this.horizontal = false});

  @override
  Widget build(BuildContext context) => ArtBleedPhoto(
        url: args.data.photoUrl,
        initials: args.data.initials,
        color: args.teamColor,
        ground: _ground(args),
        tint: args.teamColors ? artHalfColor(args.teamColor) : args.colors.base,
        horizontal: horizontal,
      );
}

/// Sobrenome gigante vazado, atravessando a arte na altura do pé da foto.
class _GhostName extends StatelessWidget {
  final PlayerArtArgs args;

  const _GhostName(this.args);

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final text = args.data.highlightName.toUpperCase();
    final width = size.width * (args.wide ? 0.9 : 1.25);
    return Positioned(
      left: args.wide ? size.width * 0.12 : -size.width * 0.12,
      top: size.height * (args.wide ? 0.02 : (args.story ? 0.4 : 0.36)),
      width: width,
      child: Opacity(
        opacity: 0.5,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            text,
            maxLines: 1,
            style: ArtFonts.outlineStyle(120, AppColors.white, stroke: 1.6, height: 1.05),
          ),
        ),
      ),
    );
  }
}

/// Selo do escudo + carimbo "FECHADO!".
class _Seal extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Seal({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58 * scale,
          height: 58 * scale,
          padding: EdgeInsets.all(7 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.4), blurRadius: 12 * scale)],
          ),
          child: ArtTeamCrest(team: args.data.team, size: 44 * scale, color: args.teamColor, plain: true),
        ),
        SizedBox(width: 12 * scale),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Transform.rotate(
              angle: -0.07,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 2 * scale),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4 * scale),
                  boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(0, 3 * scale))],
                ),
                child: Text(args.texts.closed,
                    style: ArtFonts.displayStyle(30 * scale, artOn(accent), spacing: 1, height: 1.2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "AGORA É {TIME}!", o nome, posição · competição e os números.
class _Info extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Info({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final d = args.data;
    final accent = args.colors.accent;
    final meta = [if (t.position.isNotEmpty) t.position, if (t.championship.isNotEmpty) t.championship].join('  ·  ');
    final stats = [
      if (d.goals > 0) (d.goals, t.goalsLabel),
      if (d.assists > 0) (d.assists, t.assistsLabel),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Seal(args: args, scale: scale),
        SizedBox(height: 14 * scale),
        Text(
          t.deal,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(15 * scale, accent, spacing: 3),
        ),
        SizedBox(height: 2 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            d.name.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(50 * scale, AppColors.white, spacing: 0.5, height: 1.08).copyWith(
              shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.45), blurRadius: 10 * scale)],
            ),
          ),
        ),
        if (meta.isNotEmpty) ...[
          SizedBox(height: 6 * scale),
          Row(
            children: [
              if (d.championshipLogoUrl.isNotEmpty) ...[
                ArtChampionshipLogo(url: d.championshipLogoUrl, height: 20 * scale),
                SizedBox(width: 8 * scale),
              ],
              Expanded(
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(13 * scale, AppColors.white.withValues(alpha: 0.85), spacing: 2),
                ),
              ),
            ],
          ),
        ],
        if (stats.isNotEmpty) ...[
          SizedBox(height: 12 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 6 * scale,
            children: [
              for (final (value, label) in stats)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(30 * scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$value', style: ArtFonts.displayStyle(18 * scale, AppColors.white, height: 1.2)),
                      SizedBox(width: 6 * scale),
                      Text(label, style: ArtFonts.textStyle(11 * scale, accent, spacing: 1.6)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// "ANÚNCIO OFICIAL" no alto, com o fio de destaque.
class _Official extends StatelessWidget {
  final PlayerArtArgs args;
  final double scale;

  const _Official({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 22 * scale, height: 3 * scale, color: args.colors.accent),
        SizedBox(width: 8 * scale),
        Text(
          args.texts.official,
          style: ArtFonts.textStyle(12 * scale, AppColors.white, spacing: 3.5).copyWith(
            shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.6), blurRadius: 6)],
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
    final s = args.story ? 1.15 : (args.square ? 0.78 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 52 : 18, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: _Official(args: args, scale: s)),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: SizedBox(width: args.size.width - 44, child: _Info(args: args, scale: s)),
              ),
            ),
          ),
          SizedBox(height: 14 * s),
          Align(
            alignment: Alignment.centerRight,
            child: ArtBranding(color: AppColors.white, scale: s * 0.85, qrData: args.qr),
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
    final left = args.size.width * 0.44;
    return Padding(
      padding: EdgeInsets.fromLTRB(left, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: _Official(args: args, scale: 0.62)),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 260, child: _Info(args: args, scale: 0.7)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ArtBranding(color: AppColors.white, scale: 0.58, qrData: args.qr),
          ),
        ],
      ),
    );
  }
}
