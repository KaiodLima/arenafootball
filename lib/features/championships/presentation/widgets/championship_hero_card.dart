import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Fundo do hero do campeonato: o banner com degradê escuro de baixo para
/// cima (o texto branco fica legível); sem banner, o fundo verde do app.
class ChampionshipHeroBackdrop extends StatelessWidget {
  final String imageUrl;

  const ChampionshipHeroBackdrop({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const ArenaHeroBackground(watermarkFactor: 0.9, child: SizedBox.expand());
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(color: AppColors.primaryDark),
          errorWidget: (_, __, ___) => const ArenaHeroBackground(child: SizedBox.expand()),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.4, 0.75, 1],
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.1),
                AppColors.primaryDark.withValues(alpha: 0.55),
                AppColors.primaryDark.withValues(alpha: 0.9),
                AppColors.primaryDark,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip translúcido sobre o hero escuro (ícone + texto branco).
class ChampionshipInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ChampionshipInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.s20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.s14, color: AppColors.white),
          const SizedBox(width: AppSizes.s4),
          Text(label, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}

/// Chips do campeonato: região, nº de times e regulamento (se houver).
List<Widget> championshipInfoChips(AppLocalizations l10n, ChampionshipDTO championship) => [
      if (championship.region.isNotEmpty) ChampionshipInfoChip(icon: Icons.place_rounded, label: championship.region),
      if (championship.teams.isNotEmpty)
        ChampionshipInfoChip(
          icon: Icons.groups_rounded,
          label: l10n.championshipsManageTeamsCount(championship.teams.length),
        ),
      if (championship.rulesUrl.isNotEmpty)
        ChampionshipInfoChip(icon: Icons.picture_as_pdf_rounded, label: l10n.championshipTabRules),
    ];

/// Selo do topo: "EM ANDAMENTO · 2023" na temporada corrente; senão, só a temporada.
class ChampionshipSeasonBadge extends StatelessWidget {
  final String season;

  const ChampionshipSeasonBadge({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = season.isEmpty || season == SeasonCollection.currentSeason;
    final label = current
        ? [l10n.championshipsCurrentBadge, if (season.isNotEmpty) season].join(' · ')
        : l10n.championshipSeasonShort(season);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
      decoration: BoxDecoration(
        color: current ? AppColors.primary : AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.s6),
      ),
      child: Text(
        label,
        style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12, letterSpacing: 0.6),
      ),
    );
  }
}

/// Card de destaque da aba CAMPEONATOS: banner em tela cheia com degradê,
/// selo da temporada, título grande e chips.
class ChampionshipHeroCard extends StatelessWidget {
  final ChampionshipDTO championship;
  final VoidCallback onTap;

  const ChampionshipHeroCard({super.key, required this.championship, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    return Material(
      color: AppColors.primaryDark,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: AppColors.primaryDark.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ChampionshipHeroBackdrop(imageUrl: championship.imageUrl),
              Padding(
                padding: const EdgeInsets.all(AppSizes.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChampionshipSeasonBadge(season: championship.season),
                    const Spacer(),
                    Text(
                      championship.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(color: AppColors.white).copyWith(fontSize: AppSizes.s24),
                    ),
                    const SizedBox(height: AppSizes.s10),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: AppSizes.s6,
                            runSpacing: AppSizes.s6,
                            children: championshipInfoChips(l10n, championship),
                          ),
                        ),
                        Container(
                          width: AppSizes.s36,
                          height: AppSizes.s36,
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
