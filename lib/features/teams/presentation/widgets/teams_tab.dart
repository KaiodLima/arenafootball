import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_state.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
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
        if (state is ErrorTeamsState && state.teams.isEmpty) return _Message(text: l10n.teamsLoadError);
        if (state.teams.isEmpty) return _Message(text: l10n.teamsEmpty);

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: state.teams.length,
          itemBuilder: (context, index) => _TeamCard(team: state.teams[index]),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s20),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamDTO team;

  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryTranslucent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s48)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.s16),
        onTap: () => Navigator.pushNamed(context, AppRoutes.teamPlayersPage, arguments: {'team': team}),
        leading: CircleAvatar(
          maxRadius: AppSizes.s30,
          backgroundColor: AppColors.grey,
          backgroundImage: team.imageUrl.isNotEmpty ? NetworkImage(team.imageUrl) : null,
        ),
        title: Text(
          team.name,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: AppSizes.s20),
        ),
        subtitle: Text(team.description),
        trailing: const Icon(Icons.more_vert, size: AppSizes.s30, color: AppColors.white),
      ),
    );
  }
}
