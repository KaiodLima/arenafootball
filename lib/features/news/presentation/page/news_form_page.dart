import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_album_grid.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_cover_picker.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/visible_switch.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cadastro/edição de notícia: capa no topo, seções de conteúdo, álbum e
/// publicação (região, vínculo com um destaque, link e visibilidade) e o
/// botão fixo embaixo. Com [news], edita a notícia existente. Sair com
/// alterações pede confirmação.
class NewsFormPage extends StatefulWidget {
  final NewsDTO? news;

  /// Destaque pré-selecionado (nova notícia aberta a partir do destaque).
  final String? tag;

  const NewsFormPage({super.key, this.news, this.tag});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  static const int _titleMaxLength = 120;

  late final NewsFormCubit _cubit;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  final _scrollController = ScrollController();
  final _titleKey = GlobalKey();

  /// Erros só aparecem depois da primeira tentativa de salvar.
  bool _showErrors = false;

  /// Liberado após salvar, para o pop não pedir confirmação.
  bool _saved = false;

  bool get _isEditing => widget.news != null;

  @override
  void initState() {
    super.initState();
    final news = widget.news;
    _titleController = TextEditingController(text: news?.title);
    _descriptionController = TextEditingController(text: news?.description);
    _linkController = TextEditingController(text: news?.link);
    _cubit = BlocProvider.of<NewsFormCubit>(context);
    _cubit.load(
      news: news,
      initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion,
      tag: widget.tag ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (picked.isNotEmpty) _cubit.addAlbumPhotos(picked.map((file) => File(file.path)).toList());
  }

  void _submit(NewsFormData form) {
    if (form.titleError == NewsTitleError.required) {
      setState(() => _showErrors = true);
      final titleContext = _titleKey.currentContext;
      if (titleContext != null) {
        Scrollable.ensureVisible(titleContext, duration: const Duration(milliseconds: 300), alignment: 0.2);
      }
      return;
    }
    FocusScope.of(context).unfocus();
    _cubit.submit();
  }

  String? _titleError(NewsFormData form, AppLocalizations l10n) {
    final error = form.titleError;
    if (error == NewsTitleError.required) return _showErrors ? l10n.newsTitleRequired : null;
    if (error == NewsTitleError.tooShort) return l10n.newsTitleTooShort;
    return null;
  }

  void _showPreview(NewsFormData form, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.newsPreviewTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
              const SizedBox(height: AppSizes.s14),
              NewsCard(
                news: form.toNews().copyWith(date: form.original?.date ?? DateTime.now()),
                imageFile: form.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(AppLocalizations l10n) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newsDiscardTitle),
        content: Text(l10n.newsDiscardMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.newsDiscardKeep)),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.newsDiscardConfirm, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (discard == true && mounted) _closeAfterRebuild();
  }

