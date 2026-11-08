import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Modelo "Confronto" (frente a frente): cada time numa metade da arte (em
/// cima/embaixo; na paisagem, esquerda/direita) na cor dele, com retícula,
/// escudo grande, o nome gigante em itálico e os gols dele; as metades se
/// encontram num corte em raio e o placar fica num selo inclinado sobre ele.
class FaceOffArt extends StatelessWidget {
  final ResultArtArgs args;

  const FaceOffArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final vertical = !args.wide;
    final theme = args.theme;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _SplitPainter(first: theme.home, second: theme.away, vertical: vertical)),
        // Retícula em cada metade, mais forte longe do corte.
        Positioned.fill(
          child: ClipPath(
            clipper: _HalfClipper(first: true, vertical: vertical),
            child: ArtHalftone(
              color: artOn(theme.home).withValues(alpha: 0.13),
              from: vertical ? Alignment.bottomCenter : Alignment.centerRight,
              to: vertical ? Alignment.topCenter : Alignment.centerLeft,
            ),
          ),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: _HalfClipper(first: false, vertical: vertical),
            child: ArtHalftone(
              color: artOn(theme.away).withValues(alpha: 0.13),
              from: vertical ? Alignment.topCenter : Alignment.centerLeft,
              to: vertical ? Alignment.bottomCenter : Alignment.centerRight,
            ),
          ),
        ),
        const ArtGrain(opacity: 0.06),
        if (vertical) _FaceOffTall(args) else _FaceOffWide(args),
      ],
    );
  }
}

/// Os pontos do corte em raio (proporções do lado comprido).
List<Offset> _boltPoints(Size size, bool vertical) {
  if (vertical) {
    final y = size.height * 0.5;
    final a = size.height * 0.035;
    return [
      Offset(0, y - a),
      Offset(size.width * 0.38, y + a * 0.6),
      Offset(size.width * 0.52, y - a * 0.9),
      Offset(size.width, y + a),
    ];
  }
  final x = size.width * 0.5;
  final a = size.width * 0.03;
  return [
    Offset(x + a, 0),
    Offset(x - a * 0.6, size.height * 0.4),
    Offset(x + a * 0.9, size.height * 0.56),
    Offset(x - a, size.height),
  ];
}

