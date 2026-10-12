import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/core/utils/web_link.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlight_avatar.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/circle_photo_picker.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/visible_switch.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Cadastro de destaque (carrossel de círculos do topo da home): foto,
/// título curto (a tag que agrupa as notícias), link opcional e visibilidade,
/// com a prévia do carrossel ao vivo.
class HighlightFormPage extends StatefulWidget {
  /// Destaque a editar (nulo = novo).
  final HighlightDTO? highlight;

  const HighlightFormPage({super.key, this.highlight});

  @override
  State<HighlightFormPage> createState() => _HighlightFormPageState();
}

class _HighlightFormPageState extends State<HighlightFormPage> {
  late final HighlightFormCubit _cubit;
  late final TextEditingController _titleController;
  late final TextEditingController _linkController;

  bool get _isEditing => widget.highlight != null;

  /// Erros de título só aparecem depois da primeira tentativa (exceto o
  /// duplicado, que avisa na hora).
  bool _showErrors = false;

  /// Liberado após salvar/descartar, para o pop não pedir confirmação.
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.highlight?.title);
    _linkController = TextEditingController(text: widget.highlight?.link);
    _cubit = BlocProvider.of<HighlightFormCubit>(context);
    _cubit.load(highlight: widget.highlight);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit(HighlightFormData form) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!form.canSubmit) {
      setState(() => _showErrors = true);
      return;
    }
    _cubit.submit();
  }

  String? _titleError(HighlightFormData form, AppLocalizations l10n) {
    switch (form.titleError) {
      case HighlightTitleError.duplicate:
        return l10n.highlightDuplicate;
      case HighlightTitleError.required:
        return _showErrors ? l10n.highlightTitleRequired : null;
      case HighlightTitleError.tooShort:
        return _showErrors ? l10n.highlightTitleTooShort : null;
      case null:
        return null;
    }
  }

  Future<void> _testLink(HighlightFormData form, AppLocalizations l10n) async {
    final uri = Uri.tryParse(normalizeWebLink(form.link));
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) showSnackBar(context: context, message: l10n.adLinkInvalid, isSuccess: false);
  }

  Future<void> _confirmDiscard(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
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
    FocusManager.instance.primaryFocus?.unfocus();
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

    return BlocConsumer<HighlightFormCubit, HighlightFormState>(
      listener: (context, state) {
        if (state is SuccessHighlightFormState) {
          showSnackBar(context: context, message: _isEditing ? l10n.highlightUpdated : l10n.highlightCreated);
          _closeAfterRebuild();
        }
        if (state is ErrorHighlightFormState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final submitting = state is SubmittingHighlightFormState;

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
                _isEditing ? l10n.highlightEditTitle : l10n.highlightCreateTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: ArenaSubmitBar(
              title: _isEditing ? l10n.newsSave : l10n.highlightPublish,
              loading: submitting,
              onPressed: () => _submit(form),
            ),
            body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s24),
              children: [
                Center(
                  child: CirclePhotoPicker(
                    file: form.image,
                    currentUrl: form.currentImageUrl,
                    addLabel: l10n.highlightPhotoAdd,
                    onPicked: _cubit.setImage,
                    onRemove: _cubit.clearImage,
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                Text(
                  l10n.highlightPhotoHint,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s16),
                FormSection(
                  title: l10n.highlightPreview,
                  child: _CarouselPreview(form: form),
                ),
                FormSection(
                  title: l10n.highlightSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        onChanged: _cubit.changeTitle,
                        maxLength: HighlightFormData.titleMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                        decoration: arenaInputDecoration(
                          label: l10n.highlightTitleLabel,
                          hintText: l10n.highlightTitleHint,
                          icon: Icons.auto_awesome_outlined,
                          errorText: _titleError(form, l10n),
                        ),
                      ),
                      if (form.isRenamed && form.titleError == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.s8),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: AppSizes.s16, color: AppColors.primaryDark),
                              const SizedBox(width: AppSizes.s6),
                              Expanded(
                                child: Text(
                                  l10n.highlightRenameHint(form.original!.title),
                                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSizes.s6),
                      TextField(
                        controller: _linkController,
                        onChanged: _cubit.changeLink,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        style: AppTypography.body(),
                        decoration: arenaInputDecoration(
                          label: l10n.highlightLinkLabel,
                          hintText: l10n.newsLinkHint,
                          icon: Icons.link_rounded,
                          errorText: form.linkInvalid ? l10n.adLinkInvalid : null,
                        ).copyWith(
                          suffixIcon: form.link.trim().isEmpty || form.linkInvalid
                              ? null
                              : TextButton(onPressed: () => _testLink(form, l10n), child: Text(l10n.adTestLink)),
                        ),
                      ),
                    ],
                  ),
                ),
                FormSection(
                  title: l10n.newsSectionPublish,
                  child: VisibleSwitch(
                    label: l10n.highlightVisibleLabel,
                    hint: form.isVisible ? l10n.highlightVisibleOnHint : l10n.highlightVisibleHint,
                    value: form.isVisible,
                    onChanged: _cubit.changeVisible,
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

/// O carrossel como ficará: os destaques visíveis e, por último, o novo
/// (destacado), atualizado ao vivo com a foto e o título.
class _CarouselPreview extends StatelessWidget {
  final HighlightFormData form;

  const _CarouselPreview({required this.form});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = form.title.trim().isEmpty ? l10n.highlightTitleLabel : form.title.trim();
    final current = Opacity(
      opacity: form.isVisible ? 1 : 0.4,
      child: HighlightAvatar(imageUrl: form.currentImageUrl, imageFile: form.image, title: title),
    );
    final editingId = form.original?.id;
    final others = form.existing.where((item) => item.isVisible && item.id != editingId).toList();
    final position = editingId == null
        ? others.length
        : form.existing.where((item) => item.isVisible || item.id == editingId).toList().indexWhere(
              (item) => item.id == editingId,
            );
    final insertAt = position < 0 ? others.length : position.clamp(0, others.length);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final item in others.take(insertAt)) HighlightAvatar(imageUrl: item.imageUrl, title: item.title),
          current,
          for (final item in others.skip(insertAt)) HighlightAvatar(imageUrl: item.imageUrl, title: item.title),
        ],
      ),
    );
  }
}
