import 'dart:io';

import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/art_photo_framing.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Fontes das artes (empacotadas): display condensada e texto condensado.
abstract final class ArtFonts {
  static const String display = 'Anton';
  static const String text = 'BarlowCondensed';

  static TextStyle displayStyle(double size, Color color, {double spacing = 0, double height = 1}) => TextStyle(
        fontFamily: display,
        fontSize: size,
        color: color,
        letterSpacing: spacing,
        height: height,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Anton vazado: só o contorno, na [color], com o traço [stroke].
  static TextStyle outlineStyle(double size, Color color,
          {double stroke = 1.5, double spacing = 0, double height = 1}) =>
      TextStyle(
        fontFamily: display,
        fontSize: size,
        letterSpacing: spacing,
        height: height,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color,
      );

  static TextStyle textStyle(
    double size,
    Color color, {
    FontWeight weight = FontWeight.w700,
    bool italic = false,
    double spacing = 0,
    double height = 1.1,
  }) =>
      TextStyle(
        fontFamily: text,
        fontSize: size,
        color: color,
        fontWeight: italic ? FontWeight.w800 : weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: spacing,
        height: height,
      );
}

/// Cor do texto sobre a cor [background] das artes: branco, salvo em cor
/// clara (aí, tinta escura). Mais "de pôster" que o contraste estrito.
Color artOn(Color background) => isLightColor(background) ? const Color(0xFF14171A) : AppColors.white;

/// Logo do campeonato num selo branco (a imagem pode ser quadrada ou um
/// banner largo: cabe inteira na altura dada). Sem URL, carregando ou se a
/// imagem falhar, não ocupa nada: a arte segue só com o nome.
class ArtChampionshipLogo extends StatelessWidget {
  final String url;
  final double height;

  /// Troca nos testes (imagem em memória).
  static ImageProvider Function(String url) providerFor = _network;

  static ImageProvider _network(String url) => CachedNetworkImageProvider(url);

  /// Sem o selo branco (logo grande ou marca d'água).
  final bool plain;

  const ArtChampionshipLogo({super.key, required this.url, required this.height, this.plain = false});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Image(
      image: providerFor(url),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      frameBuilder: (_, child, frame, sync) => frame == null && !sync
          ? const SizedBox.shrink()
          : plain
              ? SizedBox(height: height, child: child)
              : Container(
                  height: height,
                  constraints: BoxConstraints(maxWidth: height * 3),
                  padding: EdgeInsets.all(height * 0.1),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(height * 0.18),
                    boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: height * 0.2)],
                  ),
                  child: child,
                ),
    );
  }
}

/// Retícula (meio-tom): pontos que crescem na direção [from] → [to].
class ArtHalftone extends StatelessWidget {
  final Color color;
  final double spacing;
  final Alignment from;
  final Alignment to;

  const ArtHalftone({
    super.key,
    required this.color,
    this.spacing = 7,
    this.from = Alignment.topLeft,
    this.to = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _HalftonePainter(color: color, spacing: spacing, from: from, to: to), size: Size.infinite);
}

class _HalftonePainter extends CustomPainter {
  final Color color;
  final double spacing;
  final Alignment from;
  final Alignment to;

