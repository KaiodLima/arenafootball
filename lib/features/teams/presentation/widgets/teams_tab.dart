import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_state.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_card.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

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
          itemBuilder: (context, index) {
            final team = state.teams[index];
            return TeamCard(
              team: team,
              onTap: () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}),
            );
          },
        );
      },
    );
  }
}
