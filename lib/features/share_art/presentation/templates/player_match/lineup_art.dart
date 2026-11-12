import 'package:flutter/material.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _board = Color(0xFF123A22);
const _boardDark = Color(0xFF0E2F1B);

/// Profundidade da posição no campo (0 = área do ataque, 1 = o próprio gol).
double lineupDepth(String positionKey) => switch (PlayerPosition.fromKey(positionKey)) {
      PlayerPosition.forward => 0.18,
      PlayerPosition.midfielder => 0.4,
      PlayerPosition.defensiveMidfielder => 0.52,
      PlayerPosition.fullBack || PlayerPosition.defender => 0.7,
      PlayerPosition.goalkeeper => 0.88,
      null => 0.45,
    };

/// Lado no campo (0 = esquerda, 1 = direita): o lateral na ponta, o resto no meio.
double _lineupSide(String positionKey) => PlayerPosition.fromKey(positionKey) == PlayerPosition.fullBack ? 0.16 : 0.5;

/// Atleta na partida "Escalação" (prancheta tática): no alto, o confronto em
/// destaque sobre as cores dos dois times (escudos grandes e nomes); a tarja
/// "NA ESCALAÇÃO!"; a foto grande do atleta com o nome e, ao lado, o campinho
/// tático com a posição dele acesa; embaixo, DATA | HORÁRIO | LOCAL.
class LineupArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const LineupArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final team = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final opponent = args.teamColors ? artHalfColor(args.opponentColor) : args.colors.deep;
    final ground = Color.lerp(team, AppColors.black, 0.7)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: ground),
        ArtHalftone(color: AppColors.white.withValues(alpha: 0.05), from: Alignment.bottomRight, to: Alignment.topLeft),
        CustomPaint(painter: _BandPainter(left: team, right: opponent, wide: args.wide, accent: args.colors.accent)),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args, ground: ground) else _Tall(args, ground: ground),
      ],
    );
  }
}

/// Faixa do confronto: as cores dos dois times com o corte diagonal no meio
/// (no alto da arte; na paisagem, à direita).
class _BandPainter extends CustomPainter {
  final Color left;
  final Color right;
  final Color accent;
  final bool wide;

  const _BandPainter({required this.left, required this.right, required this.accent, required this.wide});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = wide ? Rect.fromLTRB(w * 0.56, 0, w, h * 0.58) : Rect.fromLTRB(0, 0, w, h * 0.33);
    final slant = rect.height * 0.12;
    final mid = rect.left + rect.width / 2;
    final leftPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(mid + rect.width * 0.06, rect.top)
      ..lineTo(mid - rect.width * 0.06, rect.bottom - slant)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    final rightPath = Path()
      ..moveTo(mid + rect.width * 0.06, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom - slant * 2)
      ..lineTo(mid - rect.width * 0.06, rect.bottom - slant)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = left);
    canvas.drawPath(rightPath, Paint()..color = right);
    // Fio de destaque no pé da faixa.
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(mid - rect.width * 0.06, rect.bottom - slant)
        ..lineTo(rect.right, rect.bottom - slant * 2),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008,
    );
  }

  @override
  bool shouldRepaint(covariant _BandPainter old) =>
      old.left != left || old.right != right || old.accent != accent || old.wide != wide;
}

/// Tarja "NA ESCALAÇÃO!".
class _Tag extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Tag({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: accent,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(3 * scale, 3 * scale))],
      ),
      child: Text(args.texts.lineup, style: ArtFonts.displayStyle(24 * scale, artOn(accent), spacing: 1, height: 1.2)),
    );
  }
}

