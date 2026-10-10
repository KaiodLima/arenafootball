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
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

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
          return _Message(text: l10n.championshipsLoadError);
        }
        if (state.championships.isEmpty) return _Message(text: l10n.championshipsEmpty);

        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: state.championships.length,
          itemBuilder: (context, index) => _ChampionshipItem(championship: state.championships[index]),
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

class _ChampionshipItem extends StatelessWidget {
  final ChampionshipDTO championship;

  const _ChampionshipItem({required this.championship});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.championshipDetailsPage,
        arguments: {'championship': championship},
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10),
            child: CachedNetworkImage(
              imageUrl: championship.imageUrl,
              fit: BoxFit.scaleDown,
              placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.primary),
              errorWidget: (_, __, ___) => const Icon(Icons.error, color: AppColors.white),
            ),
          ),
          ListTile(
            title: Text(
              championship.title,
              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: AppSizes.s20),
            ),
          ),
        ],
      ),
    );
  }
}
