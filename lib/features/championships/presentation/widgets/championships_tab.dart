import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Aba de campeonatos da home: campeonatos da região selecionada. Tocar num
/// campeonato abre os detalhes. A home recria a aba (key) quando a região muda.
class ChampionshipsTab extends StatelessWidget {
  const ChampionshipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    return BlocProvider<ChampionshipsCubit>(
      create: (_) => ChampionshipsCubit(sl())..watch(region: region),
      child: const _ChampionshipsList(),
    );
  }
}

class _ChampionshipsList extends StatelessWidget {
  const _ChampionshipsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ChampionshipsCubit, ChampionshipsState>(
      builder: (context, state) {
        if (state is LoadingChampionshipsState && state.championships.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ErrorChampionshipsState && state.championships.isEmpty) {
          return ArenaEmptyState.error(message: l10n.championshipsLoadError);
        }
        if (state.championships.isEmpty) {
          return ArenaEmptyState(message: l10n.championshipsEmpty, icon: Icons.emoji_events_outlined);
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
          itemCount: state.championships.length,
          itemBuilder: (context, index) => _ChampionshipCard(championship: state.championships[index]),
        );
      },
    );
  }
}

class _ChampionshipCard extends StatelessWidget {
  final ChampionshipDTO championship;

  const _ChampionshipCard({required this.championship});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArenaCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.championshipDetailsPage,
        arguments: {'championship': championship},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (championship.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: championship.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(color: AppColors.greyLight),
              ),
              errorWidget: (_, __, ___) => const AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: AppColors.greyLight,
                  child: Icon(Icons.emoji_events_outlined, color: AppColors.textSecondary),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s14, AppSizes.s12, AppSizes.s14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        championship.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title().copyWith(fontSize: AppSizes.s18 - 1),
                      ),
                      const SizedBox(height: AppSizes.s4),
                      Text(l10n.championshipsSeeDetails, style: AppTypography.label()),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
