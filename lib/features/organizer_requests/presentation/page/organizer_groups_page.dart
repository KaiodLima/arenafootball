import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/championship_groups_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_groups_cubit.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_mode_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/themes/arena_palette.dart';

/// "Formar grupos" do organizador: os grupos do campeonato (até 4 times),
/// criar/editar/apagar e sortear. Na paleta azul do modo organizador.
class OrganizerGroupsPage extends StatelessWidget {
  final ChampionshipDTO championship;

  const OrganizerGroupsPage({super.key, required this.championship});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ArenaPalette.organizerTheme(Theme.of(context)),
      // Inscrição mudou (campeonato ao vivo): recarrega os times.
      child: BlocListener<OrganizerModeCubit, OrganizerModeState>(
        listenWhen: (previous, current) => _find(previous) != _find(current),
        listener: (context, state) {
          final updated = _find(state);
          if (updated != null) BlocProvider.of<OrganizerGroupsCubit>(context).loadTeams(updated);
        },
        child: _GroupsView(championship: championship),
      ),
    );
  }

  ChampionshipDTO? _find(OrganizerModeState state) => state.championships.where((c) => c.id == championship.id).firstOrNull;
}

class _GroupsView extends StatelessWidget {
  final ChampionshipDTO championship;

  const _GroupsView({required this.championship});

  Future<void> _report(BuildContext context, Future<Either<Failure, void>> action, String? success) async {
    final response = await action;
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    response.fold(
      (failure) => showSnackBar(
        context: context,
        message: failure is ErrorWithMessage ? failure.message : l10n.organizerGroupsLoadError,
        isSuccess: false,
      ),
      (_) => success == null ? null : showSnackBar(context: context, message: success),
    );
  }

  Future<void> _edit(BuildContext context, {GroupDTO? group}) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<OrganizerGroupsCubit>(context);
    final state = cubit.state;
    final result = await showModalBottomSheet<GroupDTO>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Theme(
        data: ArenaPalette.organizerTheme(Theme.of(context)),
        child: _GroupEditor(
          group: group,
          suggestedName: state.nextName(),
          allTeams: state.teams,
          freeTeams: state.freeTeams(editing: group),
        ),
      ),
    );
    if (result == null || !context.mounted) return;
    await _report(context, cubit.save(result), l10n.organizerGroupSaved);
  }

  Future<void> _delete(BuildContext context, GroupDTO group) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<OrganizerGroupsCubit>(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.organizerGroupDeleteTitle(group.description),
      message: l10n.organizerGroupDeleteMessage,
      confirmLabel: l10n.organizerGroupDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (!confirmed || !context.mounted) return;
    await _report(context, cubit.delete(group), null);
  }

  Future<void> _draw(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<OrganizerGroupsCubit>(context);
    final options = groupCountOptions(cubit.state.teams.length);
    if (options.isEmpty) {
      showSnackBar(context: context, message: l10n.organizerGroupsDrawNeedTeams, isSuccess: false);
      return;
    }
    final teamCount = cubit.state.teams.length;
    final count = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s8),
              child: Text(l10n.organizerGroupsDrawCount, style: AppTypography.title()),
            ),
            for (final n in options)
              ListTile(
                leading: const Icon(Icons.casino_rounded),
                title: Text(l10n.organizerGroupsDrawOption(n, (teamCount / n).ceil())),
                onTap: () => Navigator.pop(sheetContext, n),
              ),
            const SizedBox(height: AppSizes.s12),
          ],
        ),
      ),
    );
    if (count == null || !context.mounted) return;
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.organizerGroupsDrawConfirmTitle(count),
      message: l10n.organizerGroupsDrawConfirmMessage,
      confirmLabel: l10n.organizerGroupsDraw,
      icon: Icons.casino_rounded,
      tone: cubit.state.groups.isEmpty ? ArenaAlertTone.primary : ArenaAlertTone.warning,
    );
    if (!confirmed || !context.mounted) return;
    await _report(context, cubit.draw(count), l10n.organizerGroupsDrawn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);

    return BlocBuilder<OrganizerGroupsCubit, OrganizerGroupsState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          backgroundColor: palette.primaryDark,
          foregroundColor: AppColors.white,
          surfaceTintColor: AppColors.transparent,
          title: Text(l10n.organizerGroupsTitle(championship.title)),
          actions: [
            IconButton(
              tooltip: l10n.organizerGroupsDraw,
              icon: const Icon(Icons.casino_rounded),
              onPressed: state.busy || state.loading ? null : () => _draw(context),
            ),
          ],
        ),
        floatingActionButton: state.loading || state.error
            ? null
            : FloatingActionButton.extended(
                onPressed: state.busy ? null : () => _edit(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.organizerGroupNew),
              ),
        body: Builder(builder: (context) {
          if (state.loading) return Center(child: CircularProgressIndicator(color: palette.primary));
          if (state.error) return ArenaEmptyState.error(message: l10n.organizerGroupsLoadError);
          if (state.groups.isEmpty) {
            return ArenaEmptyState(message: l10n.organizerGroupsEmpty, icon: Icons.grid_view_rounded);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s100),
            children: [
              for (final group in state.groups)
                _GroupCard(
                  group: group,
                  teams: state.teams,
                  onEdit: state.busy ? null : () => _edit(context, group: group),
                  onDelete: state.busy ? null : () => _delete(context, group),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Cartão do grupo: nome, times com escudo e o menu editar/apagar.
class _GroupCard extends StatelessWidget {
  final GroupDTO group;
  final List<TeamDTO> teams;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupCard({required this.group, required this.teams, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);
    final names = [for (final name in group.teams) if (name.isNotEmpty) name];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      color: AppColors.surface,
      surfaceTintColor: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.s12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.s16,
                    backgroundColor: palette.primarySoft,
                    child: Text(
                      group.description.isEmpty ? '?' : group.description.characters.first.toUpperCase(),
                      style: AppTypography.label(color: palette.primaryDark),
                    ),
                  ),
                  const SizedBox(width: AppSizes.s10),
                  Expanded(child: Text(l10n.organizerGroupLabel(group.description), style: AppTypography.title())),
                  PopupMenuButton<bool>(
                    enabled: onEdit != null,
                    onSelected: (edit) => edit ? onEdit?.call() : onDelete?.call(),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: true, child: Text(l10n.organizerGroupEdit)),
                      PopupMenuItem(value: false, child: Text(l10n.organizerGroupDelete)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s8),
              for (var i = 0; i < group.teams.length; i++)
                if (group.teams[i].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s4),
                    child: Row(
                      children: [
                        TeamCrest(imageUrl: _crestOf(group.teamIdAt(i), group.teams[i]), size: AppSizes.s28),
                        const SizedBox(width: AppSizes.s10),
                        Expanded(child: Text(group.teams[i], style: AppTypography.body())),
                      ],
                    ),
                  ),
              if (names.isEmpty) Text(l10n.organizerTeamsEmpty, style: AppTypography.subtitle()),
            ],
          ),
        ),
      ),
    );
  }

  String? _crestOf(String id, String name) {
    final key = teamKey(id: id, name: name);
    return teams.where((t) => teamKey(id: t.id, name: t.name) == key).firstOrNull?.imageUrl;
  }
}