/// A foto grande (cantos arredondados) que some no fundo, com o nome no pé.
class _Photo extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final Color ground;
  final double scale;

  const _Photo({required this.args, required this.ground, required this.scale});

  @override
  Widget build(BuildContext context) {
    final p = args.data.player;
    final t = args.texts;
    final first = p.firstName.toUpperCase();
    final shadow = [Shadow(color: AppColors.black.withValues(alpha: 0.6), blurRadius: 10 * scale)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14 * scale),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ArtBleedPhoto(
            url: p.photoUrl,
            initials: p.initials,
            color: args.teamColor,
            ground: ground,
            tint: args.teamColors ? artHalfColor(args.teamColor) : args.colors.base,
            fadeFrom: 0.45,
          ),
          Positioned(
            left: 10 * scale,
            right: 10 * scale,
            bottom: 10 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (first.isNotEmpty)
                  Text(
                    first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(16 * scale, AppColors.white, italic: true, height: 1)
                        .copyWith(shadows: shadow),
                  ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    p.highlightName.toUpperCase(),
                    maxLines: 1,
                    style: ArtFonts.displayStyle(36 * scale, AppColors.white, height: 1.05).copyWith(shadows: shadow),
                  ),
                ),
                if (t.player.position.isNotEmpty)
                  Text(t.player.position, style: ArtFonts.textStyle(11 * scale, args.colors.accent, spacing: 2.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Campinho tático: verde-escuro com as linhas finas, os companheiros em
/// pontinhos e a posição do atleta acesa com a sigla.
class _Board extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Board({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final key = args.data.player.positionKey;
    final accent = args.colors.accent;
    final abbr = args.texts.player.positionAbbr;
    return AspectRatio(
      aspectRatio: 0.66,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2), width: 1.2 * scale),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.4), blurRadius: 14 * scale)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11 * scale),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const CustomPaint(painter: _BoardPainter()),
              Align(
                alignment: Alignment(_lineupSide(key) * 2 - 1, (lineupDepth(key) * 2 - 1) * 0.92),
                child: Container(
                  width: 34 * scale,
                  height: 34 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2 * scale),
                    boxShadow: [
                      BoxShadow(color: accent.withValues(alpha: 0.8), blurRadius: 14 * scale, spreadRadius: 2 * scale)
                    ],
                  ),
                  child: abbr.isEmpty
                      ? null
                      : Text(abbr, style: ArtFonts.displayStyle(11 * scale, artOn(accent), height: 1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < 8; i++) {
      canvas.drawRect(Rect.fromLTWH(0, h * i / 8, w, h / 8 + 1), Paint()..color = i.isEven ? _board : _boardDark);
    }
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;
    final m = w * 0.07;
    canvas.drawRect(Rect.fromLTRB(m, m, w - m, h - m), line);
    canvas.drawLine(Offset(m, h / 2), Offset(w - m, h / 2), line);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.16, line);
    for (final top in [true, false]) {
      final y = top ? m : h - m;
      final d = top ? 1.0 : -1.0;
      final box = Rect.fromPoints(Offset(w * 0.22, y), Offset(w * 0.78, y + d * h * 0.14));
      canvas.drawRect(box, line);
    }
    // Os companheiros (4-3-3).
    final dot = Paint()..color = AppColors.white.withValues(alpha: 0.35);
    const formation = [
      (0.5, 0.9),
      (0.16, 0.7),
      (0.38, 0.72),
      (0.62, 0.72),
      (0.84, 0.7),
      (0.28, 0.48),
      (0.5, 0.52),
      (0.72, 0.48),
      (0.2, 0.22),
      (0.5, 0.18),
      (0.8, 0.22),
    ];
    for (final (x, y) in formation) {
      canvas.drawCircle(Offset(w * x, h * y), w * 0.035, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => false;
}

class _Tall extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final Color ground;

  const _Tall(this.args, {required this.ground});

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.7 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, args.story ? 50 : 14, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: PlayerMatchSeal(args: args, scale: s * 0.8)),
          SizedBox(height: 6 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: args.size.width - 36, child: PlayerBigMatchup(args: args, scale: s * 0.92)),
          ),
          SizedBox(height: 16 * s),
          Align(alignment: Alignment.centerLeft, child: _Tag(args: args, scale: s)),
          SizedBox(height: 10 * s),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 6, child: _Photo(args: args, ground: ground, scale: s)),
                SizedBox(width: 12 * s),
                Expanded(
                  flex: 4,
                  child: Center(child: _Board(args: args, scale: s)),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * s),
          PlayerMatchInfoBar(args: args, scale: s),
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
  final Color ground;

  const _Wide(this.args, {required this.ground});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: _Photo(args: args, ground: ground, scale: 0.62)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: Center(child: _Board(args: args, scale: 0.6))),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(width: 220, child: PlayerBigMatchup(args: args, scale: 0.62))),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerLeft, child: _Tag(args: args, scale: 0.6)),
                const Spacer(),
                PlayerMatchInfoBar(args: args, scale: 0.5),
                const SizedBox(height: 6),
                Align(
                    alignment: Alignment.centerRight,
                    child: ArtBranding(color: AppColors.white, scale: 0.5, qrData: args.qr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
