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

  /// Números da lista escolhida (faixa embaixo do nome); nulos = sem faixa.
  final ({int players, int goals, int assists})? stats;

  const TeamHeader({super.key, required this.team, required this.season, this.stats});

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
                      width: AppSizes.s80 + AppSizes.s8,
                      height: AppSizes.s80 + AppSizes.s8,
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
                  const SizedBox(height: AppSizes.s4),
                  // Região e temporada numa linha discreta.
                  Text(
                    [if (team.region.isNotEmpty) team.region, l10n.homeSeasonChip(season)].join('  ·  '),
                    style: AppTypography.subtitle(color: foreground.withValues(alpha: 0.8)).copyWith(fontSize: AppSizes.s12),
                  ),
                  if (stats != null) ...[
                    const SizedBox(height: AppSizes.s14),
                    _StatsStrip(stats: stats!, foreground: foreground),
                  ],
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

/// Faixa translúcida com os números da lista (atletas · gols · assist.).
class _StatsStrip extends StatelessWidget {
  final ({int players, int goals, int assists}) stats;
  final Color foreground;

  const _StatsStrip({required this.stats, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget item(int value, String label) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value', style: AppTypography.display(color: foreground).copyWith(fontSize: AppSizes.s20)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subtitle(color: foreground.withValues(alpha: 0.8)).copyWith(fontSize: AppSizes.s12),
              ),
            ],
          ),
        );
    Widget divider() => Container(width: 1, height: AppSizes.s28, color: foreground.withValues(alpha: 0.2));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.s32),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          item(stats.players, l10n.playersSummaryPlayers),
          divider(),
          item(stats.goals, l10n.playersSummaryGoals),
          divider(),
          item(stats.assists, l10n.playersSummaryAssists),
        ],
      ),
    );
  }
}