  _HalftonePainter({required this.color, required this.spacing, required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final a = from.alongSize(size);
    final b = to.alongSize(size);
    final length = (b - a).distance;
    if (length == 0) return;
    for (var y = 0.0; y < size.height + spacing; y += spacing) {
      final shift = ((y / spacing).round().isOdd) ? spacing / 2 : 0.0;
      for (var x = shift; x < size.width + spacing; x += spacing) {
        final p = Offset(x, y);
        // Projeção no eixo do degradê: 0 em [from], 1 em [to].
        final t = (((p - a).dx * (b - a).dx + (p - a).dy * (b - a).dy) / (length * length)).clamp(0.0, 1.0);
        final r = spacing * 0.42 * t;
        if (r > 0.25) canvas.drawCircle(p, r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) =>
      old.color != color || old.spacing != spacing || old.from != from || old.to != to;
}

/// Faixas diagonais paralelas (sensação de velocidade).
class ArtSpeedStripes extends StatelessWidget {
  final Color color;
  final int count;
  final double width;
  final double gap;
  final double angle;

  const ArtSpeedStripes({
    super.key,
    required this.color,
    this.count = 4,
    this.width = 10,
    this.gap = 8,
    this.angle = -0.5,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _StripesPainter(color: color, count: count, width: width, gap: gap, angle: angle),
        size: Size.infinite,
      );
}

class _StripesPainter extends CustomPainter {
  final Color color;
  final int count;
  final double width;
  final double gap;
  final double angle;

  _StripesPainter(
      {required this.color, required this.count, required this.width, required this.gap, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);
    final long = size.longestSide * 2;
    final total = count * width + (count - 1) * gap;
    for (var i = 0; i < count; i++) {
      final x = -total / 2 + i * (width + gap);
      canvas.drawRect(
        Rect.fromLTWH(x, -long / 2, width, long),
        Paint()..color = color.withValues(alpha: color.a * (1 - i * 0.18).clamp(0.2, 1)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripesPainter old) =>
      old.color != color || old.count != count || old.width != width || old.gap != gap || old.angle != angle;
}

/// Grão de filme: pontinhos claros/escuros com semente fixa (a arte sai
/// sempre igual).
class ArtGrain extends StatelessWidget {
  final double opacity;

  const ArtGrain({super.key, this.opacity = 0.06});

  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(painter: _GrainPainter(opacity), size: Size.infinite));
}

class _GrainPainter extends CustomPainter {
  final double opacity;

  _GrainPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final light = Paint()..color = AppColors.white.withValues(alpha: opacity);
    final dark = Paint()..color = AppColors.black.withValues(alpha: opacity);
    final count = (size.width * size.height / 18).round();
    for (var i = 0; i < count; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawRect(Rect.fromLTWH(p.dx, p.dy, 0.7, 0.7), random.nextBool() ? light : dark);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.opacity != opacity;
}

/// Texto gigante vazado (só o contorno), para o fundo.
class ArtOutlineText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double stroke;

  const ArtOutlineText({super.key, required this.text, required this.size, required this.color, this.stroke = 1.2});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontFamily: ArtFonts.display,
          fontSize: size,
          height: 0.95,
          letterSpacing: size * 0.02,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = color,
        ),
      );
}

/// Escudo do time: a imagem ou, sem ela (ou se falhar), um escudo desenhado
/// com as iniciais na cor do time. [plain] = sem o fundo branco (escudo
/// gigante apagado do fundo).
class ArtTeamCrest extends StatelessWidget {
  final ArtTeam team;
  final double size;
  final Color color;
  final bool plain;

  const ArtTeamCrest({super.key, required this.team, required this.size, required this.color, this.plain = false});

  @override
  Widget build(BuildContext context) {
    final drawn = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(color: color, border: plain ? null : AppColors.white),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.08),
            child: Text(
              team.initials,
              style: ArtFonts.displayStyle(size * 0.3, artOn(color), spacing: size * 0.01),
            ),
          ),
        ),
      ),
    );
    if (team.crestUrl.isEmpty) return drawn;
    final image = Image(
      image: CachedNetworkImageProvider(team.crestUrl),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => drawn,
    );
    if (plain) return image;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3), blurRadius: size * 0.15, offset: Offset(0, size * 0.04))
        ],
      ),
      child: ClipOval(child: image),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  final Color? border;

  _ShieldPainter({required this.color, this.border});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.9, h * 0.16)
      ..lineTo(w * 0.86, h * 0.58)
      ..quadraticBezierTo(w * 0.8, h * 0.82, w * 0.5, h * 0.96)
      ..quadraticBezierTo(w * 0.2, h * 0.82, w * 0.14, h * 0.58)
      ..lineTo(w * 0.1, h * 0.16)
      ..close();
    canvas.drawShadow(path, AppColors.black, w * 0.04, false);
    canvas.drawPath(path, Paint()..color = color);
    // Faixa clara no alto (brilho do escudo).
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.32), Paint()..color = AppColors.white.withValues(alpha: 0.12));
    canvas.restore();
    if (border != null) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.045
          ..color = border!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => old.color != color || old.border != border;
}

/// Faixa de "ingresso": competição à esquerda e data · horário · local à
/// direita, com os recortes serrilhados nas pontas.
class ArtTicketStrip extends StatelessWidget {
  final String left;
  final String right;
  final Color background;
  final Color foreground;
  final double scale;

