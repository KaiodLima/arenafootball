import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Card de um grupo: selo com o nome, os times (escudo + nome; o time do
/// usuário em destaque) e o link para a classificação.
class GroupCard extends StatelessWidget {
  final GroupDTO group;
  final String? Function(String teamName) crestOf;

  /// Time do coração? Recebe (id, nome) do time no grupo.
  final bool Function(String id, String name)? isFavorite;
  final VoidCallback onTap;

  const GroupCard({super.key, required this.group, required this.crestOf, required this.onTap, this.isFavorite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s12, AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppSizes.s20),
                ),
                child: Text(
                  l10n.championshipsGroupTitle(group.description),
                  style: AppTypography.label(color: AppColors.white),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          // Grupos com menos de 4 times guardam as vagas restantes vazias.
          for (var i = 0; i < group.teams.length; i++)
            if (group.teams[i].trim().isNotEmpty)
              _TeamRow(
                name: group.teams[i],
                crest: crestOf(group.teams[i]),
                isFavorite: isFavorite?.call(group.teamIdAt(i), group.teams[i]) ?? false,
                yourTeamLabel: l10n.standingsYourTeam,
              ),
          const SizedBox(height: AppSizes.s4),
          Text(l10n.groupsSeeStandings, style: AppTypography.label()),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String? crest;
  final bool isFavorite;
  final String yourTeamLabel;

  const _TeamRow({required this.name, required this.crest, required this.isFavorite, required this.yourTeamLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
      decoration: BoxDecoration(
        color: isFavorite ? AppColors.primarySoft : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      child: Row(
        children: [
          TeamCrest(imageUrl: crest),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body().copyWith(fontWeight: isFavorite ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          if (isFavorite)
            Tooltip(
              message: yourTeamLabel,
              child: const Icon(Icons.star_rounded, color: AppColors.gold, size: AppSizes.s20),
            ),
        ],
      ),
    );
  }
}
