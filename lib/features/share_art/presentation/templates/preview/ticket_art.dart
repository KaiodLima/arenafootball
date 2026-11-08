import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';

const _ink = Color(0xFF14171A);
const _paper = Color(0xFFFBF7EE);
const _muted = Color(0xFF8A8F94);

/// Divulgação "Ingresso": um ingresso oficial sobre a mesa (fundo da
/// paleta). Cabeçalho com a logo e o nome do campeonato em destaque, os dois
/// times grandes (escudo sobre a cor de cada um, nome em Anton, "VS"), a faixa
/// DATA | HORÁRIO | LOCAL, a logo apagada de marca d'água e, depois do
/// picote, o canhoto com o carimbo da contagem e o QR.
class TicketArt extends StatelessWidget {
  final PreviewArtArgs args;

  const TicketArt(this.args, {super.key});

  /// Mesa: grafite no "Times"; senão, as cores da paleta escurecidas.
  static (Color, Color) table(PreviewArtArgs args) => args.teamColors
      ? (const Color(0xFF2B333B), const Color(0xFF151A1F))
      : (Color.lerp(args.colors.base, AppColors.black, 0.35)!, Color.lerp(args.colors.deep, AppColors.black, 0.4)!);

  @override
  Widget build(BuildContext context) {
    final (light, dark) = table(args);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(radius: 1.0, colors: [light, dark]))),
        const ArtGrain(opacity: 0.08),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Cabeçalho: logo grande, "INGRESSO OFICIAL" e o nome do campeonato.
class _Header extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Header({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final band = args.teamColors ? artHalfColor(args.theme.home) : args.colors.base;
    final on = artOn(band);
    return Container(
      padding: EdgeInsets.fromLTRB(14 * scale, 12 * scale, 14 * scale, 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [band, Color.lerp(band, AppColors.black, 0.3)!]),
        border: Border(bottom: BorderSide(color: args.colors.accent, width: 3 * scale)),
      ),
      child: Row(
        children: [
          if (args.logoUrl.isNotEmpty) ...[
            ArtChampionshipLogo(url: args.logoUrl, height: 44 * scale),
            SizedBox(width: 12 * scale),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  args.texts.ticketLabel,
                  maxLines: 1,
                  style: ArtFonts.textStyle(9 * scale, args.colors.accent, spacing: 3),
                ),
                SizedBox(height: 6 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    args.texts.championship,
                    maxLines: 1,
                    style: ArtFonts.displayStyle(22 * scale, on, spacing: 0.6, height: 1.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Time em destaque: escudo sobre um círculo na cor do time e o nome.
class _Team extends StatelessWidget {
  final PreviewArtArgs args;
  final ArtSide side;
  final double scale;

  const _Team({required this.args, required this.side, required this.scale});

  @override
  Widget build(BuildContext context) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    final color = args.theme.sideColor(side);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82 * scale,
          height: 82 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.08)]),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2 * scale),
          ),
          child: ArtTeamCrest(team: team, size: 60 * scale, color: color, plain: true),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          height: 40 * scale,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 130 * scale),
                child: Text(
                  team.name.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: ArtFonts.displayStyle(18 * scale, _ink, spacing: 0.3, height: 1.05),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Corpo: os times com o "VS", a faixa de campos e a logo de marca d'água.
class _Body extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  /// Carimbo no canto (paisagem; no alto ele fica no canhoto).
  final bool withStamp;

  const _Body({required this.args, required this.scale, this.withStamp = false});

  Widget _field(String label, String value, {bool big = true}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, maxLines: 1, style: ArtFonts.textStyle(8 * scale, _muted, spacing: 1.6)),
          SizedBox(height: 2 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              style: big
                  ? ArtFonts.displayStyle(17 * scale, _ink, height: 1.1)
                  : ArtFonts.textStyle(13 * scale, _ink, height: 1.1),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final stamp = withStamp ? _stampText(args) : '';
    Widget divider() => Container(
          width: 1,
          height: 28 * scale,
          margin: EdgeInsets.symmetric(horizontal: 10 * scale),
          color: _ink.withValues(alpha: 0.15),
        );
    return Stack(
      children: [
        if (args.logoUrl.isNotEmpty)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.07,
                child: ArtChampionshipLogo(url: args.logoUrl, height: 130 * scale, plain: true),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(14 * scale, 16 * scale, 14 * scale, 12 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Team(args: args, side: ArtSide.home, scale: scale)),
                  Padding(
                    padding: EdgeInsets.only(top: 26 * scale),
                    child: Container(
                      width: 34 * scale,
                      height: 34 * scale,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: _ink, shape: BoxShape.circle),
                      child: Text('VS', style: ArtFonts.displayStyle(13 * scale, args.colors.accent, height: 1.1)),
                    ),
                  ),
                  Expanded(child: _Team(args: args, side: ArtSide.away, scale: scale)),
                ],
              ),
              SizedBox(height: 12 * scale),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: _ink.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6 * scale),
                  border: Border.all(color: _ink.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _field(t.dateLabel, t.fullDate)),
                    divider(),
                    Expanded(flex: 2, child: _field(t.timeLabel, t.time)),
                    divider(),
                    Expanded(flex: 3, child: _field(t.venueLabel, t.venue, big: false)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (stamp.isNotEmpty)
          Positioned(top: 8 * scale, right: 8 * scale, child: _Stamp(text: stamp, scale: scale * 0.8)),
      ],
    );
  }
}