Path _halfPath(Size size, bool vertical, bool first) {
  final bolt = _boltPoints(size, vertical);
  final path = Path()..moveTo(bolt.first.dx, bolt.first.dy);
  for (final p in bolt.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  if (vertical) {
    if (first) {
      path
        ..lineTo(size.width, 0)
        ..lineTo(0, 0);
    } else {
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }
  } else {
    if (first) {
      path
        ..lineTo(0, size.height)
        ..lineTo(0, 0);
    } else {
      path
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }
  }
  return path..close();
}

class _HalfClipper extends CustomClipper<Path> {
  final bool first;
  final bool vertical;

  _HalfClipper({required this.first, required this.vertical});

  @override
  Path getClip(Size size) => _halfPath(size, vertical, first);

  @override
  bool shouldReclip(covariant _HalfClipper old) => old.first != first || old.vertical != vertical;
}

class _SplitPainter extends CustomPainter {
  final Color first;
  final Color second;
  final bool vertical;

  _SplitPainter({required this.first, required this.second, required this.vertical});

  @override
  void paint(Canvas canvas, Size size) {
    Shader shade(Color c, bool isFirst) => LinearGradient(
          begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
          end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: isFirst ? [Color.lerp(c, AppColors.black, 0.35)!, c] : [c, Color.lerp(c, AppColors.black, 0.35)!],
        ).createShader(Offset.zero & size);
    canvas.drawPath(_halfPath(size, vertical, true), Paint()..shader = shade(first, true));
    canvas.drawPath(_halfPath(size, vertical, false), Paint()..shader = shade(second, false));
    // Faixa branca do raio, com sombra.
    final bolt = _boltPoints(size, vertical);
    final line = Path()..moveTo(bolt.first.dx, bolt.first.dy);
    for (final p in bolt.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final stroke = size.shortestSide * 0.022;
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2.2
        ..color = AppColors.black.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.miter
        ..color = AppColors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SplitPainter old) =>
      old.first != first || old.second != second || old.vertical != vertical;
}

/// Selo inclinado com o placar (sobre o corte).
class _ScoreBadge extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;

  const _ScoreBadge({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    return Transform.rotate(
      angle: -0.07,
      child: Container(
        padding: EdgeInsets.fromLTRB(18 * scale, 6 * scale, 18 * scale, 8 * scale),
        decoration: BoxDecoration(
          color: Color.lerp(args.theme.brandDark, AppColors.black, 0.4),
          border: Border.all(color: AppColors.white, width: 2.5 * scale),
          boxShadow: [
            BoxShadow(
                color: AppColors.black.withValues(alpha: 0.45), blurRadius: 16 * scale, offset: Offset(0, 6 * scale))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(args.texts.status, style: ArtFonts.textStyle(9 * scale, AppColors.gold, spacing: 2.2)),
            Text(
              '${data.homeGoals} - ${data.awayGoals}',
              style: ArtFonts.displayStyle(52 * scale, AppColors.white, spacing: 2),
            ),
            if (args.texts.halfTime != null)
              Text(args.texts.halfTime!,
                  style: ArtFonts.textStyle(8 * scale, AppColors.whiteSoft, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Metade de um time: escudo, nome gigante e gols.
class _Half extends StatelessWidget {
  final ResultArtArgs args;
  final ArtSide side;
  final double scale;
  final bool alignEnd;
  final int maxGoals;
  final bool compact;

  const _Half({
    required this.args,
    required this.side,
    required this.scale,
    required this.alignEnd,
    required this.maxGoals,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final team = side == ArtSide.home ? data.home : data.away;
    final color = args.theme.sideColor(side);
    final text = artOn(color);
    final goals = data.goalsOf(side);
    final shown = goals.take(maxGoals).toList();
    final crest = FittedBox(
      fit: BoxFit.scaleDown,
      child:
          ArtTeamCrest(team: team, size: (compact ? 64 : 92) * scale, color: Color.lerp(color, AppColors.black, 0.2)!),
    );
    final info = Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          team.name.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: ArtFonts.textStyle((compact ? 18 : 26) * scale, text, italic: true, height: 0.95),
        ),
        if (data.winner == side) ...[
          SizedBox(height: 4 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1.5 * scale),
            color: AppColors.gold,
            child: Icon(Icons.star_rounded, size: 11 * scale, color: AppColors.textPrimary),
          ),
        ],
        SizedBox(height: 6 * scale),
        for (final g in shown)
          ArtScorerLine(
            goal: g,
            noScorer: args.texts.noScorer,
            color: text,
            pill: text,
            scale: scale * 0.95,
            alignEnd: alignEnd,
          ),
        if (goals.length > shown.length)
          Text('+${goals.length - shown.length}', style: ArtFonts.textStyle(10 * scale, text.withValues(alpha: 0.8))),
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: alignEnd
          ? [Expanded(child: info), SizedBox(width: 12 * scale), crest]
          : [crest, SizedBox(width: 12 * scale), Expanded(child: info)],
    );
  }
}

class _FaceOffTall extends StatelessWidget {
  final ResultArtArgs args;

  const _FaceOffTall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.12 : (args.square ? 0.78 : 1.0);
    final maxGoals = args.square ? 2 : (args.story ? 6 : 4);
    final top = args.story ? 52.0 : 18.0;
    final bottom = args.story ? 40.0 : 12.0;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
                color: AppColors.black.withValues(alpha: 0.35),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (args.logoUrl.isNotEmpty) ...[
                      ArtChampionshipLogo(url: args.logoUrl, height: 20 * s),
                      SizedBox(width: 8 * s),
                    ],
                    Flexible(
                      child: Text(
                        args.texts.championship,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArtFonts.textStyle(10 * s, AppColors.white, spacing: 2.2),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    Center(child: _Half(args: args, side: ArtSide.home, scale: s, alignEnd: false, maxGoals: maxGoals)),
              ),
              // Espaço do selo do placar sobre o corte.
              SizedBox(height: (args.square ? 80 : 100) * s),
              Expanded(
                child:
                    Center(child: _Half(args: args, side: ArtSide.away, scale: s, alignEnd: true, maxGoals: maxGoals)),
              ),
              if (args.texts.info.isNotEmpty && !args.square)
                Padding(
                  padding: EdgeInsets.only(bottom: 8 * s),
                  child: Text(
                    args.texts.info,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(9.5 * s, artOn(args.theme.away).withValues(alpha: 0.85), spacing: 1),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
                color: AppColors.black.withValues(alpha: 0.35),
                child: ArtBranding(color: AppColors.white, scale: s, qrData: args.qr),
              ),
            ],
          ),
        ),
        Center(child: _ScoreBadge(args: args, scale: s * (args.square ? 0.8 : 1))),
      ],
    );
  }
}

class _FaceOffWide extends StatelessWidget {
  final ResultArtArgs args;

  const _FaceOffWide(this.args);

  @override
  Widget build(BuildContext context) {
    const s = 0.72;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (args.logoUrl.isNotEmpty) ...[
                    ArtChampionshipLogo(url: args.logoUrl, height: 18),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      args.texts.championship,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ArtFonts.textStyle(9, AppColors.white, spacing: 2),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child:
                          _Half(args: args, side: ArtSide.home, scale: s, alignEnd: false, maxGoals: 2, compact: true),
                    ),
                    const SizedBox(width: 96),
                    Expanded(
                      child:
                          _Half(args: args, side: ArtSide.away, scale: s, alignEnd: true, maxGoals: 2, compact: true),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: AppColors.black.withValues(alpha: 0.35),
                child: ArtBranding(color: AppColors.white, scale: 0.72, qrData: args.qr),
              ),
            ],
          ),
        ),
        Center(child: _ScoreBadge(args: args, scale: 0.72)),
      ],
    );
  }
}
