import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/preview/preview_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

const _paper = Color(0xFFF3EEE4);
const _ink = Color(0xFF14171A);
const _muted = Color(0xFF8A8F94);

/// Divulgação "Agenda" (clara, editorial): papel creme, cabeçalho "ARENA" com
/// a competição e fio duplo, título grande, a folha de calendário (dia da
/// semana, dia, mês e horário) ao lado dos dois times empilhados, e o local
/// com o QR no rodapé.
class CalendarArt extends StatelessWidget {
  final PreviewArtArgs args;

  const CalendarArt(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: _paper),
        Positioned(
          right: -args.size.width * 0.25,
          bottom: -args.size.width * 0.2,
          child: Icon(Icons.sports_soccer_outlined, size: args.size.width * 0.8, color: _ink.withValues(alpha: 0.04)),
        ),
        const ArtGrain(opacity: 0.05),
        if (args.wide) _Wide(args) else _Tall(args),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  final PreviewArtArgs args;
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

/// Folha de calendário: faixa na cor da casa com o dia da semana, o dia
/// enorme, o mês e o horário numa faixa escura com dourado.
class _CalendarSheet extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _CalendarSheet({required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final t = args.texts;
    final band = artHalfColor(args.theme.home);
    return Container(
      width: 112 * scale,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: _ink, width: 2 * scale),
        boxShadow: [BoxShadow(color: _ink.withValues(alpha: 0.18), offset: Offset(5 * scale, 5 * scale))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: band,
            padding: EdgeInsets.symmetric(vertical: 4 * scale),
            child: Text(
              t.weekday.isEmpty ? '—' : t.weekday,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: ArtFonts.textStyle(11 * scale, artOn(band), spacing: 1.6),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            t.day.isEmpty ? '?' : t.day,
            textAlign: TextAlign.center,
            style: ArtFonts.displayStyle(58 * scale, _ink, height: 1.1),
          ),
          Text(
            t.month,
            textAlign: TextAlign.center,
            style: ArtFonts.textStyle(13 * scale, _muted, spacing: 3),
          ),
          SizedBox(height: 6 * scale),
          Container(
            color: _ink,
            padding: EdgeInsets.symmetric(vertical: 4 * scale),
            child: Text(
              t.time.isEmpty ? '--:--' : t.time,
              textAlign: TextAlign.center,
              style: ArtFonts.displayStyle(20 * scale, AppColors.gold, spacing: 1, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Os dois times empilhados: barra na cor, escudo e nome, com o "×" no meio.
class _Teams extends StatelessWidget {
  final PreviewArtArgs args;
  final double scale;

  const _Teams({required this.args, required this.scale});

  Widget _row(ArtSide side) {
    final team = side == ArtSide.home ? args.data.home : args.data.away;
    final color = args.theme.sideColor(side);
    return Row(
      children: [
        Container(width: 4 * scale, height: 44 * scale, color: color),
        SizedBox(width: 8 * scale),
        ArtTeamCrest(team: team, size: 44 * scale, color: color),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text(
            team.name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(17 * scale, _ink, height: 1),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(ArtSide.home),
        Padding(
          padding: EdgeInsets.fromLTRB(18 * scale, 4 * scale, 0, 4 * scale),
          child: Text('×', style: ArtFonts.textStyle(18 * scale, _muted)),
        ),
        _row(ArtSide.away),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final PreviewArtArgs args;
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
            Icon(Icons.place_rounded, size: 12 * scale, color: _ink),
            SizedBox(width: 4 * scale),
            Expanded(
              child: Text(
                args.texts.venue,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.textStyle(10 * scale, _ink, spacing: 1.2),
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

/// Título da Agenda: o dia da semana já está na folha, então ele vira
/// "PRÓXIMO JOGO" (fica "É HOJE!" / "AMANHÃ").
String _headline(PreviewArtArgs args) =>
    args.texts.headline == args.texts.weekday ? args.texts.nextMatch : args.texts.headline;

class _Tall extends StatelessWidget {
  final PreviewArtArgs args;

  const _Tall(this.args);

  @override
  Widget build(BuildContext context) {
    final s = args.story ? 1.12 : (args.square ? 0.8 : 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(22, args.story ? 54 : 20, 22, args.story ? 40 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(args: args, scale: s),
          SizedBox(height: 14 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_headline(args), maxLines: 1, style: ArtFonts.displayStyle(52 * s, _ink, spacing: 0.5)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(width: 54 * s, height: 4 * s, margin: EdgeInsets.only(top: 4 * s), color: AppColors.gold),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: args.size.width - 44,
                  child: Row(
                    children: [
                      _CalendarSheet(args: args, scale: s),
                      SizedBox(width: 18 * s),
                      Expanded(child: _Teams(args: args, scale: s)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _Footer(args: args, scale: s),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Masthead(args: args, scale: s),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 364,
                  child: Row(
                    children: [
                      _CalendarSheet(args: args, scale: 0.62),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_headline(args), maxLines: 1, style: ArtFonts.displayStyle(28, _ink)),
                            Container(
                                width: 36, height: 3, margin: const EdgeInsets.only(bottom: 8), color: AppColors.gold),
                            _Teams(args: args, scale: 0.6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _Footer(args: args, scale: s),
        ],
      ),
    );
  }
}
