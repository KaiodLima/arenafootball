import 'package:flutter/material.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/player_match/player_match_art.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_graphics.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Peças comuns das artes do atleta na partida.

/// Confronto: escudo do time "VS" escudo do adversário, com os nomes.
class PlayerMatchup extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final Color ink;

  const PlayerMatchup({super.key, required this.args, required this.scale, this.ink = AppColors.white});

  @override
  Widget build(BuildContext context) {
    final d = args.data;
    Widget side(String name, Widget crest) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              crest,
              SizedBox(height: 5 * scale),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.displayStyle(13 * scale, ink, spacing: 0.4, height: 1.1),
              ),
            ],
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        side(args.texts.team, ArtTeamCrest(team: d.team, size: 46 * scale, color: args.teamColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          child: Text('VS', style: ArtFonts.displayStyle(20 * scale, args.colors.accent, spacing: 0.5)),
        ),
        side(args.texts.opponent, ArtTeamCrest(team: d.opponent, size: 46 * scale, color: args.opponentColor)),
      ],
    );
  }
}

/// Competição (logo + nome) numa linha.
class PlayerMatchCompetition extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final Color color;

  const PlayerMatchCompetition({super.key, required this.args, required this.scale, required this.color});

  @override
  Widget build(BuildContext context) {
    final logo = args.data.match.championshipLogoUrl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logo.isNotEmpty) ...[
          ArtChampionshipLogo(url: logo, height: 20 * scale),
          SizedBox(width: 7 * scale),
        ],
        Flexible(
          child: Text(
            args.texts.match.championship,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ArtFonts.textStyle(11 * scale, color, spacing: 2),
          ),
        ),
      ],
    );
  }
}

/// Tarja do título pela data ("É HOJE!", "SÁBADO"...).
class PlayerMatchHeadline extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final double angle;

  const PlayerMatchHeadline({super.key, required this.args, required this.scale, this.angle = -0.05});

  @override
  Widget build(BuildContext context) {
    final accent = args.colors.accent;
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 2 * scale),
        decoration: BoxDecoration(
          color: accent,
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), offset: Offset(3 * scale, 3 * scale))],
        ),
        child: Text(
          args.texts.match.headline,
          maxLines: 1,
          style: ArtFonts.displayStyle(26 * scale, artOn(accent), spacing: 1, height: 1.2),
        ),
      ),
    );
  }
}

/// Selo da competição: a logo num círculo branco (ou só o escudo do time) e o
/// nome da competição com "DIA DE JOGO" embaixo.
class PlayerMatchSeal extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final Color color;

  const PlayerMatchSeal({super.key, required this.args, required this.scale, this.color = AppColors.white});

  @override
  Widget build(BuildContext context) {
    final logo = args.data.match.championshipLogoUrl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40 * scale,
          height: 40 * scale,
          padding: EdgeInsets.all(5 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.35), blurRadius: 8 * scale)],
          ),
          child: logo.isNotEmpty
              ? ArtChampionshipLogo(url: logo, height: 30 * scale)
              : ArtTeamCrest(team: args.data.team, size: 30 * scale, color: args.teamColor, plain: true),
        ),
        SizedBox(width: 8 * scale),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                args.texts.match.championship,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtFonts.displayStyle(13 * scale, color, spacing: 0.6, height: 1.15),
              ),
              Text(
                args.texts.matchday,
                maxLines: 1,
                style: ArtFonts.textStyle(10 * scale, args.colors.accent, spacing: 2.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Barra de placar escura: escudo · VS · escudo | horário grande e o local.
class PlayerScoreBar extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const PlayerScoreBar({super.key, required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final d = args.data;
    final m = args.texts.match;
    final accent = args.colors.accent;
    final big = m.time.isNotEmpty ? m.time : m.headline;
    final small = [if (m.time.isNotEmpty) m.shortDate, m.venue].where((v) => v.isNotEmpty).join('  ·  ');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xF0101316),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border(top: BorderSide(color: accent, width: 3 * scale)),
      ),
      child: Row(
        children: [
          ArtTeamCrest(team: d.team, size: 36 * scale, color: args.teamColor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            child: Text('VS', style: ArtFonts.displayStyle(15 * scale, accent)),
          ),
          ArtTeamCrest(team: d.opponent, size: 36 * scale, color: args.opponentColor),
          Container(
            width: 1,
            height: 34 * scale,
            margin: EdgeInsets.symmetric(horizontal: 12 * scale),
            color: AppColors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child:
                      Text(big, maxLines: 1, style: ArtFonts.displayStyle(28 * scale, AppColors.white, height: 1.05)),
                ),
                if (small.isNotEmpty)
                  Text(
                    small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.textStyle(10 * scale, AppColors.white.withValues(alpha: 0.7), spacing: 1.4),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Escudo grande num quadro branco com sombra (destaque do time).
class PlayerCrestTile extends StatelessWidget {
  final ArtTeam team;
  final Color color;
  final double size;

  const PlayerCrestTile({super.key, required this.team, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.4), blurRadius: size * 0.18, offset: Offset(0, size * 0.07)),
        ],
      ),
      child: ArtTeamCrest(team: team, size: size * 0.8, color: color, plain: true),
    );
  }
}

/// Confronto em destaque: os dois escudos grandes em quadros brancos com os
/// nomes em Anton e o "VS" no losango entre eles (time do atleta à esquerda).
class PlayerBigMatchup extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;
  final Color ink;

  const PlayerBigMatchup({super.key, required this.args, required this.scale, this.ink = AppColors.white});

  @override
  Widget build(BuildContext context) {
    final d = args.data;
    Widget side(ArtTeam team, Color color, String name) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerCrestTile(team: team, color: color, size: 84 * scale),
              SizedBox(height: 8 * scale),
              SizedBox(
                height: 42 * scale,
                child: Center(
                  child: Text(
                    name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: ArtFonts.displayStyle(18 * scale, ink, spacing: 0.5, height: 1.05).copyWith(
                      shadows: [Shadow(color: AppColors.black.withValues(alpha: 0.45), offset: Offset(0, 2 * scale))],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side(d.team, args.teamColor, args.texts.team),
        Padding(
          padding: EdgeInsets.only(top: 14 * scale),
          child: ArtVsDiamond(accent: args.colors.accent, scale: scale * 0.82),
        ),
        side(d.opponent, args.opponentColor, args.texts.opponent),
      ],
    );
  }
}

/// Faixa DATA | HORÁRIO | LOCAL da partida.
class PlayerMatchInfoBar extends StatelessWidget {
  final PlayerMatchArtArgs args;
  final double scale;

  const PlayerMatchInfoBar({super.key, required this.args, required this.scale});

  @override
  Widget build(BuildContext context) {
    final m = args.texts.match;
    return ArtInfoBar(
      accent: args.colors.accent,
      scale: scale,
      date: (m.dateLabel, m.shortDate),
      time: (m.timeLabel, m.time),
      venue: (m.venueLabel, m.venue),
    );
  }
}
