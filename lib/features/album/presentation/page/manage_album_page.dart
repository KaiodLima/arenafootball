import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/presentation/bloc/manage_album_cubit.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_tile.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Painel do admin "Álbum de figurinhas": a lista de eventos (ligar/desligar,
/// apagar, criar) e o editor do evento aberto (times e figurinhas).
class ManageAlbumPage extends StatefulWidget {
  const ManageAlbumPage({super.key});

  @override
  State<ManageAlbumPage> createState() => _ManageAlbumPageState();
}

class _ManageAlbumPageState extends State<ManageAlbumPage> {
  late final ManageAlbumCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ManageAlbumCubit>(context)..watch();
  }

  /// "Novo evento": folha de alerta do app com o campo do nome.
  Future<void> _newEvent(AppLocalizations l10n) async {
    final controller = TextEditingController();
    final confirmed = await showArenaConfirm(
      context,
      header: l10n.albumAdminNewEvent,
      title: l10n.albumAdminNewEvent,
      message: l10n.albumAdminNewEventMessage,
      icon: Icons.collections_bookmark_outlined,
      confirmLabel: l10n.albumAdminCreate,
      content: ArenaTextField(
        controller: controller,
        autofocus: true,
        labelText: l10n.albumAdminEventTitle,
        hintText: l10n.albumAdminEventTitleHint,
      ),
    );
    final title = controller.text.trim();
    // Descarta depois da animação de fechar (o campo ainda está na tela).
    Future<void>.delayed(const Duration(milliseconds: 500), controller.dispose);
    if (!confirmed || !mounted) return;
    if (title.length < 3) {
      showSnackBar(context: context, message: l10n.albumAdminEventTitleShort, isSuccess: false);
      return;
    }
    await _cubit.saveEvent(AlbumEventDTO(title: title));
  }

  Future<void> _confirmDelete(AlbumEventDTO event, AppLocalizations l10n) async {
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.albumAdminDeleteTitle(event.title),
      message: l10n.albumAdminDeleteMessage,
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await _cubit.deleteEvent(event);
  }

  String _notice(NoticeManageAlbumState state, AppLocalizations l10n) => switch (state.notice) {
        ManageAlbumNotice.saved => l10n.albumAdminSaved,
        ManageAlbumNotice.activated => l10n.albumAdminActivated,
        ManageAlbumNotice.deactivated => l10n.albumAdminDeactivated,
        ManageAlbumNotice.deleted => l10n.albumAdminDeleted,
        ManageAlbumNotice.generated => l10n.albumAdminGenerated(state.count),
        ManageAlbumNotice.stickerSaved => l10n.albumAdminStickerSaved,
        ManageAlbumNotice.stickerDeleted => l10n.albumAdminStickerDeleted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ManageAlbumCubit, ManageAlbumState>(
      listener: (context, state) {
        if (state is ErrorManageAlbumState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
        if (state is NoticeManageAlbumState) showSnackBar(context: context, message: _notice(state, l10n));
      },
      builder: (context, state) {
        final editing = state.editing;
        return PopScope(
          canPop: editing == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _cubit.edit(null);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              titleSpacing: 0,
              title: Text(
                editing?.title ?? l10n.albumAdminTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
              bottom: state.busy
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(AppSizes.s2),
                      child: LinearProgressIndicator(minHeight: AppSizes.s2, color: AppColors.googleYellow),
                    )
                  : null,
            ),
            floatingActionButton: editing == null
                ? FloatingActionButton.extended(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                    onPressed: state.busy ? null : () => _newEvent(l10n),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.albumAdminNewEvent),
                  )
                : null,
            body: state.loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : editing != null
                    ? _EventEditor(state: state, cubit: _cubit)
                    : state.events.isEmpty
                        ? ArenaEmptyState(message: l10n.albumAdminEmpty, icon: Icons.collections_bookmark_outlined)
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s100),
                            children: [
                              Text(l10n.albumAdminIntro, style: AppTypography.subtitle()),
                              const SizedBox(height: AppSizes.s12),
                              for (final event in state.events)
                                ArenaCard(
                                  margin: const EdgeInsets.only(bottom: AppSizes.s10),
                                  padding: EdgeInsets.zero,
                                  child: ListTile(
                                    onTap: () => _cubit.edit(event),
                                    title: Text(event.title, style: AppTypography.label(color: AppColors.textPrimary)),
                                    subtitle: Text(
                                      l10n.albumAdminEventInfo(event.teamIds.length),
                                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: event.active,
                                          onChanged: state.busy ? null : (value) => _cubit.setActive(event, value),
                                        ),
                                        IconButton(
                                          tooltip: l10n.commonDelete,
                                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                                          onPressed: state.busy ? null : () => _confirmDelete(event, l10n),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
          ),
        );
      },
    );
  }
}

/// Editor do evento: título, descrição, times (páginas) e as figurinhas de
/// cada time.
class _EventEditor extends StatefulWidget {
  final ManageAlbumState state;
  final ManageAlbumCubit cubit;

  const _EventEditor({required this.state, required this.cubit});

  @override
  State<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<_EventEditor> {
  late final _title = TextEditingController(text: widget.state.editing!.title);
  late final _description = TextEditingController(text: widget.state.editing!.description);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  AlbumEventDTO get _event => widget.state.editing!;

  void _saveTexts() {
    final title = _title.text.trim();
    if (title.length < 3) return;
    widget.cubit.saveEvent(_event.copyWith(title: title, description: _description.text.trim()));
  }

  void _toggleTeam(String teamId, String teamName) {
    final ids = [..._event.teamIds];
    final names = [..._event.teams];
    final index = ids.indexOf(teamId);
    if (index >= 0) {
      ids.removeAt(index);
      if (index < names.length) names.removeAt(index);
    } else {
      ids.add(teamId);
      names.add(teamName);
    }
    widget.cubit.saveEvent(_event.copyWith(teamIds: ids, teams: names));
  }

  Future<void> _editSticker(StickerDTO sticker) async {
    final result = await showModalBottomSheet<_StickerEdit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StickerSheet(sticker: sticker),
    );
    if (result == null) return;
    if (result.delete) {
      await widget.cubit.deleteSticker(sticker);
    } else {
      await widget.cubit.saveSticker(result.sticker, image: result.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final pages = state.pages;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s32),
      children: [
        FormSection(
          title: l10n.albumAdminEventData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                maxLength: 40,
                decoration: arenaInputDecoration(label: l10n.albumAdminEventTitle, icon: Icons.title_rounded),
              ),
              TextField(
                controller: _description,
                maxLength: 200,
                minLines: 1,
                maxLines: 3,
                decoration: arenaInputDecoration(label: l10n.albumAdminEventDescription, icon: Icons.notes_rounded),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: state.busy ? null : _saveTexts,
                  icon: const Icon(Icons.save_outlined, size: AppSizes.s18),
                  label: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        FormSection(
          title: l10n.albumAdminTeams,
          child: Wrap(
            spacing: AppSizes.s8,
            runSpacing: AppSizes.s8,
            children: [
              for (final team in state.teams)
                FilterChip(
                  label: Text(team.name),
                  selected: _event.teamIds.contains(team.id),
                  onSelected: state.busy ? null : (_) => _toggleTeam(team.id, team.name),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        for (final page in pages) _TeamStickers(page: page, state: state, cubit: widget.cubit, onEdit: _editSticker),
      ],
    );
  }
}

/// Figurinhas de um time no editor: gerar do elenco, acrescentar e editar.
class _TeamStickers extends StatelessWidget {
  final AlbumTeamPage page;
  final ManageAlbumState state;
  final ManageAlbumCubit cubit;
  final ValueChanged<StickerDTO> onEdit;

  const _TeamStickers({required this.page, required this.state, required this.cubit, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormSection(
      title: l10n.albumAdminTeamStickers(page.team, page.stickers.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSizes.s8,
            children: [
              OutlinedButton.icon(
                onPressed: state.busy ? null : () => cubit.generateFromSquad(page.teamId),
                icon: const Icon(Icons.groups_rounded, size: AppSizes.s18),
                label: Text(l10n.albumAdminGenerate),
              ),
              TextButton.icon(
                onPressed: state.busy
                    ? null
                    : () => onEdit(StickerDTO(teamId: page.teamId, team: page.team, order: page.stickers.length + 1)),
                icon: const Icon(Icons.add_rounded, size: AppSizes.s18),
                label: Text(l10n.albumAdminAddSticker),
              ),
            ],
          ),
          if (page.stickers.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSizes.s8,
              crossAxisSpacing: AppSizes.s8,
              childAspectRatio: 3 / 4,
              children: [
                for (final sticker in page.stickers)
                  StickerTile(sticker: sticker, count: 1, frame: AppColors.primary, onTap: () => onEdit(sticker)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Resultado da folha da figurinha: gravar (com a foto nova, se houver) ou apagar.
class _StickerEdit {
  final StickerDTO sticker;
  final File? image;
  final bool delete;

  const _StickerEdit(this.sticker, {this.image, this.delete = false});
}

class _StickerSheet extends StatefulWidget {
  final StickerDTO sticker;

  const _StickerSheet({required this.sticker});

  @override
  State<_StickerSheet> createState() => _StickerSheetState();
}

class _StickerSheetState extends State<_StickerSheet> {
  late final _name = TextEditingController(text: widget.sticker.name);
  late final _order = TextEditingController(text: '${widget.sticker.order}');
  File? _image;
  bool _removed = false;

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNew = widget.sticker.id.isEmpty;
    final valid = _name.text.trim().isNotEmpty;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(AppSizes.s20, 0, AppSizes.s20, AppSizes.s20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isNew ? l10n.albumAdminAddSticker : l10n.albumAdminEditSticker(widget.sticker.number),
              style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
            ),
            const SizedBox(height: AppSizes.s16),
            Center(
              child: CirclePhotoPicker(
                file: _image,
                currentUrl: _removed ? '' : widget.sticker.imageUrl,
                addLabel: l10n.albumAdminPhoto,
                emptyIcon: Icons.person_outline_rounded,
                size: AppSizes.s100,
                onPicked: (file) => setState(() => _image = file),
                onRemove: () => setState(() {
                  _image = null;
                  _removed = true;
                }),
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            TextField(
              controller: _name,
              maxLength: 30,
              onChanged: (_) => setState(() {}),
              decoration: arenaInputDecoration(label: l10n.albumAdminStickerName, icon: Icons.badge_outlined),
            ),
            TextField(
              controller: _order,
              keyboardType: TextInputType.number,
              decoration: arenaInputDecoration(label: l10n.albumAdminStickerOrder, icon: Icons.format_list_numbered),
            ),
            const SizedBox(height: AppSizes.s20),
            ArenaButton.primary(
              title: l10n.commonSave,
              function: valid
                  ? () => Navigator.pop(
                        context,
                        _StickerEdit(
                          widget.sticker.copyWith(
                            name: _name.text.trim(),
                            order: int.tryParse(_order.text.trim()) ?? widget.sticker.order,
                            imageUrl: _removed && _image == null ? '' : null,
                          ),
                          image: _image,
                        ),
                      )
                  : null,
            ),
            if (!isNew)
              TextButton(
                onPressed: () => Navigator.pop(context, _StickerEdit(widget.sticker, delete: true)),
                child: Text(l10n.commonDelete, style: AppTypography.label(color: AppColors.danger)),
              ),
          ],
        ),
      ),
    );
  }
}
