import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_summary.dart';
import 'package:arena_soccer/features/players/presentation/widgets/team_header.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Elenco de um time na temporada selecionada: topo com o escudo, resumo,
/// busca, ordenação e a lista. Tocar num jogador abre a tela do atleta
/// (o admin edita nome, foto, gols e assistências por lá).
class TeamPlayersPage extends StatefulWidget {
  final TeamDTO team;

  const TeamPlayersPage({super.key, required this.team});

  @override
  State<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  static const double _expandedHeight = 300;

  final _scroll = ScrollController();
  late final String _season;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _season = BlocProvider.of<RegionCubit>(context).state.selectedSeason;
    BlocProvider.of<TeamPlayersCubit>(context).watch(teamName: widget.team.name, season: _season);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed = _scroll.offset > _expandedHeight - kToolbarHeight - MediaQuery.paddingOf(context).top;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<TeamPlayersCubit, TeamPlayersState>(
          listener: (context, state) {
            if (state is ErrorTeamPlayersState && state.players.isNotEmpty) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
          },
          builder: (context, state) {
            final visible = state.visiblePlayers;
            final topScorerId = state.topScorerId;

            // Quando a busca encolhe a lista, a posição volta ao topo sem evento de
            // rolagem: as métricas avisam, e o título da barra é recalculado.
            return NotificationListener<ScrollMetricsNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _scroll.hasClients) _onScroll();
                });
                return false;
              },
              child: CustomScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: _expandedHeight,
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.white,
                    surfaceTintColor: AppColors.transparent,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    title: AnimatedOpacity(
                      opacity: _collapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: TeamHeader(team: widget.team, season: _season),
                    ),
                  ),
                  ..._body(context, state, visible, topScorerId, cubit, l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    TeamPlayersState state,
    List<PlayerDTO> visible,
    String? topScorerId,
    TeamPlayersCubit cubit,
    AppLocalizations l10n,
  ) {
    if (state is LoadingTeamPlayersState && state.players.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ];
    }
    if (state.players.isEmpty) {
      final empty = state is ErrorTeamPlayersState
          ? ArenaEmptyState.error(message: l10n.playersLoadError)
          : ArenaEmptyState(message: l10n.playersEmpty, icon: Icons.groups_outlined);
      return [SliverFillRemaining(hasScrollBody: false, child: empty)];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SquadSummary(players: state.players.length, goals: state.totalGoals, assists: state.totalAssists),
              const SizedBox(height: AppSizes.s16),
              ArenaSearchField(hint: l10n.playersSearchHint, onChanged: cubit.setQuery),
              const SizedBox(height: AppSizes.s12),
              Row(
                children: [
                  _SortChip(
                    label: l10n.playersSortGoals,
                    selected: state.sort == PlayersSort.goals,
                    onTap: () => cubit.setSort(PlayersSort.goals),
                  ),
                  const SizedBox(width: AppSizes.s8),
                  _SortChip(
                    label: l10n.playersSortAssists,
                    selected: state.sort == PlayersSort.assists,
                    onTap: () => cubit.setSort(PlayersSort.assists),
                  ),
                  const SizedBox(width: AppSizes.s8),
                  _SortChip(
                    label: l10n.playersSortName,
                    selected: state.sort == PlayersSort.name,
                    onTap: () => cubit.setSort(PlayersSort.name),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s16),
            ],
          ),
        ),
      ),
      if (visible.isEmpty)
        SliverToBoxAdapter(
          child: ArenaEmptyState(message: l10n.playersNoResults, icon: Icons.search_off_rounded),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
          sliver: SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final player = visible[index];
              return PlayerCard(
                player: player,
                isTopScorer: player.id == topScorerId,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.playerProfilePage,
                  arguments: {'playerId': player.id, 'season': _season, 'name': player.name, 'player': player},
                ),
              );
            },
          ),
        ),
    ];
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primaryDark : AppColors.greyLight)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s8),
          child: Text(label, style: AppTypography.label(color: selected ? AppColors.white : AppColors.primaryDark)),
        ),
      ),
    );
  }
}
