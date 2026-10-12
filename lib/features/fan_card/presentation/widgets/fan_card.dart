import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/team_colors_background.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Carteirinha de torcedor: cartão no padrão de cantos recortados nas cores
/// do time do coração (sem time ou sem cores, nas cores do app), com a foto,
/// o nome, o time, a região, os papéis (jogador/dono) e o número.
class FanCard extends StatelessWidget {
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
  });

  /// Cores do time, ou o verde e branco do app.
  static TeamPalette paletteFor(TeamDTO? team) =>
      TeamPalette.fromHex(team?.primaryColor ?? '', team?.secondaryColor ?? '') ??
      TeamPalette.fromHex(colorToHex(AppColors.primaryStrong), colorToHex(AppColors.white))!;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = paletteFor(team);
    final text = palette.onBackground;
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return AspectRatio(
      aspectRatio: 1.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: TeamColorsBackground(
            palette: palette,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final photoSize = constraints.maxHeight * 0.42;
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // No alto à direita (o canto esquerdo é colorido).
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                l10n.fanCardLabel,
                                maxLines: 1,
                                style: AppTypography.label(color: text).copyWith(
                                  fontSize: AppSizes.s12,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.s8),
                          Image.asset('lib/assets/images/ic_logo.png', height: AppSizes.s20),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _Photo(url: photoUrl, name: name, size: photoSize, ring: palette.ring),
                            const SizedBox(width: AppSizes.s14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.title(color: text).copyWith(fontSize: AppSizes.s20),
                                  ),
                                  const SizedBox(height: AppSizes.s6),
                                  Row(
                                    children: [
                                      if (favoriteTeam.isNotEmpty) ...[
                                        TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s24),
                                        const SizedBox(width: AppSizes.s6),
                                      ],
                                      Flexible(
                                        child: Text(
                                          favoriteTeam.isEmpty ? l10n.fanCardNoTeam : l10n.fanCardFanOf(favoriteTeam),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.label(color: text).copyWith(fontSize: AppSizes.s14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (region.isNotEmpty) ...[
                                    const SizedBox(height: AppSizes.s2),
                                    Text(
                                      region,
                                      style: AppTypography.subtitle(color: text.withValues(alpha: 0.75))
                                          .copyWith(fontSize: AppSizes.s12),
                                    ),
                                  ],
                                  if (ownedTeam != null || playerTeam != null) ...[
                                    const SizedBox(height: AppSizes.s6),
                                    Wrap(
                                      spacing: AppSizes.s4,
                                      runSpacing: AppSizes.s4,
                                      children: [
                                        if (ownedTeam != null)
                                          _RolePill(
                                            icon: Icons.shield_rounded,
                                            label: l10n.drawerOwnerOf(ownedTeam!),
                                            palette: palette,
                                          ),
                                        if (playerTeam != null)
                                          _RolePill(
                                            icon: Icons.sports_soccer_rounded,
                                            label: l10n.drawerPlayerOf(playerTeam!),
                                            palette: palette,
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Embaixo à esquerda (o canto direito é colorido).
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          [
                            if (memberSince != null) l10n.fanCardSince('$memberSince'),
                            l10n.fanCardNumber(number),
                          ].join('   ·   '),
                          maxLines: 1,
                          style: AppTypography.label(color: text).copyWith(
                            fontSize: AppSizes.s12,
                            letterSpacing: 0.8,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto da conta em círculo, com anel na cor do time; sem foto, as iniciais.
class _Photo extends StatelessWidget {
  final String url;
  final String name;
  final double size;
  final Color ring;

  const _Photo({required this.url, required this.name, required this.size, required this.ring});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: url.isEmpty
              ? ColoredBox(
                  color: AppColors.background,
                  child: Center(
                    child: Text(
                      _initials,
                      style: AppTypography.title(color: AppColors.textSecondary).copyWith(fontSize: size * 0.32),
                    ),
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
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final TeamPalette palette;

  const _RolePill({required this.icon, required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(AppSizes.s20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s12, color: palette.onAccent),
          const SizedBox(width: AppSizes.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: palette.onAccent).copyWith(fontSize: AppSizes.s12),
            ),
          ),
        ],
      ),
    );
  }
}
