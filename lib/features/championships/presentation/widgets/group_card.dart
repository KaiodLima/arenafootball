import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Card de um grupo: nome no topo e os times numa caixa verde-escura.
class GroupCard extends StatelessWidget {
  final GroupDTO group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const radius = BorderRadius.all(Radius.circular(AppSizes.s20));

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: const BoxDecoration(color: AppColors.primary, borderRadius: radius),
          padding: const EdgeInsets.all(AppSizes.s8),
          alignment: Alignment.topCenter,
          child: AutoSizeText(
            l10n.championshipsGroupTitle(group.description),
            maxLines: 1,
            style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s24),
          ),
        ),
        Container(
          height: AppSizes.s200,
          decoration: const BoxDecoration(color: AppColors.primaryStrong, borderRadius: radius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final team in group.teams)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.s4),
                  child: AutoSizeText(
                    team,
                    maxLines: 1,
                    style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s22),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
