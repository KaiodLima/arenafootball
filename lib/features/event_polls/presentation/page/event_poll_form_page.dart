import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll_draft.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_form_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_select_tile.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/image_source_sheet.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Formulário do evento de votação (admin): região, título, descrição, capa,
/// encerramento, parcial e as opções (2 a 8) com foto, detalhe e o link do
/// vídeo. Com votos, as opções travam.
class EventPollFormPage extends StatefulWidget {
  final NewsDTO? editing;

  const EventPollFormPage({super.key, this.editing});

  @override
  State<EventPollFormPage> createState() => _EventPollFormPageState();
}

class _EventPollFormPageState extends State<EventPollFormPage> {
  late final EventPollFormCubit _cubit;
  late final TextEditingController _title;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<EventPollFormCubit>(context);
    _cubit.start(editing: widget.editing, region: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
    _title = TextEditingController(text: widget.editing?.title ?? '');
    _description = TextEditingController(text: widget.editing?.description ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _errorText(AppLocalizations l10n, EventPollFormState state, EventPollDraftError field, [int option = -1]) {
    if (!state.submitted) return null;
    final problem = state.draft.validate(_cubit.now(), checkOptions: !state.locked);
    if (problem == null || problem.error != field || (option >= 0 && problem.option != option)) return null;
    return switch (field) {
      EventPollDraftError.title => l10n.eventPollErrorTitle,
      EventPollDraftError.region => l10n.eventPollErrorRegion,
      EventPollDraftError.closesAt => l10n.eventPollErrorClosesAt,
      EventPollDraftError.tooFewOptions => l10n.eventPollErrorFewOptions,
      EventPollDraftError.optionTitle => l10n.eventPollErrorOptionTitle(option + 1),
      EventPollDraftError.optionLink => l10n.eventPollErrorOptionLink(option + 1),
    };
  }

  Future<void> _pickCover() async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 90, maxWidth: 1600);
    if (picked != null) _cubit.setCover(File(picked.path));
  }

  Future<void> _pickDate(EventPollDraft draft) async {
    final now = _cubit.now();
    final current = draft.closesAt ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    _cubit.update(draft.copyWith(
      closesAt: DateTime(picked.year, picked.month, picked.day, current.hour, current.minute),
    ));
  }

