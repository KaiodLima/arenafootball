import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/group_card.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/page_title_bar.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/stats_shortcuts_bar.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Grupos de uma região na temporada. Sem [region]/[season], usa a região e
/// a temporada selecionadas no [RegionCubit]. Tocar num grupo abre a
/// classificação dele.
class GroupsPage extends StatefulWidget {
  final String? region;
  final String? season;

  /// Só os grupos deste campeonato (nulo = todos da região).
  final int? championshipId;

  const GroupsPage({super.key, this.region, this.season, this.championshipId});

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
    BlocProvider.of<GroupsCubit>(context).watch(
      region: _region,
      season: _season,
      championshipId: widget.championshipId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PageTitleBar(title: l10n.groupsTitle, subtitle: l10n.groupsSubtitle(_region, _season)),
      bottomNavigationBar: StatsShortcutsBar(region: _region, season: _season),
      body: BlocBuilder<GroupsCubit, GroupsState>(
        builder: (context, state) {
          if (state is LoadingGroupsState && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ErrorGroupsState && state.groups.isEmpty) {
            return ArenaEmptyState.error(message: l10n.championshipsGroupsLoadError);
          }
          if (state.groups.isEmpty) {
            return ArenaEmptyState(message: l10n.championshipsGroupsEmpty, icon: Icons.grid_view_rounded);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s24),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return GroupCard(
                group: group,
                crestOf: state.crestOf,
                isFavorite: (id, name) => user?.isFavorite(id: id, name: name) ?? false,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.standingsPage,
                  arguments: {'region': _region, 'season': _season, 'group': group.description, 'groupId': group.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
