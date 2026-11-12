import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_parts.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF15181C);
const _muted = Color(0xFF6B7178);

/// Atleta na partida "Agenda" (cartaz): a foto sangrada no alto com as faixas
/// diagonais no pé, o selo da competição no canto, "{NOME} TE ESPERA" e o
/// nome em camadas e, embaixo, o ingresso de verdade — dia/mês, horário ·
/// local, o confronto com os dois nomes e o canhoto com o QR e a contagem.
class AgendaPlayerArt extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const AgendaPlayerArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = args.size;
    final ground = _ground(args);
    final p = args.data.player;
    final tint = args.teamColors ? artHalfColor(args.teamColor) : args.colors.base;
    final photo = ArtBleedPhoto(
      url: p.photoUrl,
      initials: p.initials,
      color: args.teamColor,
      ground: ground,
      tint: tint,
      horizontal: args.wide,
      fadeFrom: 0.5,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: ground),
        if (args.wide)
          Positioned(left: 0, top: 0, bottom: 0, width: size.width * 0.52, child: photo)
        else
          Positioned(left: 0, right: 0, top: 0, height: size.height * (args.story ? 0.68 : 0.66), child: photo),
        CustomPaint(
          painter: _CrossStripes(
            team: tint,
            accent: args.colors.accent,
            wide: args.wide,
            at: args.wide ? 0.46 : (args.story ? 0.5 : 0.46),
          ),
        ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

Color _ground(PlayerMatchArtArgs args) => args.teamColors
    ? Color.lerp(artHalfColor(args.teamColor), AppColors.black, 0.62)!
    : Color.lerp(args.colors.deep, AppColors.black, 0.25)!;

/// Duas faixas finas diagonais (cor do time e destaque) cruzando o pé da
/// foto; na paisagem, na vertical inclinada, no corte da foto.
class _CrossStripes extends CustomPainter {
  final Color team;
  final Color accent;
  final bool wide;
  final double at;

  const _CrossStripes({required this.team, required this.accent, required this.wide, required this.at});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    void band(double offset, double thick, Color color) {
      final path = wide
          ? (Path()
            ..moveTo(w * at + offset, 0)
            ..lineTo(w * at + offset + thick, 0)
            ..lineTo(w * (at - 0.12) + offset + thick, h)
            ..lineTo(w * (at - 0.12) + offset, h)
            ..close())
          : (Path()
            ..moveTo(0, h * at + offset)
            ..lineTo(w, h * (at - 0.1) + offset)
            ..lineTo(w, h * (at - 0.1) + offset + thick)
            ..lineTo(0, h * at + offset + thick)
            ..close());
      canvas.drawPath(path, Paint()..color = color);
    }

    final unit = wide ? w * 0.012 : h * 0.008;
    band(0, unit * 1.4, team.withValues(alpha: 0.9));
    band(unit * 2.4, unit * 0.7, accent);
  }

  @override
  bool shouldRepaint(covariant _CrossStripes old) =>
      old.team != team || old.accent != accent || old.wide != wide || old.at != at;
}

/// Tarja do dia, "{NOME} TE ESPERA" e o nome em camadas.
class _Title extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Title({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final p = args.data.player;
    final first = p.firstName.toUpperCase();
    final shadow = [Shadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 12 * scale)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            PlayerMatchHeadline(args: args, scale: scale * 0.72, angle: 0),
            SizedBox(width: 10 * scale),
            Flexible(
              child: Text(
                t.waiting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(13 * scale, args.colors.accent, spacing: 2.6).copyWith(shadows: shadow),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        if (first.isNotEmpty)
          Text(
            first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(20 * scale, AppColors.white, italic: true, height: 1).copyWith(shadows: shadow),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            p.highlightName.toUpperCase(),
            maxLines: 1,
            style: ArtFonts.displayStyle(58 * scale, AppColors.white, spacing: 0.5, height: 1.05)
                .copyWith(shadows: shadow),
          ),
        ),
        if (t.player.position.isNotEmpty)
          Text(t.player.position,
              style: ArtFonts.textStyle(12 * scale, AppColors.white.withValues(alpha: 0.85), spacing: 2.8)),
      ],
    );
  }
}

/// Recortes em meia-lua em cima e embaixo nas duas linhas de picote.
class _TicketClipper extends CustomClipper<Path> {
  final double left;
  final double right;
  final double radius;

  const _TicketClipper({required this.left, required this.right, required this.radius});

  @override
  Path getClip(Size size) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius * 1.4)));
    final holes = Path();
    for (final x in [left, size.width - right]) {
      holes
        ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: radius))
        ..addOval(Rect.fromCircle(center: Offset(x, size.height), radius: radius));
    }
    return Path.combine(PathOperation.difference, body, holes);
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) => old.left != left || old.right != right || old.radius != radius;
}