  const ArtTicketStrip({
    super.key,
    required this.left,
    required this.right,
    required this.background,
    required this.foreground,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketPainter(background),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 7 * scale),
        child: Row(
          children: [
            // Só um lado: ocupa a faixa inteira, centralizado.
            if (right.isEmpty)
              Expanded(
                child: Text(
                  left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ArtFonts.textStyle(10 * scale, foreground, spacing: 1.4),
                ),
              )
            else
              Flexible(
                child: Text(
                  left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(10 * scale, foreground, spacing: 1.4),
                ),
              ),
            if (left.isNotEmpty && right.isNotEmpty)
              Container(
                width: 1,
                height: 12 * scale,
                margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                color: foreground.withValues(alpha: 0.4),
              ),
            if (right.isNotEmpty)
              Flexible(
                child: Text(
                  right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: ArtFonts.textStyle(10 * scale, foreground.withValues(alpha: 0.85), weight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  final Color color;

  _TicketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final notch = size.height * 0.28;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 2 - notch)
      ..arcToPoint(Offset(size.width, size.height / 2 + notch), radius: Radius.circular(notch), clockwise: false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 2 + notch)
      ..arcToPoint(Offset(0, size.height / 2 - notch), radius: Radius.circular(notch), clockwise: false)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TicketPainter old) => old.color != color;
}

/// Linha de gol: minuto numa pílula + autor (ou "Gol" sem autor).
class ArtScorerLine extends StatelessWidget {
  final ArtGoal goal;
  final String noScorer;
  final Color color;
  final Color pill;
  final double scale;
  final bool alignEnd;

  const ArtScorerLine({
    super.key,
    required this.goal,
    required this.noScorer,
    required this.color,
    required this.pill,
    this.scale = 1,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final minute = goal.minute == null
        ? const SizedBox.shrink()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 1 * scale),
            decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(3 * scale)),
            child: Text("${goal.minute}'", style: ArtFonts.textStyle(9 * scale, artOn(pill))),
          );
    final name = Flexible(
      child: Text(
        (goal.scorer.isEmpty ? noScorer : goal.scorer).toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: ArtFonts.textStyle(11 * scale, color, spacing: 0.4),
      ),
    );
    final gap = SizedBox(width: 5 * scale);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5 * scale),
      child: Row(
        mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: alignEnd ? [name, gap, minute] : [minute, gap, name],
      ),
    );
  }
}

/// Fundo da metade: a cor do time; muito clara, um pouco mais escura para o
/// branco do corte e das placas não sumirem.
Color artHalfColor(Color color) => isLightColor(color) ? Color.lerp(color, AppColors.black, 0.12)! : color;

/// Linha do corte: em cima/à esquerda a casa, do outro lado o visitante.
(Offset, Offset) artCut(Size size, bool wide) => wide
    ? (Offset(size.width * 0.58, 0), Offset(size.width * 0.42, size.height))
    : (Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.44));

/// Fundo em duas metades nas cores dos times, com o corte diagonal branco e
/// dourado, retícula perto do corte e um feixe de luz ("Cores", "Dia de jogo").
class ArtSplitPainter extends CustomPainter {
  final Color home;
  final Color away;
  final bool wide;

  /// Fio do corte (padrão: dourado).
  final Color accent;

  ArtSplitPainter({required this.home, required this.away, required this.wide, this.accent = AppColors.gold});

