import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_state.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba de times da home: times da região/temporada selecionadas. Tocar num
/// time abre o elenco. A home recria a aba (key) quando região/ano mudam.
class TeamsTab extends StatelessWidget {
  const TeamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state;
    return BlocProvider<TeamsCubit>(
      create: (_) => TeamsCubit(sl())..watch(region: region.selectedRegion, season: region.selectedSeason),
      child: const _TeamsList(),
    );
  }
}

class _TeamsList extends StatelessWidget {
  const _TeamsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        if (state is LoadingTeamsState && state.teams.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorTeamsState && state.teams.isEmpty) return ArenaEmptyState.error(message: l10n.teamsLoadError);
        if (state.teams.isEmpty) return ArenaEmptyState(message: l10n.teamsEmpty, icon: Icons.shield_outlined);

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          itemCount: state.teams.length,
          itemBuilder: (context, index) => _TeamCard(team: state.teams[index]),
        );
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamDTO team;

  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      padding: const EdgeInsets.all(AppSizes.s12),
      onTap: () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}),
      child: Row(
        children: [
          Container(
            width: AppSizes.s56,
            height: AppSizes.s56,
            padding: const EdgeInsets.all(AppSizes.s6),
            decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            child: ClipOval(
              child: team.imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: team.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.shield_outlined, color: AppColors.textSecondary),
            ),
          ),
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