  /// Libera o pop e fecha no frame seguinte: o `PopScope` só aceita depois
  /// de reconstruir com `canPop` verdadeiro.
  void _closeAfterRebuild() {
    setState(() => _saved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<NewsFormCubit, NewsFormState>(
      listener: (context, state) {
        if (state is SuccessNewsFormState) {
          showSnackBar(context: context, message: _isEditing ? l10n.newsUpdated : l10n.newsCreated);
          _closeAfterRebuild();
        }
        if (state is ErrorNewsFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final submitting = state is SubmittingNewsFormState;

        return PopScope(
          canPop: _saved || !form.isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !submitting) _confirmDiscard(l10n);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              surfaceTintColor: AppColors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
              titleSpacing: 0,
              title: Text(
                _isEditing ? l10n.newsEditTitle : l10n.newsCreateTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => _showPreview(form, l10n),
                  style: TextButton.styleFrom(foregroundColor: AppColors.white),
                  icon: const Icon(Icons.visibility_outlined, size: AppSizes.s20),
                  label: Text(l10n.newsPreview),
                ),
                const SizedBox(width: AppSizes.s4),
              ],
            ),
            bottomNavigationBar: ArenaSubmitBar(
              title: _isEditing ? l10n.newsSave : l10n.newsPublish,
              loading: submitting,
              onPressed: () => _submit(form),
            ),
            body: ListView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
              children: [
                NewsCoverPicker(
                  file: form.cover,
                  currentUrl: form.currentCoverUrl,
                  onPicked: _cubit.setCover,
                  onRemove: _cubit.clearCover,
                ),
                const SizedBox(height: AppSizes.s20),
                FormSection(
                  title: l10n.newsSectionContent,
                  child: Column(
                    children: [
                      TextField(
                        key: _titleKey,
                        controller: _titleController,
                        onChanged: _cubit.changeTitle,
                        maxLength: _titleMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                        decoration: arenaInputDecoration(
                          label: l10n.newsTitleLabel,
                          errorText: _titleError(form, l10n),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s6),
                      TextField(
                        controller: _descriptionController,
                        onChanged: _cubit.changeDescription,
                        minLines: 4,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTypography.body(),
                        // Multilinha: o rótulo fica no topo, não no meio da caixa.
                        decoration:
                            arenaInputDecoration(label: l10n.newsDescriptionLabel).copyWith(alignLabelWithHint: true),
                      ),
                    ],
                  ),
                ),
                FormSection(
                  title: l10n.newsSectionAlbum,
                  trailing: l10n.newsAlbumCount(form.albumCount),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.newsAlbumHint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                      const SizedBox(height: AppSizes.s12),
                      NewsAlbumGrid(
                        savedUrls: form.keptImages,
                        newFiles: form.album,
                        onRemoveSaved: _cubit.removeKeptImage,
                        onRemoveNew: _cubit.removeAlbumPhoto,
                        onAdd: _addPhotos,
                      ),
                    ],
                  ),
                ),
                FormSection(
                  title: l10n.newsSectionPublish,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FieldLabel(l10n.newsRegion),
                      Wrap(
                        spacing: AppSizes.s8,
                        runSpacing: AppSizes.s8,
                        children: [
                          for (final region in form.regions)
                            ArenaChoiceChip(
                              label: region,
                              icon: Icons.place_outlined,
                              selected: region == form.selectedRegion,
                              onTap: () => _cubit.selectRegion(region),
                            ),
                        ],
                      ),
                      if (!form.isAd) ...[
                        const SizedBox(height: AppSizes.s20),
                        _FieldLabel(l10n.newsHighlight, hint: l10n.newsHighlightHint),
                        _HighlightChips(
                          highlights: form.highlights,
                          selected: form.tag,
                          noneLabel: l10n.newsHighlightNone,
                          onSelected: _cubit.selectHighlight,
                        ),
                      ],
                      const SizedBox(height: AppSizes.s20),
                      TextField(
                        controller: _linkController,
                        onChanged: _cubit.changeLink,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        style: AppTypography.body(),
                        decoration: arenaInputDecoration(
                          label: l10n.newsLinkLabel,
                          hintText: l10n.newsLinkHint,
                          icon: Icons.link_rounded,
                        ),
                      ),
                      const SizedBox(height: AppSizes.s12),
                      VisibleSwitch(
                        label: l10n.newsVisibleLabel,
                        hint: form.isVisible ? l10n.newsVisibleOnHint : l10n.newsVisibleHint,
                        value: form.isVisible,
                        onChanged: _cubit.changeVisible,
                      ),
                    ],
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final String? hint;

  const _FieldLabel(this.label, {this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
          if (hint != null) ...[
            const SizedBox(height: AppSizes.s2),
            Text(hint!, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
          ],
        ],
      ),
    );
  }
}

/// "Nenhum" + um chip por destaque. A tag atual entra mesmo que o destaque
/// não esteja mais visível, para não se perder ao editar.
class _HighlightChips extends StatelessWidget {
  final List<String> highlights;
  final String selected;
  final String noneLabel;
  final ValueChanged<String?> onSelected;

  const _HighlightChips({
    required this.highlights,
    required this.selected,
    required this.noneLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      if (selected.isNotEmpty && !highlights.contains(selected)) selected,
      ...highlights,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          ArenaChoiceChip(label: noneLabel, selected: selected.isEmpty, onTap: () => onSelected(null)),
          for (final title in options) ...[
            const SizedBox(width: AppSizes.s8),
            ArenaChoiceChip(
              label: title,
              icon: Icons.auto_awesome_outlined,
              selected: title == selected,
              onTap: () => onSelected(title),
            ),
          ],
        ],
      ),
    );
  }
}
