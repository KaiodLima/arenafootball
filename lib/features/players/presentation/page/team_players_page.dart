import 'package:flutter/material.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_player_row.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_spotlight.dart';
import 'package:arena_soccer/features/players/presentation/widgets/squad_toolbar.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_mode_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/widgets/organizer_squad_actions.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/players/presentation/widgets/championship_checklist_sheet.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/players/presentation/widgets/team_header.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';

/// Elenco de um time na temporada selecionada: topo com o escudo, as chips
/// "Elenco geral" + uma por competição que o time joga, resumo, busca,
/// ordenação e a lista. Tocar num jogador abre a tela do atleta (o admin
/// edita nome, foto, gols e assistências por lá).
class TeamPlayersPage extends StatefulWidget {
  final TeamDTO team;

  /// Abre já na sublista da competição (`id_campeonato`); nula = elenco geral.
  final int? championshipId;

  /// Organizador: as chips ficam só "Elenco geral" e a de [championshipId].
  final bool onlyChampionship;

  /// Temporada do elenco (campeonato do organizador); nula = a escolhida.
  final String? season;

  const TeamPlayersPage({
    super.key,
    required this.team,
    this.championshipId,
    this.onlyChampionship = false,
    this.season,
  });

  @override
  State<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  static const double _expandedHeight = 340;

  final _scroll = ScrollController();
  late final String _season;

  /// Time exibido; trocado pelo que volta da edição do admin.
  late TeamDTO _team = widget.team;
  bool _collapsed = false;

  /// Busca aberta na barra fixa.
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final season = widget.season;
    _season = season != null && season.isNotEmpty ? season : BlocProvider.of<RegionCubit>(context).state.selectedSeason;
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

  /// Competição do organizador (aberta pela aba Times do modo organizador e
  /// organizada pela conta); nula = sem as ações do organizador.
  int? _organizerChampionship(BuildContext context) {
    final id = widget.championshipId;
    if (!widget.onlyChampionship || id == null) return null;
    final organizes = context.read<OrganizerModeCubit>().state.championships.any((c) => c.championshipId == id);
    return organizes ? id : null;
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
                      background: TeamHeader(
                        team: _team,
                        season: _season,
                        stats: state.players.isEmpty
                            ? null
                            : (players: state.squad.length, goals: state.totalGoals, assists: state.totalAssists),
                      ),
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
    final organizerChampionship = _organizerChampionship(context);
    // Organizador no elenco da competição dele: adicionar/novo e tirar.
    final organizerActions = organizerChampionship != null && state.championshipId == organizerChampionship
        ? OrganizerSquadActions(
            cubit: cubit,
            players: state.players,
            championshipId: organizerChampionship,
            championshipTitle:
                state.view.championships.where((c) => c.championshipId == organizerChampionship).firstOrNull?.title ??
                    '',
            teamId: _team.id,
            teamName: _team.name,
          )
        : null;
    if (state.players.isEmpty) {
      final empty = state is ErrorTeamPlayersState
          ? ArenaEmptyState.error(message: l10n.playersLoadError)
          : ArenaEmptyState(message: l10n.playersEmpty, icon: Icons.groups_outlined);
      return [
        if (organizerActions != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
            sliver: SliverToBoxAdapter(child: organizerActions),
          ),
        SliverFillRemaining(hasScrollBody: false, child: empty),
      ];
    }

    final isAdmin = context.read<SessionCubit>().state.isAdmin;
    final ownsTeam = context.read<OwnedTeamCubit>().state.owns(id: _team.id, name: _team.name);
    final canEnroll = (isAdmin || ownsTeam) && state.championshipId == null && state.view.championships.isNotEmpty;
    final palette = TeamPalette.fromHex(_team.primaryColor, _team.secondaryColor);
    final accent = palette?.ring ?? ArenaPalette.of(context).primary;
    final searching = state.query.trim().isNotEmpty;
    final sections = state.sections;
    final topScorer = state.topScorer;
    final topAssister = state.topAssister;

    void openPlayer(PlayerDTO player) => openAthlete(
          context,
          {'playerId': player.id, 'season': _season, 'name': player.name, 'player': player},
        );

    // Menu "⋮" da linha: arte do atleta (todos), inscrever (admin/dono, no geral) e tirar (organizador).
    List<SquadRowAction> actionsOf(PlayerDTO player) => [
          SquadRowAction(
            icon: Icons.auto_awesome_rounded,
            label: l10n.playerArtAction,
            onSelected: () => Navigator.of(context).pushNamed(
              AppRoutes.playerArtPage,
              arguments: {
                'player': player,
                'team': _team,
                'season': _season,
                'championship': state.view.championships
                    .where((c) => c.championshipId == state.championshipId)
                    .firstOrNull,
              },
            ),
          ),
          if (canEnroll)
            SquadRowAction(
              icon: Icons.emoji_events_outlined,
              label: l10n.enrollPlayerTitle,
              onSelected: () => _enrollPlayer(player, state, l10n),
            ),
          if (organizerActions != null)
            SquadRowAction(
              icon: Icons.person_remove_alt_1_outlined,
              label: l10n.organizerSquadRemove,
              destructive: true,
              onSelected: () => organizerRemoveFromChampionship(
                context,
                cubit: cubit,
                player: player,
                championshipId: organizerChampionship!,
              ),
            ),
        ];

    final showTabs = state.view.championships.isNotEmpty || state.hasFriendlies;

    return [
      // Abas de competição + busca + ordenação, presas ao rolar.
      SliverPersistentHeader(
        pinned: true,
        delegate: SquadToolbarDelegate(
          child: SquadToolbar(
            tabs: showTabs
                ? _ChampionshipChips(
                    state: state,
                    onSelected: cubit.selectChampionship,
                    onlyChampionshipId: widget.onlyChampionship ? widget.championshipId : null,
                  )
                : const SizedBox.shrink(),
            searching: _searching,
            query: state.query,
            onSearch: cubit.setQuery,
            onOpenSearch: () => setState(() => _searching = true),
            onCloseSearch: () {
              cubit.setQuery('');
              setState(() => _searching = false);
            },
            sort: state.sort,
            onSort: cubit.setSort,
            accent: accent,
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (organizerActions != null) ...[
                organizerActions,
                const SizedBox(height: AppSizes.s16),
              ],
              if (!searching)
                SquadSpotlight(
                  topScorer: topScorer,
                  topScorerGoals: topScorer == null ? 0 : state.goalsOf(topScorer),
                  topAssister: topAssister,
                  topAssisterAssists: topAssister == null ? 0 : state.assistsOf(topAssister),
                  accent: accent,
                  onTap: openPlayer,
                ),
            ],
          ),
        ),
      ),
      if (sections.isEmpty)
        SliverToBoxAdapter(
          child: state.query.trim().isEmpty
              ? ArenaEmptyState(message: l10n.playersEmptyChampionship, icon: Icons.groups_outlined)
              : ArenaEmptyState(message: l10n.playersNoResults, icon: Icons.search_off_rounded),
        )
      else
        SliverPadding(
          padding: EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, safeBottom(context, AppSizes.s32)),
          sliver: SliverList.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) => SquadSectionCard(
              section: sections[index],
              accent: accent,
              // Números da lista escolhida (total ou da competição).
              goalsOf: state.goalsOf,
              assistsOf: state.assistsOf,
              topScorerId: topScorerId,
              onTap: openPlayer,
              actionsOf: actionsOf,
            ),
          ),
        ),
    ];
  }
}