  Shader _shade(Color color, Rect rect, Alignment light) => LinearGradient(
        begin: light,
        end: -light,
        colors: [Color.lerp(color, AppColors.white, 0.16)!, color, Color.lerp(color, AppColors.black, 0.22)!],
        stops: const [0, 0.55, 1],
      ).createShader(rect);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final (a, b) = artCut(size, wide);
    final awayPath = wide
        ? (Path()
          ..moveTo(a.dx, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(b.dx, size.height)
          ..close())
        : (Path()
          ..moveTo(0, a.dy)
          ..lineTo(size.width, b.dy)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close());
    canvas.drawRect(rect, Paint()..shader = _shade(home, rect, Alignment.topLeft));
    canvas.drawPath(awayPath, Paint()..shader = _shade(away, rect, Alignment.bottomRight));

    // Feixe de luz diagonal ("luz de estádio").
    final beam = Path()
      ..moveTo(size.width * 0.18, 0)
      ..lineTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.02, size.height)
      ..lineTo(-size.width * 0.22, size.height)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0.09),
            AppColors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    // Retícula grossa só perto do corte, dos dois lados.
    final dir = (b - a) / (b - a).distance;
    final normal = Offset(-dir.dy, dir.dx);
    final band = size.shortestSide * 0.2;
    const spacing = 7.0;
    final dot = Paint()..color = AppColors.white.withValues(alpha: 0.16);
    for (var y = 0.0; y <= size.height; y += spacing) {
      final shift = (y / spacing).round().isOdd ? spacing / 2 : 0.0;
      for (var x = shift; x <= size.width; x += spacing) {
        final p = Offset(x, y) - a;
        final d = (p.dx * normal.dx + p.dy * normal.dy).abs();
        if (d < band) canvas.drawCircle(Offset(x, y), spacing * 0.36 * (1 - d / band), dot);
      }
    }

    // O corte: faixa branca larga e um fio dourado.
    void stripe(double from, double to, Color color) {
      final ext = dir * 40;
      final path = Path()
        ..moveTo(a.dx + normal.dx * from - ext.dx, a.dy + normal.dy * from - ext.dy)
        ..lineTo(b.dx + normal.dx * from + ext.dx, b.dy + normal.dy * from + ext.dy)
        ..lineTo(b.dx + normal.dx * to + ext.dx, b.dy + normal.dy * to + ext.dy)
        ..lineTo(a.dx + normal.dx * to - ext.dx, a.dy + normal.dy * to - ext.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    final t = size.shortestSide * 0.014;
    stripe(-t, t, AppColors.white);
    stripe(t * 2.2, t * 3.2, accent);
  }

  @override
  bool shouldRepaint(covariant ArtSplitPainter old) => old.home != home || old.away != away || old.wide != wide;
}

/// Foto do atleta na arte (corta para preencher); sem foto ou se falhar, a
/// silhueta desenhada com as iniciais na cor do time — a arte nunca quebra.
const _diamondInk = Color(0xFF0E1114);

/// "VS" forte: losango escuro inclinado com contorno e brilho no [accent].
class ArtVsDiamond extends StatelessWidget {
  final Color accent;
  final double scale;

  const ArtVsDiamond({super.key, required this.accent, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final box = 64 * scale;
    return SizedBox(
      width: box * 1.45,
      height: box * 1.45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: box,
              height: box,
              decoration: BoxDecoration(
                color: _diamondInk,
                border: Border.all(color: accent, width: 3 * scale),
                boxShadow: [
                  BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 18 * scale),
                  BoxShadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 10 * scale),
                ],
              ),
            ),
          ),
          Text(
            'VS',
            style: ArtFonts.displayStyle(30 * scale, AppColors.white, spacing: 1, height: 1.1).copyWith(
              shadows: [Shadow(color: accent.withValues(alpha: 0.9), blurRadius: 10 * scale)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Faixa de dados DATA | HORÁRIO | LOCAL (rótulo, valor), rótulos no [accent].
class ArtInfoBar extends StatelessWidget {
  final Color accent;
  final double scale;
  final (String, String) date;
  final (String, String) time;
  final (String, String) venue;

  const ArtInfoBar({
    super.key,
    required this.accent,
    required this.date,
    required this.time,
    required this.venue,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    Widget block(String label, String value, {bool big = true}) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: ArtFonts.textStyle(9 * scale, accent, spacing: 2)),
              ),
              SizedBox(height: 2 * scale),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 1,
                  style: big
                      ? ArtFonts.displayStyle(18 * scale, AppColors.white, spacing: 0.6, height: 1.15)
                      : ArtFonts.textStyle(14 * scale, AppColors.white, spacing: 0.8, height: 1.3),
                ),
              ),
            ],
          ),
        );
    Widget divider() => Container(width: 1, height: 30 * scale, color: AppColors.white.withValues(alpha: 0.2));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: _diamondInk.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border(top: BorderSide(color: accent, width: 3 * scale)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: block(date.$1, date.$2)),
          divider(),
          Expanded(flex: 2, child: block(time.$1, time.$2)),
          divider(),
          Expanded(flex: 4, child: block(venue.$1, venue.$2, big: false)),
        ],
      ),
    );
  }
}

