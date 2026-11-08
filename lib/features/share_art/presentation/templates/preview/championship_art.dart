import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Divulgação "Campeonato": capa oficial do jogo, limpa e elegante. Fundo
/// profundo com feixes de luz e estrelas, a logo do campeonato no alto com o
/// nome espaçado, os dois escudos soltos com um halo na cor de cada time, os
/// nomes, um "VS" fino entre fios e a linha de data · horário · local.
class ChampionshipArt extends StatelessWidget {
  final PreviewArtArgs args;

  const ChampionshipArt(this.args, {super.key});

  /// Fundo: azul-noite neutro na paleta "Times"; senão, as cores da paleta.
  static (Color, Color) background(PreviewArtArgs args) =>
      args.teamColors ? (const Color(0xFF13233F), const Color(0xFF050A14)) : (args.colors.base, args.colors.deep);

  @override
  Widget build(BuildContext context) {
    final (top, bottom) = background(args);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
          ),
        ),
        // Um toque da cor de cada time nos cantos de baixo.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.1, 0.9),
              radius: 0.9,
              colors: [args.theme.home.withValues(alpha: 0.35), args.theme.home.withValues(alpha: 0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.1, 0.9),
              radius: 0.9,
              colors: [args.theme.away.withValues(alpha: 0.35), args.theme.away.withValues(alpha: 0)],
            ),
          ),
        ),
        const CustomPaint(painter: _BeamsPainter()),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Feixes de luz saindo do alto e estrelinhas (semente fixa).
class _BeamsPainter extends CustomPainter {
  const _BeamsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final origin = Offset(w / 2, -h * 0.08);
    final beam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.white.withValues(alpha: 0.09), AppColors.white.withValues(alpha: 0)],
      ).createShader(Offset.zero & size);
    for (final (from, to) in [(-0.55, -0.4), (-0.22, -0.1), (0.08, 0.2), (0.38, 0.52)]) {
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(w / 2 + from * w * 1.6, h)
          ..lineTo(w / 2 + to * w * 1.6, h)
          ..close(),
        beam,
      );
    }
    final random = math.Random(11);
    final star = Paint()..color = AppColors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 60; i++) {
      final p = Offset(random.nextDouble() * w, random.nextDouble() * h * 0.6);
      canvas.drawCircle(p, random.nextDouble() * 0.9 + 0.2, star);
    }
  }

  @override
  bool shouldRepaint(covariant _BeamsPainter oldDelegate) => false;
}

/// Logo no alto (círculo branco com aro fino no destaque; sem logo, o troféu
/// em linha fina), o nome do campeonato espaçado e o fio.
class _Competition extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Competition({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    final size = 92 * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: args.logoUrl.isEmpty ? AppColors.transparent : AppColors.white,
            border: Border.all(color: accent.withValues(alpha: 0.8), width: 1.5 * scale),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 24 * scale)],
          ),
          child: args.logoUrl.isEmpty
              ? Icon(Icons.emoji_events_outlined, color: accent, size: size * 0.55)
              : Padding(
                  padding: EdgeInsets.all(size * 0.16),
                  child: ArtChampionshipLogo(url: args.logoUrl, height: size * 0.68, plain: true),
                ),
        ),
        SizedBox(height: 14 * scale),
        Text(
          args.texts.championship,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: ArtFonts.textStyle(16 * scale, AppColors.white, spacing: 4, height: 1.2),
        ),
        SizedBox(height: 10 * scale),
        Container(width: 44 * scale, height: 2 * scale, color: accent),
      ],
    );
  }
}

/// Escudo solto com o halo na cor do time e o nome embaixo.
class _Team extends StatelessWidget {
  final PreviewArtArgs args;
  final ArtSide side;
  final double scale;

  const _Team({required this.args, required this.side, required this.scale});

  @override
  Widget build(BuildContext context) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    final color = args.theme.sideColor(side);
    final halo = 150 * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: halo,
          height: halo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.65), color.withValues(alpha: 0.18), color.withValues(alpha: 0)],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
              Container(
                width: halo * 0.78,
                height: halo * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.18), width: 1.2 * scale),
                ),
              ),
              ArtTeamCrest(team: team, size: halo * 0.6, color: color, plain: true),
            ],
          ),
        ),
        SizedBox(height: 6 * scale),
        SizedBox(
          height: 50 * scale,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150 * scale),
                child: Text(
                  team.name.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: ArtFonts.displayStyle(22 * scale, AppColors.white, spacing: 0.6, height: 1.08),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Os dois times com o "VS" fino entre dois fios no destaque.
class _Matchup extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Matchup({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    Widget line() => Container(width: 1.5 * scale, height: 30 * scale, color: accent.withValues(alpha: 0.8));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _Team(args: args, side: ArtSide.home, scale: scale)),
        Padding(
          padding: EdgeInsets.only(top: 34 * scale),
          child: Column(
            children: [
              line(),
              SizedBox(height: 8 * scale),
              Text('VS', style: ArtFonts.textStyle(22 * scale, AppColors.white, spacing: 3, height: 1)),
              SizedBox(height: 8 * scale),
              line(),
            ],
          ),
        ),
        Expanded(child: _Team(args: args, side: ArtSide.away, scale: scale)),
      ],
    );
  }
}

/// Linha de dados: 📅 DOM 15/11 · 🕐 18:00 · 📍 local.
class _InfoLine extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _InfoLine({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final accent = args.colors.accent;
    final items = [
      if (t.shortDate.isNotEmpty) (Icons.calendar_month_rounded, t.shortDate),
      if (t.time.isNotEmpty) (Icons.schedule_rounded, t.time),
      (Icons.place_rounded, t.venue),
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: Container(
                  width: 4 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
              ),
            Icon(items[i].$1, size: 15 * scale, color: accent),
            SizedBox(width: 5 * scale),
            Text(items[i].$2, style: ArtFonts.textStyle(14 * scale, AppColors.white, spacing: 1.6)),
          ],
        ],
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
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 64 : 22, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 44,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Competition(args: args, scale: s),
                      SizedBox(height: (args.story ? 46 : 24) * s),
                      _Matchup(args: args, scale: s),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * s),
          _InfoLine(args: args, scale: s),
          SizedBox(height: 14 * s),
          ArtBranding(color: AppColors.white, scale: s, qrData: args.qr),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 10),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(width: 150, child: _Competition(args: args, scale: 0.75)),
                    ),
                  ),
                ),
                Container(width: 1, height: 120, color: AppColors.white.withValues(alpha: 0.15)),
                Expanded(
                  flex: 6,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(width: 250, child: _Matchup(args: args, scale: 0.7)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: _InfoLine(args: args, scale: 0.7))),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: AppColors.white, scale: 0.65, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