class _Perforation extends StatelessWidget {
  final double scale;

  const _Perforation({required this.scale});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 2 * scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < 7; i++)
              Container(width: 2 * scale, height: 5 * scale, color: _ink.withValues(alpha: 0.22)),
          ],
        ),
      );
}

/// O ingresso: dia/mês | horário · local, confronto e competição | canhoto
/// com o QR e a contagem.
class _Ticket extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Ticket({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final m = args.texts.match;
    final accent = args.colors.accent;
    final d = args.data;
    final dateW = 76 * scale;
    final stubW = args.qr != null || m.countdown.isNotEmpty ? 74 * scale : 0.0;
    return ClipPath(
      clipper: _TicketClipper(left: dateW, right: stubW == 0 ? -100 : stubW, radius: 8 * scale),
      child: Container(
        color: AppColors.white,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dia e mês.
              Container(
                width: dateW,
                color: accent,
                padding: EdgeInsets.symmetric(vertical: 10 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (m.day.isNotEmpty) ...[
                      Text(m.day, style: ArtFonts.displayStyle(40 * scale, artOn(accent), height: 1)),
                      Text(m.month, style: ArtFonts.textStyle(14 * scale, artOn(accent), spacing: 2.4)),
                    ] else
                      Icon(Icons.event_rounded, size: 30 * scale, color: artOn(accent)),
                  ],
                ),
              ),
              // Horário · local, confronto com os dois nomes e a competição.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12 * scale, 10 * scale, 10 * scale, 10 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (m.weekday.isNotEmpty)
                        Text(m.weekday, style: ArtFonts.textStyle(10 * scale, _muted, spacing: 2.4)),
                      // Horário grande; o local na linha de baixo (até 2 linhas).
                      if (m.time.isNotEmpty)
                        Text(m.time, maxLines: 1, style: ArtFonts.displayStyle(22 * scale, _ink, height: 1.1)),
                      Text(
                        m.venue,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ArtFonts.textStyle(11 * scale, _ink, spacing: 1, height: 1.1),
                      ),
                      SizedBox(height: 7 * scale),
                      for (final (team, color, name) in [
                        (d.team, args.teamColor, args.texts.team),
                        (d.opponent, args.opponentColor, args.texts.opponent),
                      ])
                        Padding(
                          padding: EdgeInsets.only(bottom: 3 * scale),
                          child: Row(
                            children: [
                              ArtTeamCrest(team: team, size: 22 * scale, color: color),
                              SizedBox(width: 7 * scale),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ArtFonts.displayStyle(12 * scale, _ink, spacing: 0.4, height: 1.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 3 * scale),
                      PlayerMatchCompetition(args: args, scale: scale * 0.82, color: _muted),
                    ],
                  ),
                ),
              ),
              // Canhoto: QR e a contagem.
              if (stubW > 0) ...[
                _Perforation(scale: scale),
                SizedBox(
                  width: stubW - 2 * scale,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 10 * scale),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (args.qr != null) ArtQrCode(data: args.qr!, size: 48 * scale),
                        if (m.countdown.isNotEmpty) ...[
                          SizedBox(height: 7 * scale),
                          Transform.rotate(
                            angle: -0.08,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 2 * scale),
                              decoration: BoxDecoration(
                                border: Border.all(color: accent, width: 1.6 * scale),
                                borderRadius: BorderRadius.circular(4 * scale),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  m.countdown,
                                  maxLines: 1,
                                  style:
                                      ArtFonts.displayStyle(11 * scale, Color.lerp(accent, _ink, 0.35)!, height: 1.2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "VEM PRO JOGO!" e a marca (o QR já está no canhoto).
class _Footer extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const _Footer({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              args.texts.comeWatch,
              maxLines: 1,
              style: ArtFonts.displayStyle(22 * scale, AppColors.white, spacing: 1.2, height: 1.2),
            ),
          ),
        ),
        SizedBox(width: 10 * scale),
        ArtBranding(color: AppColors.white, scale: scale * 0.75),
      ],
    );
  }
}

class _Tall extends StatelessWidget {
  final PlayerMatchArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.72 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, args.story ? 50 : 16, 20, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: PlayerMatchSeal(args: args, scale: s * 0.9)),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: args.size.width - 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Title(args: args, scale: s),
                      SizedBox(height: 14 * s),
                      _Ticket(args: args, scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          _Footer(args: args, scale: s),
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
      padding: EdgeInsets.fromLTRB(args.size.width * 0.44, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: PlayerMatchSeal(args: args, scale: 0.58)),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Title(args: args, scale: 0.7),
                      const SizedBox(height: 10),
                      _Ticket(args: args, scale: 0.72),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _Footer(args: args, scale: 0.6),
        ],
      ),
    );
  }
}
