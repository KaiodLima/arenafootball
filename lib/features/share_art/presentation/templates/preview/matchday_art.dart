import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF14171A);

/// Divulgação "Dia de jogo": metades nas cores dos times com o corte diagonal,
/// "É HOJE!" branco itálico gigante, a placa branca inclinada com os escudos
/// e o "VS", o horário enorme num placar escuro e o local na faixa de ingresso.
class MatchdayArt extends StatelessWidget {
  final PreviewArtArgs args;

  const MatchdayArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final home = artHalfColor(args.theme.home);
    final away = artHalfColor(args.theme.away);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: ArtSplitPainter(home: home, away: away, wide: args.wide)),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args, home: home, away: away) else _Tall(args, home: home, away: away),
      ],
    );
  }
}

/// Competição (com a logo), o título gigante e o fio dourado.
class _Headline extends StatelessWidget {
  final PreviewArtArgs args;
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
              args.texts.headline,
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

/// Placa branca inclinada: os dois escudos com os nomes e o "VS" no meio.
class _VersusPlate extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _VersusPlate({required this.args, required this.scale});

  Widget _team(ArtSide side) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtTeamCrest(team: team, size: 62 * scale, color: args.theme.sideColor(side)),
        SizedBox(height: 6 * scale),
        Text(
          team.name.toUpperCase(),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(12.5 * scale, _ink, italic: true, height: 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = 50 * scale;
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: EdgeInsets.fromLTRB(12 * scale, 14 * scale, 12 * scale, 12 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4 * scale),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.28), offset: Offset(6 * scale, 6 * scale))],
        ),
        child: Row(
          children: [
            Expanded(child: _team(ArtSide.home)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * scale),
              child: Container(
                width: badge,
                height: badge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2.5 * scale),
                ),
                child: Text('VS', style: ArtFonts.displayStyle(20 * scale, AppColors.gold, spacing: 0.5)),
              ),
            ),
            Expanded(child: _team(ArtSide.away)),
          ],
        ),
      ),
    );
  }
}

/// Horário enorme e a data curta num "placar" escuro.
class _KickoffBoard extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _KickoffBoard({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    if (t.time.isEmpty && t.shortDate.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(6 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (t.time.isNotEmpty)
            Text(t.time, style: ArtFonts.displayStyle(46 * scale, AppColors.white, spacing: 1, height: 1.1)),
          if (t.time.isNotEmpty && t.shortDate.isNotEmpty)
            Container(
              width: 2 * scale,
              height: 34 * scale,
              margin: EdgeInsets.symmetric(horizontal: 12 * scale),
              color: AppColors.gold,
            ),
          if (t.shortDate.isNotEmpty)
            Text(t.shortDate, style: ArtFonts.textStyle(15 * scale, AppColors.gold, spacing: 2)),
        ],
      ),
    );
  }
}

class _Tall extends StatelessWidget {
  final PreviewArtArgs args;
  final Color home;
  final Color away;

  const _Tall(this.args, {required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.15 : (args.square ? 0.8 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 54 : 20, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Headline(args: args, on: artOn(home), scale: s, title: (args.square ? 50 : 64) * s),
          // Placa + horário: encolhem juntos se faltar altura (nunca estoura).
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 44,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10 * s),
                      _VersusPlate(args: args, scale: args.square ? s : s * 1.12),
                      SizedBox(height: 22 * s),
                      FittedBox(fit: BoxFit.scaleDown, child: _KickoffBoard(args: args, scale: s)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ArtTicketStrip(left: args.texts.venue, right: '', background: AppColors.white, foreground: _ink, scale: s),
          SizedBox(height: 10 * s),
          ArtBranding(color: artOn(away), scale: s, qrData: args.qr),
        ],
      ),
    );
  }
}

class _Wide extends StatelessWidget {
  final PreviewArtArgs args;
  final Color home;
  final Color away;

  const _Wide(this.args, {required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 200, child: _Headline(args: args, on: artOn(home), scale: 0.75, title: 30)),
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
                      _VersusPlate(args: args, scale: 0.62),
                      const SizedBox(height: 10),
                      FittedBox(fit: BoxFit.scaleDown, child: _KickoffBoard(args: args, scale: 0.62)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ArtTicketStrip(
                  left: args.texts.venue,
                  right: '',
                  background: AppColors.white,
                  foreground: _ink,
                  scale: 0.7,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: artOn(away), scale: 0.7, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
