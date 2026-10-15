import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_crest_hero.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/team_colors_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

/// Topo do elenco: escudo (Hero vindo do card do time), nome, região e
/// temporada. Com as cores do time, o fundo é o padrão de cantos recortados
/// ([TeamColorsBackground]); sem cores, o verde do app. A borda arredondada
/// da folha de conteúdo é desenhada aqui, porque a barra fixa do
/// CustomScrollView fica por cima dos slivers seguintes.
class TeamHeader extends StatelessWidget {
  final TeamDTO team;
  final String season;

  const TeamHeader({super.key, required this.team, required this.season});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = TeamPalette.fromHex(team.primaryColor, team.secondaryColor);
    final foreground = palette?.onBackground ?? AppColors.white;

    final content = Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.s24 + AppSizes.s8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: teamCrestHeroTag(team.id),
                    child: Container(
                      width: AppSizes.s100,
                      height: AppSizes.s100,
                      padding: const EdgeInsets.all(AppSizes.s10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        // Anel na cor do time.
                        border: palette == null ? null : Border.all(color: palette.ring, width: 3),
                      ),
                      child: ClipOval(
                        child: team.imageUrl.isNotEmpty
                            ? CachedNetworkImage(imageUrl: team.imageUrl, fit: BoxFit.cover)
                            : const Icon(Icons.shield_outlined, color: AppColors.textSecondary, size: AppSizes.s40),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s24),
                    child: Text(
                      team.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(color: foreground).copyWith(fontSize: AppSizes.s24),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  Wrap(
                    spacing: AppSizes.s8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (team.region.isNotEmpty)
                        _HeaderChip(icon: Icons.place_outlined, label: team.region, palette: palette),
                      _HeaderChip(
                        icon: Icons.calendar_today_rounded,
                        label: l10n.homeSeasonChip(season),
                        palette: palette,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          height: AppSizes.s24 + 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
            ),
          ),
        ),
      ],
    );

    return palette == null
        ? ArenaHeroBackground(watermarkFactor: 0.7, child: content)
        // A folha arredondada do elenco cobre a faixa de baixo.
        : TeamColorsBackground(palette: palette, bottomInset: AppSizes.s24, child: content);
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Cores do time (nulo = verde do app).
  final TeamPalette? palette;

  const _HeaderChip({required this.icon, required this.label, this.palette});

  @override
  Widget build(BuildContext context) {
    final foreground = palette?.onAccent ?? AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        // Com cores do time, uma pílula sólida na cor principal (como no fundo).
        color: palette?.accent ?? AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.s20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: foreground),
          const SizedBox(width: AppSizes.s4),
          Text(label, style: AppTypography.label(color: foreground).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}
