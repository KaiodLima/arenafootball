import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _stage = Color(0xFF050608);

/// Atleta na partida "Holofote" (pôster premium): palco escuro com o feixe de
/// luz do alto sobre o atleta (a foto some no preto pelas bordas) e dois
/// feixes laterais, um em cada cor de time; o nome grande com o sublinhado do
/// time; o confronto em destaque (escudos grandes e os nomes) e a faixa com
/// o dia, o horário e o local.
class SpotlightArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const SpotlightArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final team = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final opponent = args.teamColors ? artHalfColor(args.opponentColor) : args.colors.accent;
    final p = args.data.player;
    final photoRect = args.wide
        ? Rect.fromLTWH(0, 0, size.width * 0.5, size.height)
        : Rect.fromLTWH(size.width * 0.06, 0, size.width * 0.88, size.height * 0.5);
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _stage),
        CustomPaint(
          painter: _BeamsPainter(left: team, right: opponent, center: args.wide ? 0.25 : 0.5),
        ),
        // A foto recortada pela luz: some no palco pelas bordas.
        Positioned.fromRect(
          rect: photoRect,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const RadialGradient(
              center: Alignment(0, -0.3),
              radius: 0.75,
              colors: [AppColors.white, AppColors.white, Color(0x00FFFFFF)],
              stops: [0, 0.55, 1],
            ).createShader(rect),
            child: ArtPlayerPhoto(url: p.photoUrl, initials: p.initials, color: args.teamColor),
          ),
        ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// O feixe branco do alto sobre o atleta e os dois laterais nas cores dos
/// times, mais a mancha de luz no chão.
class _BeamsPainter extends CustomPainter {
  final Color left;
  final Color right;
  final double center;

  const _BeamsPainter({required this.left, required this.right, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * center;
    Paint beam(Color color, double alpha, Offset from, Offset to) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
      ).createShader(Rect.fromPoints(from, to));
    // Laterais, um em cada cor de time.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.18, 0)
        ..lineTo(cx - w * 0.05, h * 0.75)
        ..lineTo(cx - w * 0.4, h * 0.75)
        ..close(),
      beam(left, 0.55, Offset.zero, Offset(w, h * 0.75)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, 0)
        ..lineTo(w * 0.82, 0)
        ..lineTo(cx + w * 0.05, h * 0.75)
        ..lineTo(cx + w * 0.4, h * 0.75)
        ..close(),
      beam(right, 0.55, Offset.zero, Offset(w, h * 0.75)),
    );
    // O feixe branco do alto.
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.08, 0)
        ..lineTo(cx + w * 0.08, 0)
        ..lineTo(cx + w * 0.42, h * 0.66)
        ..lineTo(cx - w * 0.42, h * 0.66)
        ..close(),
      beam(AppColors.white, 0.16, Offset.zero, Offset(w, h * 0.66)),
    );
    // Luz no chão.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.62), width: w * 0.8, height: h * 0.06),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(covariant _BeamsPainter old) => old.left != left || old.right != right || old.center != center;
}

/// O nome: primeiro nome, SOBRENOME grande e o sublinhado na cor do time.
class _Name extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  const _Name({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final p = args.data.player;
    final t = args.texts;
    final first = p.firstName.toUpperCase();
    final team = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final line = artOn(team) == AppColors.white
        ? Color.lerp(team, AppColors.white, 0.15)!
        : Color.lerp(team, AppColors.black, 0.2)!;
    final shadow = [Shadow(color: AppColors.black.withValues(alpha: 0.7), blurRadius: 14 * scale)];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first.isNotEmpty)
          Text(
            first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(20 * scale, AppColors.white, italic: true, height: 1, spacing: 1.2)
                .copyWith(shadows: shadow),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            p.highlightName.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(54 * scale, AppColors.white, spacing: 0.6, height: 1.05)
                .copyWith(shadows: shadow),
          ),
        ),
        Container(width: 120 * scale, height: 5 * scale, color: line),
        if (t.player.position.isNotEmpty) ...[
          SizedBox(height: 6 * scale),
          Text(t.player.position, style: ArtFonts.textStyle(12 * scale, args.colors.accent, spacing: 3)),
        ],
      ],
    );
  }
}

/// Faixa fina: dia · horário · local.
class _When extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _When({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final m = args.texts.match;
    final accent = args.colors.accent;
    final day =
        m.shortDate.isEmpty ? m.headline : (m.headline == m.weekday ? m.shortDate : '${m.headline}  ·  ${m.shortDate}');
    final text = [day, if (m.time.isNotEmpty) m.time, m.venue].join('  ·  ');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child:
            Text(text, maxLines: 1, style: ArtFonts.displayStyle(15 * scale, artOn(accent), spacing: 1, height: 1.2)),
      ),
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.7 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, args.story ? 50 : 14, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: PlayerMatchSeal(args: args, scale: s * 0.85)),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: args.size.width - 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Name(args: args, scale: s),
                      SizedBox(height: 16 * s),
                      PlayerBigMatchup(args: args, scale: s * 0.8),
                      SizedBox(height: 8 * s),
                      _When(args: args, scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          ArtBranding(color: AppColors.white, scale: s * 0.8, qrData: args.qr),
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
      padding: EdgeInsets.fromLTRB(args.size.width * 0.48, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: PlayerMatchSeal(args: args, scale: 0.55)),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 230,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Name(args: args, scale: 0.6),
                      const SizedBox(height: 10),
                      PlayerBigMatchup(args: args, scale: 0.62),
                      const SizedBox(height: 6),
                      _When(args: args, scale: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: ArtBranding(color: AppColors.white, scale: 0.5, qrData: args.qr)),
        ],
      ),
    );
  }
}
