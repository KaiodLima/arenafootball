import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/features/fan_card/presentation/widgets/fan_card_chip.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

// O cartão é uma superfície de tamanho proporcional (como as artes): as
// medidas são da largura de referência [_designWidth], multiplicadas por `s`.
const double _designWidth = 340;
const String _display = 'Anton';
const String _condensed = 'BarlowCondensed';

TextStyle _displayStyle(double size, Color color) =>
    TextStyle(fontFamily: _display, fontSize: size, color: color, height: 1.05, letterSpacing: 0.4);

TextStyle _condensedStyle(double size, Color color, {double spacing = 0, FontWeight weight = FontWeight.w700}) =>
    TextStyle(
      fontFamily: _condensed,
      fontSize: size,
      color: color,
      letterSpacing: spacing,
      fontWeight: weight,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Moldura comum da frente e do verso: proporção de cartão de crédito, cantos
/// arredondados, sombra e o brilho que corre com a inclinação ([sheen], -1 a 1).
class _CardShell extends StatelessWidget {
  final double sheen;
  final Widget Function(BuildContext context, double s) builder;

  const _CardShell({required this.sheen, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: FanCard.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / _designWidth;
          final radius = BorderRadius.circular(16 * s);
          final center = 0.5 + sheen * 0.35;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.28), blurRadius: 22 * s, offset: Offset(0, 10 * s)),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  builder(context, s),
                  // Reflexo diagonal que acompanha a inclinação.
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.transparent,
                            AppColors.white.withValues(alpha: 0.16),
                            AppColors.transparent,
                          ],
                          stops: [
                            (center - 0.18).clamp(0.0, 1.0),
                            center.clamp(0.0, 1.0),
                            (center + 0.18).clamp(0.0, 1.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Filete claro na borda, como um cartão plastificado.
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.18), width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fundo da carteirinha nas cores do time: degradê, faixas diagonais,
/// guilhoché e o escudo gigante apagado (sem time, a bola na rede da marca).
class _CardBackground extends StatelessWidget {
  final TeamPalette palette;
  final String crestUrl;
  final double s;
  final bool back;

  const _CardBackground({required this.palette, required this.crestUrl, required this.s, this.back = false});

  @override
  Widget build(BuildContext context) {
    final ink = palette.onAccent;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: back
                  ? [palette.accentDark, Color.lerp(palette.accentDark, AppColors.black, 0.25)!]
                  : [palette.accent, palette.accentDark],
            ),
          ),
        ),
        FanCardGuilloche(color: ink.withValues(alpha: 0.07)),
        if (!back) FanCardBand(color: palette.background),
        Positioned(
          right: -48 * s,
          top: back ? 30 * s : -16 * s,
          child: Opacity(
            opacity: back ? 0.08 : 0.14,
            child: crestUrl.isEmpty
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                    child: Image.asset(AppImages.ballInNet, height: 200 * s),
                  )
                : CachedNetworkImage(
                    imageUrl: crestUrl,
                    width: 210 * s,
                    height: 210 * s,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Carteirinha de torcedor (frente): cartão de sócio nas cores do time do
/// coração (sem time ou sem cores, nas cores do app) com chip, foto, nome,
/// time, papéis (jogador/dono), número, ano, região, nível e medalhas.
class FanCard extends StatelessWidget {
  /// Proporção de cartão de crédito.
  static const double aspectRatio = 1.586;

  final String name;
  final String photoUrl;

  /// Nome do time do coração ('' = sem time).
  final String favoriteTeam;

  /// Dados do time (escudo e cores); nulo enquanto carrega ou se não achou.
  final TeamDTO? team;
  final String region;
  final int? memberSince;
  final String number;
  final String? playerTeam;
  final String? ownedTeam;

  /// Nível do torcedor ("ULTRA") e as melhores medalhas (até 3), das
  /// conquistas; nulo/vazio = sem a vitrine.
  final String? level;
  final List<({AchievementTier tier, String icon})> medals;

  /// Posição do reflexo (-1 a 1), pela inclinação do cartão.
  final double sheen;

  const FanCard({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.favoriteTeam,
    required this.team,
    required this.region,
    required this.memberSince,
    required this.number,
    this.playerTeam,
    this.ownedTeam,
    this.level,
    this.medals = const [],
    this.sheen = 0,
  });

  /// Cores do time, ou o verde e branco do app.
  static TeamPalette paletteFor(TeamDTO? team) =>
      TeamPalette.orDefault(team?.primaryColor ?? '', team?.secondaryColor ?? '');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = paletteFor(team);
    final ink = palette.onAccent;
    final soft = ink.withValues(alpha: 0.78);
    final crest = favoriteTeam.isEmpty ? '' : (team?.imageUrl ?? '');

    return _CardShell(
      sheen: sheen,
      builder: (context, s) => Stack(
        fit: StackFit.expand,
        children: [
          _CardBackground(palette: palette, crestUrl: crest, s: s),
          Padding(
            padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 12 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Marca e o selo do nível.
                Row(
                  children: [
                    // A marca em silhueta na cor do texto (o logo verde some no fundo do time).
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                      child: Image.asset(AppImages.logoAlt, height: 18 * s),
                    ),
                    SizedBox(width: 6 * s),
                    Expanded(
                      child: Text(
                        l10n.fanCardMember,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _condensedStyle(11.5 * s, ink, spacing: 2.2 * s),
                      ),
                    ),
                    if (level != null && medals.isNotEmpty) _LevelPill(label: level!, s: s),
                  ],
                ),
                SizedBox(height: 10 * s),
                Expanded(
                  child: Row(
                    children: [
                      _Photo(url: photoUrl, name: name, size: 78 * s, s: s),
                      SizedBox(width: 12 * s),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _displayStyle(21 * s, ink).copyWith(
                                shadows: [
                                  Shadow(color: AppColors.black.withValues(alpha: 0.25), offset: Offset(0, 1.5 * s)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4 * s),
                            Row(
                              children: [
                                if (crest.isNotEmpty) ...[
                                  _MiniCrest(url: crest, size: 16 * s),
                                  SizedBox(width: 5 * s),
                                ],
                                Flexible(
                                  child: Text(
                                    (favoriteTeam.isEmpty ? l10n.fanCardNoTeam : l10n.fanCardFanOf(favoriteTeam))
                                        .toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _condensedStyle(12 * s, soft, spacing: 0.8 * s),
                                  ),
                                ),
                              ],
                            ),
                            if (ownedTeam != null || playerTeam != null) ...[
                              SizedBox(height: 6 * s),
                              Wrap(
                                spacing: 4 * s,
                                runSpacing: 4 * s,
                                children: [
                                  if (ownedTeam != null)
                                    _RolePill(
                                      icon: Icons.shield_rounded,
                                      label: l10n.drawerOwnerOf(ownedTeam!),
                                      s: s,
                                    ),
                                  if (playerTeam != null)
                                    _RolePill(
                                      icon: Icons.sports_soccer_rounded,
                                      label: l10n.drawerPlayerOf(playerTeam!),
                                      s: s,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FanCardChip(width: 34 * s),
                          SizedBox(height: 6 * s),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Icon(Icons.wifi_rounded, color: soft, size: 18 * s),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * s),
                // Número, ano e região; à direita, as melhores medalhas.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              number.replaceAll('·', '  '),
                              maxLines: 1,
                              style: _condensedStyle(19 * s, ink, spacing: 3 * s).copyWith(
                                shadows: [
                                  Shadow(color: AppColors.black.withValues(alpha: 0.3), offset: Offset(0, 1 * s)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              [
                                if (memberSince != null) l10n.fanCardSince('$memberSince'),
                                if (region.isNotEmpty) region,
                              ].join('  ·  ').toUpperCase(),
                              maxLines: 1,
                              style: _condensedStyle(10 * s, soft, spacing: 1.2 * s),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final medal in medals.take(3))
                      Padding(
                        padding: EdgeInsets.only(left: 2 * s),
                        child: MedalBadge(tier: medal.tier, icon: medal.icon, unlocked: true, size: 28 * s),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Verso da carteirinha: tarja magnética, assinatura, QR do app, nível e a
/// validade na temporada.
class FanCardBack extends StatelessWidget {
  final String name;
  final String number;
  final TeamDTO? team;
  final String favoriteTeam;
  final String season;
  final String qrData;

  /// "ULTRA · 240 XP · 7 conquistas"; vazio = sem a linha.
  final String stats;
  final double sheen;

  const FanCardBack({
    super.key,
    required this.name,
    required this.number,
    required this.team,
    required this.favoriteTeam,
    required this.season,
    required this.qrData,
    this.stats = '',
    this.sheen = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = FanCard.paletteFor(team);
    final ink = palette.onAccent;
    final soft = ink.withValues(alpha: 0.78);
    final crest = favoriteTeam.isEmpty ? '' : (team?.imageUrl ?? '');

    return _CardShell(
      sheen: sheen,
      builder: (context, s) => Stack(
        fit: StackFit.expand,
        children: [
          _CardBackground(palette: palette, crestUrl: crest, s: s, back: true),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16 * s),
              // Tarja magnética.
              Container(
                height: 32 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.black.withValues(alpha: 0.92), AppColors.black.withValues(alpha: 0.78)],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 12 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Faixa de assinatura com o nome "assinado".
                            Container(
                              height: 30 * s,
                              padding: EdgeInsets.symmetric(horizontal: 8 * s),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(4 * s),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Alkatra',
                                    fontSize: 17 * s,
                                    color: AppColors.teamNavy,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 3 * s),
                            Text(l10n.fanCardSignature.toUpperCase(),
                                style: _condensedStyle(8 * s, soft, spacing: 1.4 * s)),
                            const Spacer(),
                            if (stats.isNotEmpty)
                              Text(
                                stats.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _condensedStyle(11 * s, ink, spacing: 0.8 * s),
                              ),
                            SizedBox(height: 4 * s),
                            Text(
                              l10n.fanCardValidSeason(season).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _condensedStyle(9.5 * s, soft, spacing: 1.2 * s),
                            ),
                            Text(
                              l10n.fanCardNumber(number),
                              style: _condensedStyle(9.5 * s, soft, spacing: 1.2 * s),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12 * s),
                      Column(
                        children: [
                          ArtQrCode(data: qrData, size: 70 * s),
                          SizedBox(height: 5 * s),
                          SizedBox(
                            width: 78 * s,
                            child: Text(
                              l10n.fanCardBackCta,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: _condensedStyle(9 * s, ink, spacing: 0.3 * s),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final String label;
  final double s;

  const _LevelPill({required this.label, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2.5 * s),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.medalGoldLight, AppColors.gold, AppColors.medalGoldDark]),
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.25), blurRadius: 4 * s)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 11 * s, color: AppColors.black),
          SizedBox(width: 3 * s),
          Text(label, style: _condensedStyle(10.5 * s, AppColors.black, spacing: 1.2 * s, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Escudo pequeno num círculo branco.
class _MiniCrest extends StatelessWidget {
  final String url;
  final double size;

  const _MiniCrest({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
      child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain, errorWidget: (_, __, ___) => const SizedBox()),
    );
  }
}

/// Foto da conta num quadrado arredondado com aro branco; sem foto, as iniciais.
class _Photo extends StatelessWidget {
  final String url;
  final String name;
  final double size;
  final double s;

  const _Photo({required this.url, required this.name, required this.size, required this.s});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14 * s);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(2.5 * s),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.3), blurRadius: 10 * s, offset: Offset(0, 4 * s))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.5 * s),
        child: url.isEmpty
            ? ColoredBox(
                color: AppColors.background,
                child: Center(
                  child: Text(_initials, style: _displayStyle(size * 0.36, AppColors.textSecondary)),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.background),
              ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double s;

  const _RolePill({required this.icon, required this.label, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10 * s, color: AppColors.white),
          SizedBox(width: 3 * s),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _condensedStyle(10.5 * s, AppColors.white, spacing: 0.3 * s),
            ),
          ),
        ],
      ),
    );
  }
}
