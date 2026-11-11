import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_mode_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championship_picker.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_teams_cubit.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/team_card.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/shortcut_tile.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// Aba Times do modo organizador: o seletor do campeonato (o mesmo da aba
/// Tabelas), o cabeçalho com as ações nele (inscrever time, formar grupos,
/// editar campeonato) e os times inscritos nele (tocar abre o elenco; o menu
/// tira do campeonato).
class OrganizerTeamsTab extends StatefulWidget {
  final List<ChampionshipDTO> championships;

  const OrganizerTeamsTab({super.key, required this.championships});

  @override
  State<OrganizerTeamsTab> createState() => _OrganizerTeamsTabState();
}

class _OrganizerTeamsTabState extends State<OrganizerTeamsTab> {
  late final OrganizerTeamsCubit _cubit = OrganizerTeamsCubit(sl(), sl(), sl());

  List<ChampionshipDTO> get _ordered => organizerTableChampionships(widget.championships);

  /// O que está carregado (só o campeonato escolhido: menos leitura).
  ChampionshipDTO? _loaded;

  void _sync(ChampionshipDTO? selected, {bool force = false}) {
    if (selected == null || (!force && selected == _loaded)) return;
    _loaded = selected;
    _cubit.load([selected]);
  }

  @override
  void initState() {
    super.initState();
    _sync(BlocProvider.of<OrganizerModeCubit>(context).state.selectedIn(_ordered));
  }

  /// Campeonato ao vivo mudou (time inscrito/tirado): recarrega os times.
  @override
  void didUpdateWidget(covariant OrganizerTeamsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.championships, widget.championships)) {
      _sync(BlocProvider.of<OrganizerModeCubit>(context).state.selectedIn(_ordered), force: true);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _ordered;
    final selected = context.watch<OrganizerModeCubit>().state.selectedIn(options);
    // Trocou no seletor (aqui ou na aba Tabelas): carrega o novo.
    if (selected != _loaded) WidgetsBinding.instance.addPostFrameCallback((_) => _sync(selected));
    return BlocProvider<OrganizerTeamsCubit>.value(
      value: _cubit,
      child: _OrganizerTeamsList(championships: options, selected: selected),
    );
  }
}

class _OrganizerTeamsList extends StatelessWidget {
  final List<ChampionshipDTO> championships;

  /// Campeonato escolhido no seletor (nulo = sem campeonatos).
  final ChampionshipDTO? selected;

  const _OrganizerTeamsList({required this.championships, required this.selected});

  /// O campeonato das ações: o escolhido no seletor.
  Future<ChampionshipDTO?> _pickChampionship(BuildContext context) async => selected;

  Future<void> _choose(BuildContext context) async {
    final current = selected;
    if (current == null || championships.length < 2) return;
    final picked = await showChampionshipPickerSheet(
      context,
      championships: championships,
      selectedId: current.championshipId,
      showNone: false,
    );
    if (picked?.id != null && context.mounted) {
      BlocProvider.of<OrganizerModeCubit>(context).selectChampionship(picked!.id!);
    }
  }

  String _errorMessage(AppLocalizations l10n, Failure failure) {
    if (failure is ErrorWithMessage) {
      return failure.code == ChampionshipsDataSource.outsideRegionCode ? l10n.organizerOutsideRegion : failure.message;
    }
    return l10n.teamsLoadError;
  }

  Future<void> _enroll(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<OrganizerTeamsCubit>(context);
    final championship = await _pickChampionship(context);
    if (championship == null || !context.mounted) return;
    final candidates = await cubit.candidates(championship);
    if (!context.mounted) return;
    if (candidates.isLeft) {
      showSnackBar(context: context, message: _errorMessage(l10n, candidates.left), isSuccess: false);
      return;
    }
    if (candidates.right.isEmpty) {
      showSnackBar(context: context, message: l10n.organizerEnrollNoCandidates, isSuccess: false);
      return;
    }
    final team = await showTeamPickerSheet(
      context,
      title: l10n.organizerEnrollTeam,
      teams: candidates.right,
      firstRegion: championship.region,
    );
    if (team == null || !context.mounted) return;
    final response = await cubit.setEnrollment(championship, team, enrolled: true);
    if (!context.mounted) return;
    response.fold(
      (failure) => showSnackBar(context: context, message: _errorMessage(l10n, failure), isSuccess: false),
      (_) => showSnackBar(context: context, message: l10n.organizerEnrolled(team.name, championship.title)),
    );
  }