/// Seletor compacto do elenco (cabe na barra fixa): pílula com o ícone e a
/// escolha atual — "Elenco geral", a competição ou "Amistosos" — que abre a
/// lista com busca. Amistosos só aparece com números em amistosos.
class _ChampionshipChips extends StatelessWidget {
  final TeamPlayersState state;
  final ValueChanged<int?> onSelected;

  /// Só esta competição (além do geral); sem amistosos.
  final int? onlyChampionshipId;

  const _ChampionshipChips({required this.state, required this.onSelected, this.onlyChampionshipId});

  Future<void> _pick(BuildContext context, List<ChampionshipDTO> championships, bool friendlies) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showChampionshipPickerSheet(
      context,
      championships: championships,
      selectedId: state.championshipId,
      noneLabel: l10n.playersGeneralSquad,
      noneIcon: Icons.groups_rounded,
      extraOption: friendlies
          ? (id: PlayerDTO.friendlyId, label: l10n.teamPlayersFriendly, icon: Icons.handshake_outlined)
          : null,
    );
    if (picked != null) onSelected(picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);
    final championships = rosterChipChampionships(state.view.championships, onlyChampionshipId);
    final friendlies =
        onlyChampionshipId == null && (state.hasFriendlies || state.championshipId == PlayerDTO.friendlyId);
    final current = state.championshipId;
    final (IconData icon, String label) = current == null
        ? (Icons.groups_rounded, l10n.playersGeneralSquad)
        : current == PlayerDTO.friendlyId
            ? (Icons.handshake_outlined, l10n.teamPlayersFriendly)
            : (
                Icons.emoji_events_rounded,
                championships.where((c) => c.championshipId == current).firstOrNull?.title ?? l10n.playersGeneralSquad,
              );
    final shape = StadiumBorder(side: BorderSide(color: palette.primary.withValues(alpha: 0.5)));
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: palette.primarySoft,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: () => _pick(context, championships, friendlies),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s8, AppSizes.s8, AppSizes.s8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSizes.s18, color: palette.primaryDark),
                const SizedBox(width: AppSizes.s6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: palette.primaryDark).copyWith(fontSize: AppSizes.s14),
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: AppSizes.s20, color: palette.primaryDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Competições das chips do elenco: todas ou, com [onlyId] (organizador), só
/// essa.
List<ChampionshipDTO> rosterChipChampionships(List<ChampionshipDTO> all, int? onlyId) => onlyId == null
    ? all
    : [
        for (final c in all)
          if (c.championshipId == onlyId) c
      ];
