import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/group_card.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcut_actions.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Grupos de uma região na temporada. Sem [region]/[season], usa a região e
/// a temporada selecionadas no [RegionCubit]. Tocar num grupo abre a
/// classificação dele.
class GroupsPage extends StatefulWidget {
  final String? region;
  final String? season;

  const GroupsPage({super.key, this.region, this.season});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final String _region;
  late final String _season;

  @override
  void initState() {
    super.initState();
    final selected = BlocProvider.of<RegionCubit>(context).state;
    _region = widget.region ?? selected.selectedRegion;
    _season = widget.season ?? selected.selectedSeason;
    BlocProvider.of<GroupsCubit>(context).watch(region: _region, season: _season);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(AppImages.logo, width: AppSizes.logoWidth, height: AppSizes.logoHeight),
        actions: statsShortcutActions(context, region: _region, season: _season),
      ),
      body: BlocBuilder<GroupsCubit, GroupsState>(
        builder: (context, state) {
          if (state is LoadingGroupsState && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorGroupsState && state.groups.isEmpty) {
            return _Message(text: l10n.championshipsGroupsLoadError);
          }
          if (state.groups.isEmpty) return _Message(text: l10n.championshipsGroupsEmpty);

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.s8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.s10,
              crossAxisSpacing: AppSizes.s10,
              childAspectRatio: 0.8,
            ),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.standingsPage,
                  arguments: {'region': _region, 'season': _season, 'group': group.description},
                ),
                child: GroupCard(group: group),
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.white, fontSize: AppSizes.s18),
      ),
    );
  }
}