/// Texto do carimbo: a contagem ("FALTAM 2 DIAS") ou o título do dia.
String _stampText(PreviewArtArgs args) => args.texts.countdown.isNotEmpty ? args.texts.countdown : args.texts.headline;

/// Carimbo vermelho inclinado.
class _Stamp extends StatelessWidget {
  final String text;
  final double scale;

  const _Stamp({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.danger.withValues(alpha: 0.85);
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2 * scale),
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        child: Text(text, style: ArtFonts.displayStyle(14 * scale, color, spacing: 0.5)),
      ),
    );
  }
}

/// Picote: tracejado com os recortes redondos nas pontas (na cor da mesa).
class _Perforation extends StatelessWidget {
  final bool vertical;
  final double scale;
  final Color notch;

  const _Perforation({required this.vertical, required this.scale, required this.notch});

  @override
  Widget build(BuildContext context) {
    final thickness = 14 * scale;
    return SizedBox(
      // O outro lado vem do pai (Row/Column esticados).
      width: vertical ? thickness : null,
      height: vertical ? null : thickness,
      child: CustomPaint(painter: _PerforationPainter(vertical: vertical, notch: notch)),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  final bool vertical;
  final Color notch;

  _PerforationPainter({required this.vertical, required this.notch});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _paper);
    final dash = Paint()
      ..color = _ink.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;
    final hole = Paint()..color = notch;
    if (vertical) {
      final x = size.width / 2;
      for (var y = size.width; y < size.height - size.width; y += 6) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 3), dash);
      }
      canvas.drawCircle(Offset(x, 0), size.width / 2, hole);
      canvas.drawCircle(Offset(x, size.height), size.width / 2, hole);
    } else {
      final y = size.height / 2;
      for (var x = size.height; x < size.width - size.height; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), dash);
      }
      canvas.drawCircle(Offset(0, y), size.height / 2, hole);
      canvas.drawCircle(Offset(size.width, y), size.height / 2, hole);
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter old) => old.vertical != vertical || old.notch != notch;
}

/// Canhoto: logo do Arena, "Nº 0001", o carimbo (no alto) e o QR.
class _Stub extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;
  final bool vertical;

  const _Stub({required this.args, required this.scale, required this.vertical});

  @override
  Widget build(BuildContext context) {
    final number = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Image.asset(AppImages.logo, height: 18 * scale, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        SizedBox(height: 4 * scale),
        Text('Nº 0001', style: ArtFonts.displayStyle(14 * scale, _ink, spacing: 1)),
      ],
    );
    final qr = args.qr;
    final stamp = vertical ? '' : _stampText(args);
    final children = [
      vertical ? number : Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: number)),
      if (stamp.isNotEmpty) Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: _Stamp(text: stamp, scale: scale))),
      if (qr != null) ArtQrCode(data: qr, size: 50 * scale),
    ];
    return Container(
      color: _paper,
      padding: EdgeInsets.all(10 * scale),
      child: vertical
          ? Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children)
          : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
    );
  }
}

/// O ingresso inteiro, levemente girado, com sombra e cantos arredondados.
class _Ticket extends StatelessWidget {
  final Widget child;
  final double scale;

  const _Ticket({required this.child, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.03,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scale),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.5),
              blurRadius: 18 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(10 * scale), child: child),
      ),
    );
  }
}

class _Tall extends StatelessWidget {
  final PreviewArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    final notch = TicketArt.table(args).$2;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, args.story ? 56 : 18, 20, args.story ? 40 : 14),
      child: Column(
        children: [
          Text(
            args.texts.headline,
            maxLines: 1,
            style: ArtFonts.displayStyle((args.square ? 30 : 38) * s, AppColors.white, spacing: 1),
          ),
          SizedBox(height: 4 * s),
          Container(width: 54 * s, height: 4 * s, color: args.colors.accent),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 52,
                  child: _Ticket(
                    scale: s,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(args: args, scale: s),
                        ColoredBox(color: _paper, child: _Body(args: args, scale: s)),
                        _Perforation(vertical: false, scale: s, notch: notch),
                        _Stub(args: args, scale: s, vertical: false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          ArtBranding(color: AppColors.white, scale: s * 0.9),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PreviewArtArgs args;

  const _Wide(this.args);

  @override
  Widget build(BuildContext context) {
    const s = 0.7;
    final notch = TicketArt.table(args).$2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 360,
            child: _Ticket(
              scale: s,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(args: args, scale: s),
                          Expanded(
                            child: ColoredBox(color: _paper, child: _Body(args: args, scale: s, withStamp: true)),
                          ),
                        ],
                      ),
                    ),
                    _Perforation(vertical: true, scale: s, notch: notch),
                    SizedBox(width: 80, child: _Stub(args: args, scale: s, vertical: true)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