  Future<void> _remove(BuildContext context, ChampionshipDTO championship, TeamDTO team) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<OrganizerTeamsCubit>(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.organizerRemoveTeamTitle(team.name),
      message: l10n.organizerRemoveTeamMessage(championship.title),
      confirmLabel: l10n.organizerRemoveTeam,
      icon: Icons.person_remove_alt_1_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (!confirmed || !context.mounted) return;
    final response = await cubit.setEnrollment(championship, team, enrolled: false);
    if (!context.mounted) return;
    response.fold(
      (failure) => showSnackBar(context: context, message: _errorMessage(l10n, failure), isSuccess: false),
      (_) => showSnackBar(context: context, message: l10n.organizerRemoved(team.name)),
    );
  }

  Future<void> _groups(BuildContext context) async {
    final championship = await _pickChampionship(context);
    if (championship == null || !context.mounted) return;
    await Navigator.pushNamed(context, AppRoutes.organizerGroupsPage, arguments: {'championship': championship});
  }

  Future<void> _editChampionship(BuildContext context) async {
    final championship = await _pickChampionship(context);
    if (championship == null || !context.mounted) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.championshipFormPage,
      // Admin no modo organizador edita tudo (nada travado).
      arguments: {
        'championship': championship,
        'organizer': !BlocProvider.of<OrganizerModeCubit>(context).state.isAdmin,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = selected;
    if (championships.isEmpty || current == null) {
      return ArenaEmptyState(message: l10n.organizerNoChampionships, icon: Icons.emoji_events_outlined);
    }

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShortcutTile(
          title: l10n.organizerEnrollTeam,
          icon: Icons.group_add_rounded,
          onTap: () => _enroll(context),
        ),
        ShortcutTile(
          title: l10n.organizerFormGroups,
          icon: Icons.grid_view_rounded,
          onTap: () => _groups(context),
        ),
        ShortcutTile(
          title: l10n.organizerEditChampionship,
          icon: Icons.edit_note_rounded,
          onTap: () => _editChampionship(context),
        ),
      ],
    );

    return BlocBuilder<OrganizerTeamsCubit, OrganizerTeamsState>(
      builder: (context, state) => ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
        children: [
          ChampionshipSelectTile(
            label: l10n.matchesChampionshipFilter,
            championship: current,
            onTap: () => _choose(context),
          ),
          const SizedBox(height: AppSizes.s16),
          header,
          const SizedBox(height: AppSizes.s20),
          if (state.loading)
            Padding(
              padding: const EdgeInsets.all(AppSizes.s30),
              child: Center(child: CircularProgressIndicator(color: ArenaPalette.of(context).primary)),
            )
          else if (state.error)
            ArenaEmptyState.error(message: l10n.teamsLoadError)
          else ...[
            SectionHeader(
              title: current.title,
              trailing: current.season.isEmpty
                  ? null
                  : Text(current.season, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ),
            ..._teams(context, current, state.teamsByChampionship[current.id] ?? const [], l10n),
          ],
        ],
      ),
    );
  }

  List<Widget> _teams(BuildContext context, ChampionshipDTO championship, List<TeamDTO> teams, AppLocalizations l10n) {
    if (teams.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
          child: Text(l10n.organizerTeamsEmpty, style: AppTypography.subtitle()),
        ),
      ];
    }
    return [
      for (final team in teams)
        TeamCard(
          team: team,
          onTap: () => openTeamRoster(context, {
            'team': team,
            'championshipId': championship.championshipId,
            'onlyChampionship': true,
            'season': championship.season,
          }),
          trailing: PopupMenuButton<void>(
            tooltip: l10n.organizerRemoveTeam,
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: () => _remove(context, championship, team),
                child: Text(l10n.organizerRemoveTeam),
              ),
            ],
          ),
        ),
    ];
  }
}