  Future<void> _pickTime(EventPollDraft draft) async {
    final current = draft.closesAt ?? _cubit.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    _cubit.update(draft.copyWith(
      closesAt: DateTime(current.year, current.month, current.day, picked.hour, picked.minute),
    ));
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final uid = BlocProvider.of<SessionCubit>(context).state.user?.id ?? '';
    _cubit.save(authorId: uid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final regions = context.watch<RegionCubit>().state;
    final editing = widget.editing != null;

    return BlocConsumer<EventPollFormCubit, EventPollFormState>(
      listenWhen: (previous, current) => previous.errorSeq != current.errorSeq || (!previous.saved && current.saved),
      listener: (context, state) {
        if (state.saved) {
          showSnackBar(context: context, message: editing ? l10n.eventPollSaved : l10n.eventPollPublished);
          Navigator.pop(context);
          return;
        }
        showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
      },
      builder: (context, state) {
        final draft = state.draft;
        final locale = Localizations.localeOf(context).toLanguageTag();
        final closesAt = draft.closesAt;
        final generalError = _errorText(l10n, state, EventPollDraftError.tooFewOptions);
        final closesError = _errorText(l10n, state, EventPollDraftError.closesAt);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              editing ? l10n.eventPollFormTitleEdit : l10n.eventPollFormTitleNew,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          bottomNavigationBar: ArenaSubmitBar(
            title: editing ? l10n.eventPollSaveChanges : l10n.eventPollPublish,
            loading: state.saving,
            onPressed: _save,
          ),
          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
            children: [
              if (!editing) ...[
                Text(l10n.eventPollFormIntro, style: AppTypography.subtitle()),
                const SizedBox(height: AppSizes.s16),
              ],
              FormSection(
                title: l10n.eventPollSectionEvent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RegionSelectTile(
                      label: l10n.registerRegionLabel,
                      region: draft.region,
                      regions: regions.regions,
                      recent: regions.recentRegions,
                      onChanged: (region) => _cubit.update(draft.copyWith(region: region)),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    TextField(
                      key: const ValueKey('event-title'),
                      controller: _title,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => _cubit.update(state.draft.copyWith(title: value)),
                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                      decoration: arenaInputDecoration(
                        label: l10n.eventPollFieldTitle,
                        hintText: l10n.eventPollFieldTitleHint,
                        icon: Icons.emoji_events_outlined,
                        errorText: _errorText(l10n, state, EventPollDraftError.title),
                      ),
                    ),
                    TextField(
                      controller: _description,
                      maxLength: 300,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => _cubit.update(state.draft.copyWith(description: value)),
                      decoration:
                          arenaInputDecoration(label: l10n.eventPollFieldDescription, icon: Icons.notes_rounded),
                    ),
                    _CoverPicker(
                      file: state.cover,
                      url: state.coverUrl,
                      onPick: _pickCover,
                      onRemove: () => _cubit.setCover(null),
                    ),
                  ],
                ),
              ),
              FormSection(
                title: l10n.eventPollSectionVoting,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PickerTile(
                            icon: Icons.event_rounded,
                            label: l10n.eventPollClosesDate,
                            value: closesAt == null ? '—' : DateFormat('dd/MM/yyyy', locale).format(closesAt),
                            onTap: () => _pickDate(draft),
                          ),
                        ),
                        const SizedBox(width: AppSizes.s10),
                        Expanded(
                          child: _PickerTile(
                            icon: Icons.schedule_rounded,
                            label: l10n.eventPollClosesTime,
                            value: closesAt == null ? '—' : DateFormat('HH:mm', locale).format(closesAt),
                            onTap: () => _pickTime(draft),
                          ),
                        ),
                      ],
                    ),
                    if (closesError != null) _ErrorLine(closesError),
                    const SizedBox(height: AppSizes.s8),
                    SwitchListTile.adaptive(
                      key: const ValueKey('event-partial'),
                      contentPadding: EdgeInsets.zero,
                      value: draft.showPartial,
                      activeTrackColor: AppColors.primary,
                      onChanged: (value) => _cubit.update(draft.copyWith(showPartial: value)),
                      title: Text(l10n.eventPollShowPartial, style: AppTypography.label(color: AppColors.textPrimary)),
                      subtitle: Text(l10n.eventPollShowPartialHint,
                          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.eventPollSectionOptions.toUpperCase(),
                        style: AppTypography.label(color: AppColors.textSecondary)
                            .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
                      ),
                    ),
                    Text(
                      '${draft.options.length}/${EventPoll.maxOptions}',
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
              if (state.locked) ...[
                _LockedNotice(text: l10n.eventPollOptionsLocked),
                const SizedBox(height: AppSizes.s10),
              ],
              if (generalError != null) _ErrorLine(generalError),
              for (var i = 0; i < draft.options.length; i++)
                _OptionEditor(
                  key: ValueKey('event-option-editor-${draft.options[i].id}'),
                  option: draft.options[i],
                  index: i,
                  count: draft.options.length,
                  locked: state.locked,
                  titleError: _errorText(l10n, state, EventPollDraftError.optionTitle, i),
                  linkError: _errorText(l10n, state, EventPollDraftError.optionLink, i),
                  onChanged: _cubit.updateOption,
                  onRemove: () => _cubit.removeOption(draft.options[i].id),
                  onMove: (to) => _cubit.moveOption(i, to),
                ),
              if (!state.locked && draft.options.length < EventPoll.maxOptions)
                OutlinedButton.icon(
                  key: const ValueKey('event-add-option'),
                  onPressed: _cubit.addOption,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s14)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.eventPollAddOption),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Uma opção no formulário: foto, título, detalhe e link (controladores
/// próprios, presos ao id: reordenar não embaralha o texto).
class _OptionEditor extends StatefulWidget {
  final EventOptionDraft option;
  final int index;
  final int count;
  final bool locked;
  final String? titleError;
  final String? linkError;
  final ValueChanged<EventOptionDraft> onChanged;
  final VoidCallback onRemove;
  final ValueChanged<int> onMove;

  const _OptionEditor({
    super.key,
    required this.option,
    required this.index,
    required this.count,
    required this.locked,
    required this.titleError,
    required this.linkError,
    required this.onChanged,
    required this.onRemove,
    required this.onMove,
  });

  @override
  State<_OptionEditor> createState() => _OptionEditorState();
}

class _OptionEditorState extends State<_OptionEditor> {
  late final TextEditingController _title = TextEditingController(text: widget.option.title);
  late final TextEditingController _subtitle = TextEditingController(text: widget.option.subtitle);
  late final TextEditingController _link = TextEditingController(text: widget.option.link);

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final option = widget.option;
    final locked = widget.locked;
    final network = SocialLink.of(option.link);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.fromLTRB(AppSizes.s14, AppSizes.s10, AppSizes.s8, AppSizes.s6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppSizes.s20),
                ),
                child: Text(
                  l10n.eventPollOptionLabel(widget.index + 1),
                  style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                ),
              ),
              const Spacer(),
              if (!locked) ...[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.index == 0 ? null : () => widget.onMove(widget.index - 1),
                  icon: const Icon(Icons.arrow_upward_rounded, size: AppSizes.s20),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.index == widget.count - 1 ? null : () => widget.onMove(widget.index + 1),
                  icon: const Icon(Icons.arrow_downward_rounded, size: AppSizes.s20),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.count <= EventPoll.minOptions ? null : widget.onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.s20, color: AppColors.danger),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.s8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IgnorePointer(
                ignoring: locked,
                child: CirclePhotoPicker(
                  file: option.photo,
                  currentUrl: option.imageUrl,
                  addLabel: l10n.eventPollOptionPhoto,
                  size: AppSizes.s64,
                  onPicked: (file) => widget.onChanged(option.copyWith(photo: file)),
                  onRemove: () => widget.onChanged(option.copyWith(clearPhoto: true)),
                ),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      key: ValueKey('event-option-title-${option.id}'),
                      controller: _title,
                      enabled: !locked,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => widget.onChanged(option.copyWith(title: value)),
                      style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                      decoration: arenaInputDecoration(
                        label: l10n.eventPollOptionTitle,
                        hintText: l10n.eventPollOptionTitleHint,
                        errorText: widget.titleError,
                      ),
                    ),
                    TextField(
                      controller: _subtitle,
                      enabled: !locked,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => widget.onChanged(option.copyWith(subtitle: value)),
                      decoration: arenaInputDecoration(
                        label: l10n.eventPollOptionSubtitle,
                        hintText: l10n.eventPollOptionSubtitleHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextField(
            key: ValueKey('event-option-link-${option.id}'),
            controller: _link,
            enabled: !locked,
            keyboardType: TextInputType.url,
            onChanged: (value) => widget.onChanged(option.copyWith(link: value)),
            decoration: arenaInputDecoration(
              label: l10n.eventPollOptionLink,
              hintText: l10n.eventPollOptionLinkHint,
              icon: network == null || network == SocialNetwork.other
                  ? Icons.link_rounded
                  : Icons.play_circle_outline_rounded,
              errorText: widget.linkError,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
        ],
      ),
    );
  }
}

/// Capa do evento (paisagem): a prévia com trocar/remover, ou o botão de adicionar.
class _CoverPicker extends StatelessWidget {
  final File? file;
  final String url;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CoverPicker({required this.file, required this.url, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ImageProvider? image;
    if (file != null) {
      image = FileImage(file!);
    } else if (url.isNotEmpty) {
      image = NetworkImage(url);
    }
    if (image == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.greyLight),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.s14)),
        ),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.eventPollCoverAdd),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.s14),
          child: AspectRatio(aspectRatio: 16 / 7, child: Image(image: image, fit: BoxFit.cover)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onPick, child: Text(l10n.eventPollCoverChange)),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: Text(l10n.eventPollCoverRemove),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.fieldRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s10),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.s20, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                    ),
                    Text(value,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  final String text;

  const _LockedNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.s12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, size: AppSizes.s18, color: AppColors.warning),
          const SizedBox(width: AppSizes.s8),
          Expanded(child: Text(text, style: AppTypography.body().copyWith(fontSize: AppSizes.s14))),
        ],
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String text;

  const _ErrorLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s6, AppSizes.s12, AppSizes.s6),
      child: Text(text, style: AppTypography.body(color: AppColors.danger).copyWith(fontSize: AppSizes.s12)),
    );
  }
}
