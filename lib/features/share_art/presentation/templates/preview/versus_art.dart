import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _ink = Color(0xFF0E1114);

/// Divulgação "Duelo" (pôster de luta): as duas metades chapadas (mandante à
/// esquerda, visitante à direita) com o corte diagonal, o escudo gigante
/// apagado em cada metade, os escudos grandes em quadros brancos com os nomes,
/// o "VS" forte num losango sobre o corte, a competição no cabeçalho e a
/// faixa DATA | HORÁRIO | LOCAL com a marca e o QR.
class VersusArt extends StatelessWidget {
  final PreviewArtArgs args;

  const VersusArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    final home = args.teamColors ? artHalfColor(args.theme.home) : args.colors.base;
    final away = args.teamColors ? artHalfColor(args.theme.away) : args.colors.deep;
    final size = args.size;
    final giant = (args.wide ? size.height : size.width) * 0.95;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: ArtSplitPainter(home: home, away: away, wide: true, accent: args.colors.accent)),
        // Escudos gigantes apagados, sangrando das bordas.
        // (Só com escudo de verdade: o substituto vira letras soltas.)
        if (args.data.home.crestUrl.isNotEmpty)
          Positioned(
            left: -giant * 0.42,
            top: (size.height - giant) / 2,
            child: Opacity(
              opacity: 0.13,
              child: ArtTeamCrest(team: args.data.home, size: giant, color: args.theme.home, plain: true),
            ),
          ),
        if (args.data.away.crestUrl.isNotEmpty)
          Positioned(
            right: -giant * 0.42,
            top: (size.height - giant) / 2,
            child: Opacity(
              opacity: 0.13,
              child: ArtTeamCrest(team: args.data.away, size: giant, color: args.theme.away, plain: true),
            ),
          ),
        // Sombra no alto e no pé (cabeçalho e faixa de dados legíveis).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.black.withValues(alpha: 0.45),
                AppColors.black.withValues(alpha: 0),
                AppColors.black.withValues(alpha: 0),
                AppColors.black.withValues(alpha: 0.6),
              ],
              stops: const [0, 0.3, 0.62, 1],
            ),
          ),
        ),
        const ArtGrain(opacity: 0.06),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

/// Cabeçalho: logo + nome do campeonato numa pílula escura e a tarja do dia.
class _Header extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Header({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    final when = [args.texts.headline, args.texts.time].where((p) => p.isNotEmpty).join('  ·  ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            args.logoUrl.isEmpty ? 18 * scale : 6 * scale,
            6 * scale,
            18 * scale,
            6 * scale,
          ),
          decoration: BoxDecoration(
            color: _ink.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(40 * scale),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (args.logoUrl.isNotEmpty) ...[
                ArtChampionshipLogo(url: args.logoUrl, height: 34 * scale),
                SizedBox(width: 10 * scale),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    args.texts.championship,
                    maxLines: 1,
                    style: ArtFonts.displayStyle(20 * scale, AppColors.white, spacing: 0.8, height: 1.15),
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

/// Lado do confronto: escudo grande num quadro branco, nome e o fio.
class _Side extends StatelessWidget {
  final PreviewArtArgs args;
  final ArtSide side;
  final double scale;

  const _Side({required this.args, required this.side, required this.scale});

  @override
  Widget build(BuildContext context) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104 * scale,
          height: 104 * scale,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22 * scale),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.4),
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: ArtTeamCrest(team: team, size: 84 * scale, color: args.theme.sideColor(side), plain: true),
        ),
        SizedBox(height: 14 * scale),
        SizedBox(
          height: 52 * scale,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 170 * scale),
                child: Text(
                  team.name.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: ArtFonts.displayStyle(24 * scale, AppColors.white, spacing: 0.5, height: 1.05).copyWith(
                    shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.5), offset: Offset(0, 2 * scale))],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(width: 36 * scale, height: 4 * scale, color: args.colors.accent),
      ],
    );
  }
}

/// "VS" forte: losango escuro inclinado com contorno e brilho no destaque.
class _VsBadge extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _VsBadge({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
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
                color: _ink,
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

/// Confronto: os dois lados e o "VS" no meio, sobre o corte.
class _Matchup extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Matchup({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _Side(args: args, side: ArtSide.home, scale: scale)),
        Padding(
          padding: EdgeInsets.only(top: 20 * scale),
          child: _VsBadge(args: args, scale: scale),
        ),
        Expanded(child: _Side(args: args, side: ArtSide.away, scale: scale)),
      ],
    );
  }
}

/// Faixa de dados: DATA | HORÁRIO | LOCAL, rótulos no destaque.
class _InfoBar extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _InfoBar({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final accent = args.colors.accent;
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
        color: _ink.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border(top: BorderSide(color: accent, width: 3 * scale)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: block(t.dateLabel, t.shortDate)),
          divider(),
          Expanded(flex: 2, child: block(t.timeLabel, t.time)),
          divider(),
          Expanded(flex: 4, child: block(t.venueLabel, t.venue, big: false)),
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
      padding: EdgeInsets.fromLTRB(18, args.story ? 56 : 20, 18, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: s)),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: args.size.width - 36, child: _Matchup(args: args, scale: s)),
              ),
            ),
          ),
          _InfoBar(args: args, scale: s),
          SizedBox(height: 12 * s),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _Header(args: args, scale: 0.56)),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: 330, child: _Matchup(args: args, scale: 0.62)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _InfoBar(args: args, scale: 0.6)),
              const SizedBox(width: 12),
              Flexible(child: ArtBranding(color: AppColors.white, scale: 0.62, qrData: args.qr)),
            ],
          ),
        ],
      ),
    );
  }
}
