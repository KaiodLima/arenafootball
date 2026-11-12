import 'package:flutter/material.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF0E1114);

// Corte diagonal: no alto em 58% da largura, no pé em 42%.
const _cutTop = 0.58;
const _cutBottom = 0.42;

/// Atleta na partida "Duelo" (pôster de luta): a arte dividida na diagonal na
/// ordem da partida; a metade do atleta é a foto dele sangrada de cima a baixo
/// se fundindo na cor do time, com o nome e o escudo do time grande; a outra
/// metade, na cor do adversário, com o escudo gigante e o nome; o "VS" enorme
/// no corte, a competição no alto e DATA | HORÁRIO | LOCAL embaixo.
class DuelArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const DuelArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final athleteLeft = args.data.side == MatchSide.home;
    final team = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final opponent = args.teamColors ? artHalfColor(args.opponentColor) : args.colors.deep;
    final teamGround = Color.lerp(team, AppColors.black, 0.35)!;
    final size = args.size;
    final p = args.data.player;
    final giant = (args.wide ? size.height : size.width) * 0.9;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _SplitPainter(
            left: athleteLeft ? teamGround : opponent,
            right: athleteLeft ? opponent : teamGround,
            accent: args.colors.accent,
          ),
        ),
        // Escudo gigante apagado do adversário, sangrando da borda dele.
        if (args.data.opponent.crestUrl.isNotEmpty)
          Positioned(
            left: athleteLeft ? null : -giant * 0.4,
            right: athleteLeft ? -giant * 0.4 : null,
            top: size.height * (args.wide ? 0.05 : 0.12),
            child: Opacity(
              opacity: 0.14,
              child: ArtTeamCrest(team: args.data.opponent, size: giant, color: args.opponentColor, plain: true),
            ),
          ),
        // A foto do atleta na metade dele, de cima a baixo.
        ClipPath(
          clipper: _HalfClipper(left: athleteLeft),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: athleteLeft ? 0 : size.width * 0.38,
                right: athleteLeft ? size.width * 0.38 : 0,
                top: 0,
                bottom: size.height * (args.wide ? 0 : 0.2),
                child: ArtBleedPhoto(
                  url: p.photoUrl,
                  initials: p.initials,
                  color: args.teamColor,
                  ground: teamGround,
                  tint: team,
                  fadeFrom: 0.5,
                ),
              ),
            ],
          ),
        ),
        // Sombra no alto e no pé (cabeçalho e faixa legíveis).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withValues(alpha: 0.5),
                AppColors.black.withValues(alpha: 0),
                AppColors.black.withValues(alpha: 0),
                AppColors.black.withValues(alpha: 0.6),
              ],
              stops: const [0, 0.22, 0.66, 1],
            ),
          ),
        ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args, athleteLeft: athleteLeft) else _Tall(args, athleteLeft: athleteLeft),
      ],
    );
  }
}

Path _halfPath(Size size, {required bool left}) {
  final w = size.width;
  final h = size.height;
  return left
      ? (Path()
        ..moveTo(0, 0)
        ..lineTo(w * _cutTop, 0)
        ..lineTo(w * _cutBottom, h)
        ..lineTo(0, h)
        ..close())
      : (Path()
        ..moveTo(w * _cutTop, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h)
        ..lineTo(w * _cutBottom, h)
        ..close());
}

class _HalfClipper extends CustomClipper<Path> {
  final bool left;

  const _HalfClipper({required this.left});

  @override
  Path getClip(Size size) => _halfPath(size, left: left);

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) => oldClipper.left != left;
}

/// As duas metades chapadas e o fio de destaque no corte.
class _SplitPainter extends CustomPainter {
  final Color left;
  final Color right;
  final Color accent;

  const _SplitPainter({required this.left, required this.right, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_halfPath(size, left: true), Paint()..color = left);
    canvas.drawPath(_halfPath(size, left: false), Paint()..color = right);
    final w = size.width;
    canvas.drawLine(
      Offset(w * _cutTop, 0),
      Offset(w * _cutBottom, size.height),
      Paint()
        ..color = accent
        ..strokeWidth = w * 0.012,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitPainter old) => old.left != left || old.right != right || old.accent != accent;
}

/// Pílula da competição + tarja do dia e horário.
class _Header extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Header({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    final m = args.texts.match;
    final logo = args.data.match.championshipLogoUrl;
    final when = [m.headline, m.time].where((p) => p.isNotEmpty).join('  ·  ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(logo.isEmpty ? 18 * scale : 6 * scale, 6 * scale, 18 * scale, 6 * scale),
          decoration: BoxDecoration(
            color: _ink.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(40 * scale),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (logo.isNotEmpty) ...[
                ArtChampionshipLogo(url: logo, height: 32 * scale),
                SizedBox(width: 10 * scale),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    m.championship,
                    maxLines: 1,
                    style: ArtFonts.displayStyle(19 * scale, AppColors.white, spacing: 0.8, height: 1.15),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (when.isNotEmpty) ...[
          SizedBox(height: 8 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 3 * scale),
            color: accent,
            child: Text(when, style: ArtFonts.displayStyle(15 * scale, artOn(accent), spacing: 1.4, height: 1.2)),
          ),
        ],
      ],
    );
  }
}

/// "VS" enorme: o contorno de destaque deslocado e o branco cheio por cima.
class _BigVs extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _BigVs({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final size = 86 * scale;
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(5 * scale, 5 * scale),
          child: Text('VS', style: ArtFonts.outlineStyle(size, args.colors.accent, stroke: 3 * scale, height: 1)),
        ),
        Text(
          'VS',
          style: ArtFonts.displayStyle(size, AppColors.white, height: 1).copyWith(
            shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 16 * scale)],
          ),
        ),
      ],
    );
  }
}

