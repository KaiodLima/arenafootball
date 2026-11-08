import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF14171A);
const _muted = Color(0xFFB4BAC0);

/// Modelo "Cores" (pôster colorido): duas metades chapadas nas cores
/// dos times (casa em cima/à esquerda, visitante embaixo/à direita) com um
/// corte diagonal branco e dourado, "FIM DE JOGO" branco itálico gigante,
/// a placa branca inclinada do placar cruzando o corte, os gols em pílulas
/// brancas, a faixa de ingresso e a marca.
class VibrantArt extends StatelessWidget {
  final ResultArtArgs args;

  const VibrantArt(this.args, {super.key});

  /// Fundo da metade: a cor do time; muito clara, um pouco mais escura
  /// para o branco do corte e da placa não sumirem.
  static Color half(Color color) => artHalfColor(color);

  @override
  Widget build(BuildContext context) {
    final home = half(args.theme.home);
    final away = half(args.theme.away);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: ArtSplitPainter(home: home, away: away, wide: args.wide)),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _PosterWide(args, home: home, away: away) else _PosterTall(args, home: home, away: away),
      ],
    );
  }
}

/// Competição (com a logo) e o título branco itálico gigante.
class _Headline extends StatelessWidget {
  final ResultArtArgs args;
  final Color on;
  final double scale;
  final double title;

  const _Headline({required this.args, required this.on, required this.scale, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (args.logoUrl.isNotEmpty) ...[
              ArtChampionshipLogo(url: args.logoUrl, height: 24 * scale),
              SizedBox(width: 8 * scale),
            ],
            Flexible(
              child: Text(
                args.texts.championship,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(11 * scale, on.withValues(alpha: 0.92), spacing: 2.4),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * scale),
        Transform(
          transform: Matrix4.skewX(-0.18),
          alignment: Alignment.bottomLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              args.texts.status,
              maxLines: 1,
              style: ArtFonts.displayStyle(title, on, spacing: 0.5).copyWith(
                shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.25), offset: Offset(0, title * 0.05))],
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * scale),
        Container(width: 64 * scale, height: 5 * scale, color: AppColors.gold),
      ],
    );
  }
}

/// Placa branca inclinada com os escudos, os nomes e o placar.
class _ScorePlate extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;

  const _ScorePlate({required this.args, required this.scale});

  Color _digit(ArtSide side) {
    final winner = args.data.winner;
    return winner == null || winner == side ? _ink : _muted;
  }

  Widget _team(ArtSide side) {
    final data = args.data;
    final team = side == ArtSide.home ? data.home : data.away;
    final winner = data.winner == side;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtTeamCrest(team: team, size: 58 * scale, color: args.theme.sideColor(side)),
        SizedBox(height: 6 * scale),
        Text(
          team.name.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(12 * scale, _ink, italic: true, height: 1),
        ),
        SizedBox(height: 4 * scale),
        Container(width: 26 * scale, height: 3 * scale, color: winner ? AppColors.gold : AppColors.transparent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final tag = switch (data.status) {
      ArtMatchStatus.live => (AppColors.danger, AppColors.white),
      ArtMatchStatus.halfTime => (AppColors.gold, _ink),
      _ => null,
    };
    final digit = 62 * scale;
    final plate = Container(
      padding: EdgeInsets.fromLTRB(12 * scale, 14 * scale, 12 * scale, 10 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.28), offset: Offset(6 * scale, 6 * scale))],
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _team(ArtSide.home)),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${data.homeGoals}', style: ArtFonts.displayStyle(digit, _digit(ArtSide.home))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: digit * 0.14),
                        child: Text('×', style: ArtFonts.textStyle(digit * 0.42, _muted)),
                      ),
                      Text('${data.awayGoals}', style: ArtFonts.displayStyle(digit, _digit(ArtSide.away))),
                    ],
                  ),
                ),
                if (args.texts.halfTime != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2 * scale),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(args.texts.halfTime!, style: ArtFonts.textStyle(9 * scale, _muted, spacing: 1.4)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(flex: 3, child: _team(ArtSide.away)),
        ],
      ),
    );
    return Transform.rotate(
      angle: -0.05,
      child: tag == null
          ? plate
          : Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                plate,
                Positioned(
                  top: -9 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
                    color: tag.$1,
                    child: Text(args.texts.status, style: ArtFonts.textStyle(10 * scale, tag.$2, spacing: 2)),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Gols em pílulas brancas: minuto na cor do time + autor.
class _Scorers extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;
  final int maxLines;

  const _Scorers({required this.args, required this.scale, required this.maxLines});

  Widget _pill(ArtGoal goal, Color color, bool end) {
    final minute = goal.minute == null
        ? null
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 2 * scale),
            color: color,
            child: Text("${goal.minute}'", style: ArtFonts.textStyle(10 * scale, artOn(color))),
          );
    final name = Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
        child: Text(
          (goal.scorer.isEmpty ? args.texts.noScorer : goal.scorer).toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(10.5 * scale, _ink, spacing: 0.4),
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.2), offset: Offset(2 * scale, 2 * scale))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: end ? [name, if (minute != null) minute] : [if (minute != null) minute, name],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    if (data.goals.isEmpty) return const SizedBox.shrink();
    Widget side(ArtSide s, bool end) {
      final goals = data.goalsOf(s);
      final shown = goals.take(maxLines).toList();
      return Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          for (final g in shown) _pill(g, args.theme.sideColor(s), end),
          if (goals.length > shown.length)
            Text('+${goals.length - shown.length}', style: ArtFonts.textStyle(10 * scale, AppColors.white)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: side(ArtSide.home, false)),
        SizedBox(width: 10 * scale),
        Expanded(child: side(ArtSide.away, true)),
      ],
    );
  }
}

class _PosterTall extends StatelessWidget {
  final ResultArtArgs args;
  final Color home;
  final Color away;

  const _PosterTall(this.args, {required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    final inner = args.size.width - 44;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 54 : 20, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Headline(args: args, on: artOn(home), scale: s, title: (args.square ? 50 : 64) * s),
          // Placa + gols: encolhem juntos se faltar altura (nunca estoura).
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: inner,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10 * s),
                      _ScorePlate(args: args, scale: args.square ? s : s * 1.12),
                      SizedBox(height: 18 * s),
                      _Scorers(args: args, scale: s, maxLines: args.story ? 5 : (args.square ? 2 : 3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (args.texts.info.isNotEmpty) ...[
            ArtTicketStrip(left: args.texts.info, right: '', background: AppColors.white, foreground: _ink, scale: s),
            SizedBox(height: 10 * s),
          ],
          ArtBranding(color: artOn(away), scale: s, qrData: args.qr),
        ],
      ),
    );
  }
}

class _PosterWide extends StatelessWidget {
  final ResultArtArgs args;
  final Color home;
  final Color away;

  const _PosterWide(this.args, {required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 200,
              child: _Headline(args: args, on: artOn(home), scale: 0.75, title: 30),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 330,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      _ScorePlate(args: args, scale: 0.62),
                      const SizedBox(height: 10),
                      _Scorers(args: args, scale: 0.62, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (args.texts.info.isNotEmpty)
                Expanded(
                  child: ArtTicketStrip(
                    left: args.texts.info,
                    right: '',
                    background: AppColors.white,
                    foreground: _ink,
                    scale: 0.7,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: artOn(away), scale: 0.7, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
