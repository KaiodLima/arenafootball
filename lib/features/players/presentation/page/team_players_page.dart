import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_details_dialog.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Elenco de um time na temporada selecionada. Tocar num jogador abre os
/// detalhes (o admin edita nome, foto, gols e assistências por lá).
class TeamPlayersPage extends StatefulWidget {
  final TeamDTO team;

  const TeamPlayersPage({super.key, required this.team});

  @override
  State<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  @override
  void initState() {
    super.initState();
    final season = BlocProvider.of<RegionCubit>(context).state.selectedSeason;
    BlocProvider.of<TeamPlayersCubit>(context).watch(teamName: widget.team.name, season: season);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        title: Text(widget.team.name),
      ),
      body: BlocConsumer<TeamPlayersCubit, TeamPlayersState>(
        listener: (context, state) {
          if (state is ErrorTeamPlayersState && state.players.isNotEmpty) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state is LoadingTeamPlayersState && state.players.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorTeamPlayersState && state.players.isEmpty) {
            return _Message(text: l10n.playersLoadError);
          }
          if (state.players.isEmpty) return _Message(text: l10n.playersEmpty);

          return ListView.builder(
            itemCount: state.players.length,
            itemBuilder: (context, index) => _PlayerTile(player: state.players[index]),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: AppSizes.s18)),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final PlayerDTO player;

  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(AppSizes.s16),
      onTap: () => PlayerDetailsDialog.show(context, player),
      leading: CircleAvatar(
        maxRadius: AppSizes.s30,
        backgroundColor: AppColors.grey,
        backgroundImage: player.imageUrl.isNotEmpty ? NetworkImage(player.imageUrl) : null,
      ),
      title: Text(
        player.name,
        style: const TextStyle(color: AppColors.primaryStrong, fontWeight: FontWeight.bold, fontSize: AppSizes.s20),
      ),
      subtitle: Text(player.team),
      trailing: const Icon(Icons.more_vert, size: AppSizes.s30),
    );
  }
}