/// Metade do atleta (no pé): o nome em camadas, o escudo do time grande e o
/// nome do time.
class _AthleteBlock extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final bool left;

  const _AthleteBlock({required this.args, required this.scale, required this.left});

  @override
  Widget build(BuildContext context) {
    final p = args.data.player;
    final t = args.texts;
    final first = p.firstName.toUpperCase();
    final align = left ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final shadow = [Shadow(color: AppColors.black.withValues(alpha: 0.6), blurRadius: 12 * scale)];
    final crest = PlayerCrestTile(team: args.data.team, color: args.teamColor, size: 62 * scale);
    final teamName = Flexible(
      child: Text(
        t.team,
        maxLines: 2,
        textAlign: left ? TextAlign.left : TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: ArtFonts.displayStyle(19 * scale, AppColors.white, spacing: 0.5, height: 1.05).copyWith(shadows: shadow),
      ),
    );
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first.isNotEmpty)
          Text(
            first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(18 * scale, AppColors.white, italic: true, height: 1).copyWith(shadows: shadow),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: left ? Alignment.centerLeft : Alignment.centerRight,
          child: Text(
            p.highlightName.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(44 * scale, AppColors.white, spacing: 0.4, height: 1.05)
                .copyWith(shadows: shadow),
          ),
        ),
        if (t.player.position.isNotEmpty)
          Text(t.player.position, style: ArtFonts.textStyle(11 * scale, args.colors.accent, spacing: 2.4)),
        SizedBox(height: 10 * scale),
        Row(
          mainAxisSize: MainAxisSize.min,
          children:
              left ? [crest, SizedBox(width: 10 * scale), teamName] : [teamName, SizedBox(width: 10 * scale), crest],
        ),
      ],
    );
  }
}

/// Metade do adversário: o escudo grande no quadro branco e o nome.
class _OpponentBlock extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _OpponentBlock({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerCrestTile(team: args.data.opponent, color: args.opponentColor, size: 118 * scale),
        SizedBox(height: 12 * scale),
        Text(
          args.texts.opponent,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.displayStyle(26 * scale, AppColors.white, spacing: 0.5, height: 1.05).copyWith(
            shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.5), offset: Offset(0, 2 * scale))],
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(width: 36 * scale, height: 4 * scale, color: args.colors.accent),
      ],
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final bool athleteLeft;

  const _Tall(this.args, {required this.athleteLeft});

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.74 : 1.0);
    final half = (args.size.width - 36) / 2;
    Widget fit(Widget child, Alignment alignment) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: SizedBox(width: half - 4, child: child),
        );
    final athleteAlign = athleteLeft ? Alignment.bottomLeft : Alignment.bottomRight;
    final athlete = Align(
      alignment: athleteAlign,
      child: fit(_AthleteBlock(args: args, scale: s, left: athleteLeft), athleteAlign),
    );
    final opponent = Align(
      alignment: const Alignment(0, 0.3),
      child: fit(_OpponentBlock(args: args, scale: s), Alignment.center),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(18, args.story ? 54 : 18, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: s)),
          Expanded(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: athleteLeft ? athlete : opponent),
                    Expanded(child: athleteLeft ? opponent : athlete),
                  ],
                ),
                Align(alignment: const Alignment(0.05, -1), child: _BigVs(args: args, scale: s * 0.78)),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
          PlayerMatchInfoBar(args: args, scale: s),
          SizedBox(height: 10 * s),
          ArtBranding(color: AppColors.white, scale: s * 0.9, qrData: args.qr),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final bool athleteLeft;

  const _Wide(this.args, {required this.athleteLeft});

  @override
  Widget build(BuildContext context) {
    const s = 0.6;
    final athleteAlign = athleteLeft ? Alignment.bottomLeft : Alignment.bottomRight;
    final athlete = Align(
      alignment: athleteAlign,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: athleteAlign,
        child: SizedBox(width: 160, child: _AthleteBlock(args: args, scale: s, left: athleteLeft)),
      ),
    );
    final opponent = Center(
      child: FittedBox(fit: BoxFit.scaleDown, child: SizedBox(width: 150, child: _OpponentBlock(args: args, scale: s))),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: 0.5)),
          Expanded(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: athleteLeft ? athlete : opponent),
                    Expanded(child: athleteLeft ? opponent : athlete),
                  ],
                ),
                Center(child: _BigVs(args: args, scale: 0.6)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: PlayerMatchInfoBar(args: args, scale: 0.5)),
              const SizedBox(width: 10),
              ArtBranding(color: AppColors.white, scale: 0.5, qrData: args.qr),
            ],
          ),
        ],
      ),
    );
  }
}