/// Folha de criar/editar grupo: nome e até 4 times (dos inscritos livres).
class _GroupEditor extends StatefulWidget {
  final GroupDTO? group;
  final String suggestedName;
  final List<TeamDTO> allTeams;
  final List<TeamDTO> freeTeams;

  const _GroupEditor({required this.group, required this.suggestedName, required this.allTeams, required this.freeTeams});

  @override
  State<_GroupEditor> createState() => _GroupEditorState();
}

class _GroupEditorState extends State<_GroupEditor> {
  late final TextEditingController _name;
  late final List<TeamDTO> _teams;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _name = TextEditingController(text: group?.description ?? widget.suggestedName);
    _teams = [
      if (group != null)
        for (var i = 0; i < group.teams.length; i++)
          if (group.teams[i].isNotEmpty)
            widget.allTeams
                    .where((t) => teamKey(id: t.id, name: t.name) == teamKey(id: group.teamIdAt(i), name: group.teams[i]))
                    .firstOrNull ??
                TeamDTO(id: group.teamIdAt(i), name: group.teams[i]),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _addTeam() async {
    final l10n = AppLocalizations.of(context);
    if (_teams.length >= GroupDTO.maxTeams) {
      showSnackBar(context: context, message: l10n.organizerGroupFull, isSuccess: false);
      return;
    }
    final chosen = {for (final t in _teams) teamKey(id: t.id, name: t.name)};
    final options = [for (final t in widget.freeTeams) if (!chosen.contains(teamKey(id: t.id, name: t.name))) t];
    if (options.isEmpty) {
      showSnackBar(context: context, message: l10n.organizerGroupNoTeamsLeft, isSuccess: false);
      return;
    }
    final team = await showTeamPickerSheet(context, title: l10n.organizerGroupAddTeam, teams: options);
    if (team != null && mounted) setState(() => _teams.add(team));
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    Navigator.pop(context, OrganizerGroupsCubit.groupOf(name, _teams, id: widget.group?.id ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = ArenaPalette.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSizes.s20, 0, AppSizes.s20, AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.group == null ? l10n.organizerGroupNew : l10n.organizerGroupEdit, style: AppTypography.title()),
          const SizedBox(height: AppSizes.s16),
          ArenaTextField(
            controller: _name,
            labelText: l10n.organizerGroupName,
            onChaged: (_) {
              if (_nameError) setState(() => _nameError = false);
            },
            errorText: () => _nameError ? l10n.organizerGroupNameRequired : null,
          ),
          const SizedBox(height: AppSizes.s12),
          for (final team in _teams)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: TeamCrest(imageUrl: team.imageUrl, size: AppSizes.s32),
              title: Text(team.name),
              trailing: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _teams.remove(team)),
              ),
            ),
          if (_teams.length < GroupDTO.maxTeams)
            TextButton.icon(
              onPressed: _addTeam,
              icon: Icon(Icons.add_circle_outline_rounded, color: palette.primary),
              label: Text(l10n.organizerGroupAddTeam, style: AppTypography.label(color: palette.primaryDark)),
            ),
          const SizedBox(height: AppSizes.s16),
          ArenaButton.primary(title: l10n.commonSave, function: _save),
        ],
      ),
    );
  }
}
