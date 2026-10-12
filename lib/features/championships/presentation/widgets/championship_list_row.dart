import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Linha compacta de campeonato (temporadas anteriores): miniatura, título e
/// temporada.
class ChampionshipListRow extends StatelessWidget {
  final ChampionshipDTO championship;
  final VoidCallback onTap;

  const ChampionshipListRow({super.key, required this.championship, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final thumbRadius = BorderRadius.circular(AppSizes.s12);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: thumbRadius,
                  child: SizedBox.square(
                    dimension: AppSizes.s56,
                    child: championship.imageUrl.isEmpty
                        ? const ColoredBox(
                            color: AppColors.primarySoft,
                            child: Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark),
                          )
                        : CachedNetworkImage(
                            imageUrl: championship.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.primarySoft),
                          ),
                  ),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        championship.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w700, fontSize: AppSizes.s14),
                      ),
                      if (championship.season.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.s2),
                        Text(
                          l10n.championshipSeasonShort(championship.season),
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