/// Foto do atleta sangrada (de borda a borda) que some no fundo [ground]
/// (para baixo ou, com [horizontal], para a direita), com um duotom leve na
/// cor [tint]. Sem foto, a silhueta com as iniciais.
class ArtBleedPhoto extends StatelessWidget {
  final String url;
  final String initials;
  final Color color;
  final Color ground;
  final Color tint;
  final bool horizontal;

  /// Onde o degradê começa (0 a 1).
  final double fadeFrom;

  const ArtBleedPhoto({
    super.key,
    required this.url,
    required this.initials,
    required this.color,
    required this.ground,
    required this.tint,
    this.horizontal = false,
    this.fadeFrom = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    final end = horizontal ? Alignment.centerRight : Alignment.bottomCenter;
    final begin = horizontal ? Alignment.centerLeft : Alignment.topCenter;
    return Stack(
      fit: StackFit.expand,
      children: [
        ArtPlayerPhoto(url: url, initials: initials, color: color),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [tint.withValues(alpha: 0.28), tint.withValues(alpha: 0.05)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              stops: [fadeFrom, 1],
              colors: [ground.withValues(alpha: 0), ground],
            ),
          ),
        ),
      ],
    );
  }
}

class ArtPlayerPhoto extends StatelessWidget {
  final String url;
  final String initials;
  final Color color;

  /// Troca nos testes (imagem em memória).
  static ImageProvider Function(String url) providerFor = _network;

  static ImageProvider _network(String url) => CachedNetworkImageProvider(url);

  /// Foto do aparelho (arquivo local); troca nos testes.
  static ImageProvider Function(String path) localProviderFor = _file;

  static ImageProvider _file(String path) => FileImage(File(path));

  const ArtPlayerPhoto({super.key, required this.url, required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    final fallback = _Silhouette(initials: initials, color: color);
    // Foto do aparelho escolhida só para esta arte (em alta), senão a do atleta.
    final local = ArtPhotoFramingScope.localPhotoOf(context);
    if (url.isEmpty && local == null) return fallback;
    // Enquadramento escolhido pelo usuário (padrão: o centro do alto).
    final framing = ArtPhotoFramingScope.of(context);
    final alignment = Alignment(framing.x, framing.y);
    return ClipRect(
      child: Transform.scale(
        scale: framing.zoom,
        alignment: alignment,
        child: Image(
          image: local != null ? localProviderFor(local) : providerFor(url),
          fit: BoxFit.cover,
          alignment: alignment,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

/// Leva o enquadramento da foto do atleta ([ArtPhotoFraming]) até todas as
/// fotos da arte, sem os modelos precisarem saber dele.
class ArtPhotoFramingScope extends InheritedWidget {
  final ArtPhotoFraming framing;

  /// Foto do aparelho usada só nesta arte (caminho do arquivo; nulo = a do atleta).
  final String? localPhoto;

  const ArtPhotoFramingScope({super.key, required this.framing, this.localPhoto, required super.child});

  static ArtPhotoFraming of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArtPhotoFramingScope>()?.framing ?? ArtPhotoFraming.centered;

  static String? localPhotoOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ArtPhotoFramingScope>()?.localPhoto;

  @override
  bool updateShouldNotify(ArtPhotoFramingScope oldWidget) =>
      oldWidget.framing != framing || oldWidget.localPhoto != localPhoto;
}

class _Silhouette extends StatelessWidget {
  final String initials;
  final Color color;

  const _Silhouette({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = c.biggest.shortestSide.isFinite ? c.biggest.shortestSide : 100.0;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, AppColors.white, 0.25)!, Color.lerp(color, AppColors.black, 0.35)!],
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Icon(Icons.person_rounded, size: size * 0.95, color: AppColors.white.withValues(alpha: 0.22)),
            Align(
              alignment: const Alignment(0, -0.1),
              child: Text(initials, style: ArtFonts.displayStyle(size * 0.26, artOn(color).withValues(alpha: 0.9))),
            ),
          ],
        ),
      );
    });
  }
}
