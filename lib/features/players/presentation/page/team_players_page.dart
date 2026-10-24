import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/players/presentation/widgets/championship_checklist_sheet.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_summary.dart';
import 'package:arena_soccer/features/players/presentation/widgets/team_header.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_search_field.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Elenco de um time na temporada selecionada: topo com o escudo, as chips
/// "Elenco geral" + uma por competição que o time joga, resumo, busca,
/// ordenação e a lista. Tocar num jogador abre a tela do atleta (o admin
/// edita nome, foto, gols e assistências por lá).
class TeamPlayersPage extends StatefulWidget {
  final TeamDTO team;

  /// Abre já na sublista da competição (`id_campeonato`); nula = elenco geral.
  final int? championshipId;

  const TeamPlayersPage({super.key, required this.team, this.championshipId});

  @override
  State<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  static const double _expandedHeight = 300;

  final _scroll = ScrollController();
  late final String _season;

  /// Time exibido; trocado pelo que volta da edição do admin.
  late TeamDTO _team = widget.team;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _season = BlocProvider.of<RegionCubit>(context).state.selectedSeason;
    BlocProvider.of<TeamPlayersCubit>(context).watch(
      teamId: widget.team.id,
      teamName: widget.team.name,
      season: _season,
      region: widget.team.region,
      championshipId: widget.championshipId,
    );
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

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.editTeamPage,
      arguments: {'team': _team, 'season': _season},
    );
    if (updated is TeamDTO && mounted) setState(() => _team = updated);
  }

  /// Admin: em quais competições da temporada o time joga (só o time entra).
  Future<void> _enrollTeam(AppLocalizations l10n) async {
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);
    final offered = await cubit.eligibleChampionships(_team);
    if (!mounted) return;
    if (offered == null) {
      showSnackBar(context: context, message: l10n.enrollLoadError, isSuccess: false);
      return;
    }
    final selected = await showChampionshipChecklistSheet(
      context,
      title: l10n.enrollTeamTitle,
      subtitle: l10n.enrollTeamSubtitle(_team.name),
      items: [for (final c in offered) ChampionshipChecklistItem(c)],
      selected: {
        for (final c in offered)
          if (c.hasTeam(id: _team.id, name: _team.name)) c.championshipId,
      },
    );
    if (selected == null || !mounted) return;
    final error = await cubit.saveTeamChampionships(_team, offered, selected);
    if (!mounted) return;
    showSnackBar(context: context, message: error ?? l10n.enrollSaved, isSuccess: error == null);
  }

  /// Admin/dono: em quais competições do time o atleta joga por ele.
  Future<void> _enrollPlayer(PlayerDTO player, TeamPlayersState state, AppLocalizations l10n) async {
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);
    final items = [
      for (final c in state.view.championships)
        ChampionshipChecklistItem(
          c,
          blockedReason: switch (player.enrollmentIn(c.championshipId)) {
            final e? when !player.playsIn(c.championshipId, teamId: _team.id, teamName: _team.name) =>
              l10n.enrollPlayerOtherTeam(e.team),
            _ => null,
          },
        ),
    ];
    final selected = await showChampionshipChecklistSheet(
      context,
      title: l10n.enrollPlayerTitle,
      subtitle: l10n.enrollPlayerSubtitle(player.name, _team.name),
      items: items,
      selected: {
        for (final c in state.view.championships)
          if (player.playsIn(c.championshipId, teamId: _team.id, teamName: _team.name)) c.championshipId,
      },
    );
    if (selected == null || !mounted) return;
    final error = await cubit.savePlayerChampionships(player, selected);
    if (!mounted) return;
    showSnackBar(context: context, message: error ?? l10n.enrollPlayerSaved(player.name), isSuccess: error == null);
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.teamDeleteTitle(_team.name),
      message: l10n.teamDeleteMessage(_season),
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed && mounted) await BlocProvider.of<TeamPlayersCubit>(context).deleteTeam(_team);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<TeamPlayersCubit>(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;
    final palette = TeamPalette.fromHex(_team.primaryColor, _team.secondaryColor);
    final barColor = palette?.bar ?? AppColors.primaryDark;
    final barForeground = palette?.onAccent ?? AppColors.white;
    // Expandido, a status bar fica sobre o fundo do cabeçalho; recolhido, sobre a barra.
    final topColor = _collapsed ? palette?.bar : palette?.background;
    final overlay = topColor != null && readableOn(topColor) != AppColors.white
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<TeamPlayersCubit, TeamPlayersState>(
          listener: (context, state) {
            if (state is DeletedTeamPlayersState) {
              showSnackBar(context: context, message: l10n.teamDeleted(state.teamName));
              Navigator.pop(context);
              return;
            }
            if (state is ErrorTeamPlayersState && state.players.isNotEmpty) {
              showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
            }
          },
          builder: (context, state) {
            final visible = state.visiblePlayers;
            final topScorerId = state.topScorerId;
            final deleting = state is DeletingTeamPlayersState;

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
                    backgroundColor: barColor,
                    foregroundColor: barForeground,
                    surfaceTintColor: AppColors.transparent,
                    systemOverlayStyle: overlay,
                    title: AnimatedOpacity(
                      opacity: _collapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(color: barForeground).copyWith(fontSize: AppSizes.s18),
                      ),
                    ),
                    actions: [
                      if (isAdmin)
                        deleting
                            ? Padding(
                                padding: const EdgeInsets.all(AppSizes.s14),
                                child: SizedBox.square(
                                  dimension: AppSizes.s20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: barForeground),
                                ),
                              )
                            : CardMenuButton(
                                onImage: true,
                                actions: [
                                  CardMenuAction(
                                    icon: Icons.edit_outlined,
                                    label: l10n.teamEdit,
                                    onSelected: _edit,
                                  ),
                                  CardMenuAction(
                                    icon: Icons.emoji_events_outlined,
                                    label: l10n.enrollTeamMenu,
                                    onSelected: () => _enrollTeam(l10n),
                                  ),
                                  CardMenuAction(
                                    icon: Icons.delete_outline_rounded,
                                    label: l10n.teamDelete,
                                    destructive: true,
                                    onSelected: () => _confirmDelete(l10n),
                                  ),
                                ],
                              ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: TeamHeader(team: _team, season: _season),
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

    final isAdmin = context.read<SessionCubit>().state.isAdmin;
    final ownsTeam = context.read<OwnedTeamCubit>().state.owns(id: _team.id, name: _team.name);
    final canEnroll = (isAdmin || ownsTeam) && state.championshipId == null && state.view.championships.isNotEmpty;

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.view.championships.isNotEmpty || state.hasFriendlies) ...[
                _ChampionshipChips(state: state, onSelected: cubit.selectChampionship),
                const SizedBox(height: AppSizes.s12),
              ],
              SquadSummary(players: state.squad.length, goals: state.totalGoals, assists: state.totalAssists),
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
          child: state.query.trim().isEmpty
              ? ArenaEmptyState(message: l10n.playersEmptyChampionship, icon: Icons.groups_outlined)
              : ArenaEmptyState(message: l10n.playersNoResults, icon: Icons.search_off_rounded),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s32),
          sliver: SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final player = visible[index];
              return PlayerCard(
                // Números da lista escolhida (total ou da competição).
                player: player.copyWith(goals: state.goalsOf(player), assists: state.assistsOf(player)),
                // No elenco geral, admin/dono inscreve o atleta nas competições do time.
                onEnroll: canEnroll ? () => _enrollPlayer(player, state, l10n) : null,
                isTopScorer: player.id == topScorerId,
                onTap: () => openAthlete(
                  context,
                  {'playerId': player.id, 'season': _season, 'name': player.name, 'player': player},
                ),
              );
            },
          ),
        ),
    ];
  }
}

