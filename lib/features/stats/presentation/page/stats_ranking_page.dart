import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Ranking de artilharia ou de assistências. Sem [region]/[season], usa a
/// região e a temporada selecionadas no [RegionCubit].
class StatsRankingPage extends StatefulWidget {
  final StatsRankingType type;
  final String? region;
  final String? season;

  const StatsRankingPage({super.key, required this.type, this.region, this.season});

  @override
  State<StatsRankingPage> createState() => _StatsRankingPageState();
}

class _StatsRankingPageState extends State<StatsRankingPage> {
  @override
  void initState() {
    super.initState();
    final selected = BlocProvider.of<RegionCubit>(context).state;
    BlocProvider.of<StatsRankingCubit>(context).load(
      type: widget.type,
      region: widget.region ?? selected.selectedRegion,
      season: widget.season ?? selected.selectedSeason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isGoals = widget.type == StatsRankingType.goals;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        title: Text(isGoals ? l10n.statsGoalsTitle : l10n.statsAssistsTitle),
      ),
      body: BlocBuilder<StatsRankingCubit, StatsRankingState>(
        builder: (context, state) {
          if (state is LoadingStatsRankingState && state.players.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorStatsRankingState && state.players.isEmpty) {
            return _Message(text: l10n.statsLoadError);
          }
          if (state.players.isEmpty) return _Message(text: l10n.statsEmpty);

          return ListView.builder(
            itemCount: state.players.length,
            itemBuilder: (context, index) {
              final player = state.players[index];
              final value = widget.type.valueOf(player);
              return _RankingTile(
                player: player,
                subtitle: isGoals ? l10n.playersGoalsCount(value) : l10n.playersAssistsCount(value),
              );
            },
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

class _RankingTile extends StatelessWidget {
  final PlayerDTO player;
  final String subtitle;

  const _RankingTile({required this.player, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = player.imageUrl.isNotEmpty
        ? NetworkImage(player.imageUrl) as ImageProvider
        : const AssetImage(AppImages.avatar);
    return ListTile(
      contentPadding: const EdgeInsets.all(AppSizes.s16),
      leading: CircleAvatar(maxRadius: AppSizes.s30, backgroundColor: AppColors.grey, backgroundImage: image),
      title: Text(
        player.name,
        style: const TextStyle(color: AppColors.primaryStrong, fontWeight: FontWeight.bold, fontSize: AppSizes.s20),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.more_vert, size: AppSizes.s30),
    );
  }
}
