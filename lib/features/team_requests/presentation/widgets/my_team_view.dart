import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/presentation/widgets/player_request_labels.dart';
import 'package:arena_soccer/features/players/presentation/widgets/player_card.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/my_team_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/my_team_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/widgets/reason_dialog.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_color_selector.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// "Meu time": área do dono aprovado, com abas Elenco · Pedidos · Editar.
class MyTeamView extends StatefulWidget {
  final TeamRequestDTO request;

  const MyTeamView({super.key, required this.request});

  @override
  State<MyTeamView> createState() => _MyTeamViewState();
}

class _MyTeamViewState extends State<MyTeamView> {
  late final MyTeamCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<MyTeamCubit>(context)
      ..load(teamId: widget.request.teamId, teamName: widget.request.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<MyTeamCubit, MyTeamState>(
      listener: (context, state) {
        if (state is ErrorMyTeamState) showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        if (state is MyTeamNoticeState) {
          showSnackBar(
            context: context,
            message: switch (state.notice) {
              MyTeamNotice.saved => l10n.myTeamSaved,
              MyTeamNotice.playerAdded => l10n.myTeamPlayerAdded(state.name),
              MyTeamNotice.requestApproved => l10n.playerRequestsApproved(state.name, state.team?.name ?? ''),
              MyTeamNotice.requestRejected => l10n.playerRequestsRejected,
            },
          );
        }
      },
      builder: (context, state) {
        final team = state.team;
        final pending = state.pendingRequests.length;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: 0,
              title: Text(
                l10n.myTeamTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(AppSizes.s100 + kTextTabBarHeight),
                child: Column(
                  children: [
                    SizedBox(
                      height: AppSizes.s100,
                      child: ArenaHeroBackground(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                          child: Row(
                            children: [
                              TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s64),
                              const SizedBox(width: AppSizes.s14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team?.name ?? widget.request.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.title(color: AppColors.white),
                                    ),
                                    Text(
                                      [widget.request.region, l10n.myTeamOwnerBadge].join(' · '),
                                      style: AppTypography.subtitle(color: AppColors.whiteSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TabBar(
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.white,
                      unselectedLabelColor: AppColors.whiteSoft,
                      dividerColor: AppColors.transparent,
                      tabs: [
                        Tab(text: l10n.myTeamTabSquad),
                        Tab(text: pending == 0 ? l10n.myTeamTabRequests : '${l10n.myTeamTabRequests} ($pending)'),
                        Tab(text: l10n.myTeamTabEdit),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _SquadTab(state: state, onAdd: () => _openAddPlayer(state)),
                _RequestsTab(state: state, onApprove: _cubit.approve, onReject: _reject),
                _EditTab(state: state, onSave: _cubit.saveDetails),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reject(PlayerRequestDTO request) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showReasonDialog(
      context,
      title: l10n.playerRequestsRejectTitle(request.name),
      confirmLabel: l10n.playerRequestsReject,
    );
    if (reason != null) await _cubit.reject(request, reason: reason);
  }

  Future<void> _openAddPlayer(MyTeamState state) async {
    final result = await showModalBottomSheet<(String, String, File?)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddPlayerSheet(),
    );
    if (result != null) await _cubit.addPlayer(name: result.$1, position: result.$2, photo: result.$3);
  }
}

class _SquadTab extends StatelessWidget {
  final MyTeamState state;
  final VoidCallback onAdd;

  const _SquadTab({required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
      children: [
        ArenaButton.primary(title: l10n.myTeamAddPlayer, isLoading: state.saving, function: state.saving ? null : onAdd),
        const SizedBox(height: AppSizes.s16),
        if (state.players.isEmpty && !state.loading)
          ArenaEmptyState(message: l10n.myTeamSquadEmpty, icon: Icons.groups_outlined)
        else
          for (final player in state.players)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.s8),
              child: PlayerCard(
                player: player,
                isTopScorer: false,
                // O perfil libera o editor para o dono do time.
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.playerProfilePage,
                  arguments: {'playerId': player.id, 'player': player},
                ),
              ),
            ),
      ],
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final MyTeamState state;
  final ValueChanged<PlayerRequestDTO> onApprove;
  final ValueChanged<PlayerRequestDTO> onReject;

  const _RequestsTab({required this.state, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = state.pendingRequests;
    if (pending.isEmpty) return ArenaEmptyState(message: l10n.myTeamRequestsEmpty, icon: Icons.how_to_reg_outlined);

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.s16),
      itemCount: pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s10),
      itemBuilder: (context, index) {
        final request = pending[index];
        final busy = state.busy.contains(request.userId);
        final position = request.position;
        return Container(
          padding: const EdgeInsets.all(AppSizes.s14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.name, style: AppTypography.body().copyWith(fontWeight: FontWeight.w700)),
              Text(
                [if (position != null) playerPositionLabel(l10n, position), request.userName].join(' · '),
                style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
              ),
              if (request.message.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s8),
                Text('"${request.message}"', style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
              ],
              const SizedBox(height: AppSizes.s10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: busy ? null : () => onReject(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: Text(l10n.playerRequestsReject),
                  ),
                  const SizedBox(width: AppSizes.s8),
                  FilledButton(
                    onPressed: busy ? null : () => onApprove(request),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text(l10n.playerRequestsApprove),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditTab extends StatefulWidget {
  final MyTeamState state;
  final Future<void> Function({
    required String description,
    required String primaryColor,
    required String secondaryColor,
    File? crest,
  }) onSave;

  const _EditTab({required this.state, required this.onSave});

  @override
  State<_EditTab> createState() => _EditTabState();
}

class _EditTabState extends State<_EditTab> {
  late final _description = TextEditingController(text: widget.state.team?.description);
  File? _crest;

  /// Nulas = ainda não mexeu (vale a do time).
  String? _primary;
  String? _secondary;

  @override
  void didUpdateWidget(covariant _EditTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Descrição chegou depois (time carregado) e o campo ainda está vazio.
    final description = widget.state.team?.description ?? '';
    if (_description.text.isEmpty && description.isNotEmpty) _description.text = description;
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final team = widget.state.team;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.s16),
      children: [
        Center(
          child: CirclePhotoPicker(
            file: _crest,
            currentUrl: team?.imageUrl ?? '',
            addLabel: l10n.teamRequestCrestAdd,
            emptyIcon: Icons.shield_outlined,
            size: AppSizes.s100,
            onPicked: (file) => setState(() => _crest = file),
            onRemove: () => setState(() => _crest = null),
          ),
        ),
        const SizedBox(height: AppSizes.s20),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: arenaInputDecoration(label: l10n.teamRequestDescriptionLabel, icon: Icons.notes_rounded),
        ),
        TeamColorsPicker(
          primary: _primary ?? team?.primaryColor ?? '',
          secondary: _secondary ?? team?.secondaryColor ?? '',
          onPrimaryChanged: (hex) => setState(() => _primary = hex),
          onSecondaryChanged: (hex) => setState(() => _secondary = hex),
        ),
        const SizedBox(height: AppSizes.s16),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: AppSizes.s18, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.s6),
            Expanded(
              child: Text(l10n.myTeamNameLocked, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s20),
        ArenaButton.primary(
          title: l10n.commonSave,
          isLoading: widget.state.saving,
          function: widget.state.saving || team == null
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await widget.onSave(
                    description: _description.text,
                    primaryColor: _primary ?? team.primaryColor,
                    secondaryColor: _secondary ?? team.secondaryColor,
                    crest: _crest,
                  );
                  if (mounted) setState(() => _crest = null);
                },
        ),
      ],
    );
  }
}

/// Jogador novo do time: nome, posição e foto. Devolve (nome, posição, foto).
class _AddPlayerSheet extends StatefulWidget {
  const _AddPlayerSheet();

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _name = TextEditingController();
  PlayerPosition? _position;
  File? _photo;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _name.text.trim().length >= 3;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s20,
        0,
        AppSizes.s20,
        AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.myTeamAddPlayer, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            const SizedBox(height: AppSizes.s16),
            Center(
              child: CirclePhotoPicker(
                file: _photo,
                addLabel: l10n.playersPhotoAdd,
                emptyIcon: Icons.add_a_photo_outlined,
                size: AppSizes.s80,
                onPicked: (file) => setState(() => _photo = file),
                onRemove: () => setState(() => _photo = null),
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _name,
              maxLength: 40,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: arenaInputDecoration(label: l10n.playersNameLabel, icon: Icons.person_outline_rounded),
            ),
            Text(l10n.playerRequestPositionLabel, style: AppTypography.label(color: AppColors.textPrimary)),
            const SizedBox(height: AppSizes.s10),
            Wrap(
              spacing: AppSizes.s8,
              runSpacing: AppSizes.s8,
              children: [
                for (final position in PlayerPosition.values)
                  ArenaChoiceChip(
                    label: playerPositionLabel(l10n, position),
                    selected: position == _position,
                    onTap: () => setState(() => _position = position),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: l10n.playersSubmit,
              function: valid
                  ? () => Navigator.pop<(String, String, File?)>(
                        context,
                        (_name.text.trim(), _position?.key ?? '', _photo),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