/// "Elenco geral" + uma chip por competição que o time joga na temporada e,
/// se houver números em amistosos, "Amistosos".
class _ChampionshipChips extends StatelessWidget {
  final TeamPlayersState state;
  final ValueChanged<int?> onSelected;

  const _ChampionshipChips({required this.state, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final championships = state.view.championships;
    final friendlies = state.hasFriendlies || state.championshipId == PlayerDTO.friendlyId;
    return SizedBox(
      height: AppSizes.s40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: championships.length + 1 + (friendlies ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ArenaChoiceChip(
              label: l10n.playersGeneralSquad,
              icon: Icons.groups_rounded,
              selected: state.championshipId == null,
              onTap: () => onSelected(null),
            );
          }
          // Amistosos: contagem à parte, depois das competições.
          if (index > championships.length) {
            return ArenaChoiceChip(
              label: l10n.teamPlayersFriendly,
              icon: Icons.handshake_outlined,
              selected: state.championshipId == PlayerDTO.friendlyId,
              onTap: () => onSelected(PlayerDTO.friendlyId),
            );
          }
          final championship = championships[index - 1];
          return ArenaChoiceChip(
            label: championship.title,
            icon: Icons.emoji_events_outlined,
            selected: state.championshipId == championship.championshipId,
            onTap: () => onSelected(championship.championshipId),
          );
        },
      ),
    );
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
