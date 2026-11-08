import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/result/result_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

/// Papel creme e tinta das artes editoriais.
const _paper = Color(0xFFF3EEE4);
const _ink = Color(0xFF14171A);
const _muted = Color(0xFF8A8F94);

/// Modelo "Editorial" (capa de revista esportiva): papel creme com grão,
/// cabeçalho com fio, o placar como tabela (escudo · NOME ······ número
/// gigante, o vencedor em tinta cheia e o perdedor apagado, com a barra na
/// cor do time), fio dourado e o "box score" dos gols (minuto | autor | time).
class EditorialArt extends StatelessWidget {
  final ResultArtArgs args;

  const EditorialArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _paper),
        // Bola gigante em linha fina, discreta, no canto.
        Positioned(
          right: -args.size.width * 0.25,
          top: -args.size.width * 0.2,
          child: Icon(Icons.sports_soccer_outlined, size: args.size.width * 0.85, color: _ink.withValues(alpha: 0.04)),
        ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _EditorialWide(args) else _EditorialTall(args),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;

  const _Masthead({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('ARENA', style: ArtFonts.displayStyle(16 * scale, _ink, spacing: 1)),
            SizedBox(width: 6 * scale),
            if (args.logoUrl.isNotEmpty) ...[
              ArtChampionshipLogo(url: args.logoUrl, height: 20 * scale),
              SizedBox(width: 6 * scale),
            ],
            Expanded(
              child: Text(
                args.texts.championship,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(10 * scale, _muted, spacing: 1.8),
              ),
            ),
            Text(args.texts.status, style: ArtFonts.textStyle(10 * scale, _ink, spacing: 1.8)),
          ],
        ),
        SizedBox(height: 5 * scale),
        Container(height: 2.5 * scale, color: _ink),
        SizedBox(height: 2 * scale),
        Container(height: 0.8 * scale, color: _ink),
      ],
    );
  }
}

/// Linha do placar: barra da cor do time, escudo, nome e o número gigante.
class _ScoreRow extends StatelessWidget {
  final ResultArtArgs args;
  final ArtSide side;
  final double scale;

  const _ScoreRow({required this.args, required this.side, required this.scale});

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    final team = side == ArtSide.home ? data.home : data.away;
    final goals = side == ArtSide.home ? data.homeGoals : data.awayGoals;
    final lost = data.winner != null && data.winner != side;
    final ink = lost ? _muted : _ink;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 5 * scale, color: args.theme.sideColor(side)),
          SizedBox(width: 10 * scale),
          Center(child: ArtTeamCrest(team: team, size: 44 * scale, color: args.theme.sideColor(side))),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  team.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ArtFonts.textStyle(19 * scale, ink, height: 1),
                ),
                if (data.winner == side)
                  Padding(
                    padding: EdgeInsets.only(top: 3 * scale),
                    child: Container(width: 22 * scale, height: 3 * scale, color: AppColors.gold),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Text('$goals', style: ArtFonts.displayStyle(78 * scale, ink, height: 1)),
        ],
      ),
    );
  }
}

/// "Box score" dos gols: minuto | autor | time (sigla), em ordem de minuto.
class _BoxScore extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;
  final int maxRows;

  const _BoxScore({required this.args, required this.scale, required this.maxRows});

  @override
  Widget build(BuildContext context) {
    final data = args.data;
    if (data.goals.isEmpty) return const SizedBox.shrink();
    final shown = data.goals.take(maxRows).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(args.texts.goals, style: ArtFonts.textStyle(9.5 * scale, _muted, spacing: 2.2)),
        SizedBox(height: 3 * scale),
        for (final g in shown)
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.5 * scale),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _ink.withValues(alpha: 0.12)))),
            child: Row(
              children: [
                SizedBox(
                  width: 28 * scale,
                  child: Text(
                    g.minute == null ? '–' : "${g.minute}'",
                    style: ArtFonts.textStyle(11 * scale, _ink),
                  ),
                ),
                Expanded(
                  child: Text(
                    (g.scorer.isEmpty ? args.texts.noScorer : g.scorer).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(11 * scale, _ink, weight: FontWeight.w600),
                  ),
                ),
                Container(width: 8 * scale, height: 8 * scale, color: args.theme.sideColor(g.side)),
                SizedBox(width: 5 * scale),
                Text(
                  (g.side == ArtSide.home ? data.home : data.away).initials,
                  style: ArtFonts.textStyle(10 * scale, _muted),
                ),
              ],
            ),
          ),
        if (data.goals.length > shown.length)
          Padding(
            padding: EdgeInsets.only(top: 2 * scale),
            child: Text('+${data.goals.length - shown.length}', style: ArtFonts.textStyle(10 * scale, _muted)),
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final ResultArtArgs args;
  final double scale;

  const _Footer({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 0.8 * scale, color: _ink),
        SizedBox(height: 6 * scale),
        Row(
          children: [
            Expanded(
              child: Text(
                args.texts.info,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(9 * scale, _ink, weight: FontWeight.w600, spacing: 0.8),
              ),
            ),
            SizedBox(width: 8 * scale),
            if (args.qr != null) ArtQrCode(data: args.qr!, size: 34 * scale),
          ],
        ),
        SizedBox(height: 4 * scale),
        Text(args.texts.callToAction, style: ArtFonts.textStyle(8.5 * scale, _muted, weight: FontWeight.w600)),
      ],
    );
  }
}

class _EditorialTall extends StatelessWidget {
  final ResultArtArgs args;

  const _EditorialTall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.12 : (args.square ? 0.8 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, args.story ? 56 : 22, 24, args.story ? 44 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(args: args, scale: s),
          const Spacer(),
          _ScoreRow(args: args, side: ArtSide.home, scale: s),
          SizedBox(height: 10 * s),
          _ScoreRow(args: args, side: ArtSide.away, scale: s),
          if (args.texts.halfTime != null)
            Padding(
              padding: EdgeInsets.only(top: 6 * s),
              child: Text(args.texts.halfTime!, style: ArtFonts.textStyle(9.5 * s, _muted, spacing: 1.4)),
            ),
          SizedBox(height: 14 * s),
          Container(height: 2 * s, color: AppColors.gold),
          SizedBox(height: 10 * s),
          _BoxScore(args: args, scale: s, maxRows: args.square ? 2 : (args.story ? 9 : 5)),
          const Spacer(),
          _Footer(args: args, scale: s),
        ],
      ),
    );
  }
}

class _EditorialWide extends StatelessWidget {
  final ResultArtArgs args;

  const _EditorialWide(this.args);

  @override
  Widget build(BuildContext context) {
    const s = 0.7;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        children: [
          _Masthead(args: args, scale: s),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ScoreRow(args: args, side: ArtSide.home, scale: s),
                      const SizedBox(height: 6),
                      _ScoreRow(args: args, side: ArtSide.away, scale: s),
                    ],
                  ),
                ),
                Container(width: 2, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.gold),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BoxScore(args: args, scale: 0.75, maxRows: 3),
                      const Spacer(),
                      ArtBranding(color: _ink, scale: 0.7, qrData: args.qr, alignment: MainAxisAlignment.end),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (args.texts.info.isNotEmpty)
            Text(
              args.texts.info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ArtFonts.textStyle(8, _ink, weight: FontWeight.w600, spacing: 0.6),
            ),
        ],
      ),
    );
  }
}
