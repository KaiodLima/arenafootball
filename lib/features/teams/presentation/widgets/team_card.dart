import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_crest_hero.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de um time na aba Times: escudo, nome, descrição e a seta. Com
/// [crestFile] (prévia do cadastro), o escudo vem do arquivo local e o card
/// não tem Hero nem toque.
class TeamCard extends StatelessWidget {
  final TeamDTO team;
  final VoidCallback? onTap;
  final File? crestFile;

  const TeamCard({super.key, required this.team, this.onTap, this.crestFile});

  @override
  Widget build(BuildContext context) {
    final Widget crest;
    if (crestFile != null) {
      crest = Image.file(crestFile!, fit: BoxFit.cover);
    } else if (team.imageUrl.isNotEmpty) {
      crest = CachedNetworkImage(imageUrl: team.imageUrl, fit: BoxFit.cover);
    } else {
      crest = const Icon(Icons.shield_outlined, color: AppColors.textSecondary);
    }
    final circle = Container(
      width: AppSizes.s56,
      height: AppSizes.s56,
      padding: const EdgeInsets.all(AppSizes.s6),
      decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: ClipOval(child: crest),
    );

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      padding: const EdgeInsets.all(AppSizes.s12),
      onTap: onTap,
      child: Row(
        children: [
          if (crestFile == null) Hero(tag: teamCrestHeroTag(team.id), child: circle) else circle,
          const SizedBox(width: AppSizes.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                ),
                if (team.description.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(team.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.subtitle()),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
