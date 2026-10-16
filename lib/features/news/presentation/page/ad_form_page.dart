import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
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
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Cadastro/edição de publicidade (notícia com tag "publicidade"): o banner
/// 2:1 já aparece como no feed, um nome para o admin identificar, o link
/// aberto ao tocar no anúncio, a região e a visibilidade.
class AdFormPage extends StatefulWidget {
  /// Anúncio a editar (nulo = novo).
  final NewsDTO? news;

  const AdFormPage({super.key, this.news});

  @override
  State<AdFormPage> createState() => _AdFormPageState();
}

class _AdFormPageState extends State<AdFormPage> {
  late final NewsFormCubit _cubit;
  late final TextEditingController _nameController;
  late final TextEditingController _linkController;

  /// Liberado após salvar/descartar, para o pop não pedir confirmação.
  bool _saved = false;

  bool get _isEditing => widget.news != null;

  @override
  void initState() {
    super.initState();
    final news = widget.news;
    _nameController = TextEditingController(text: news?.title);
    _linkController = TextEditingController(text: news?.link);
    _cubit = BlocProvider.of<NewsFormCubit>(context);
    _cubit.load(
      news: news,
      initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion,
      tag: NewsDTO.adTag,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit(NewsFormData form, AppLocalizations l10n) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!form.hasCover) {
      showSnackBar(context: context, message: l10n.adImageRequired, isSuccess: false);
      return;
    }
    if (form.linkInvalid) {
      showSnackBar(context: context, message: l10n.adLinkInvalid, isSuccess: false);
      return;
    }
    _cubit.submit();
  }

  Future<void> _testLink(NewsFormData form, AppLocalizations l10n) async {
    final uri = Uri.tryParse(form.normalizedLink);
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) showSnackBar(context: context, message: l10n.adLinkInvalid, isSuccess: false);
  }

  Future<void> _confirmDiscard(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final discard = await showArenaConfirm(
      context,
      title: l10n.newsDiscardTitle,
      message: l10n.newsDiscardMessage,
      confirmLabel: l10n.newsDiscardConfirm,
      cancelLabel: l10n.newsDiscardKeep,
      icon: Icons.delete_sweep_outlined,
      tone: ArenaAlertTone.danger,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (discard && mounted) _closeAfterRebuild();
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
          showSnackBar(context: context, message: _isEditing ? l10n.adUpdated : l10n.newsAdCreated);
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
                _isEditing ? l10n.adEditTitle : l10n.adCreateTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
              ),
            ),
            bottomNavigationBar: ArenaSubmitBar(
              title: _isEditing ? l10n.newsSave : l10n.adPublish,
              loading: submitting,
              onPressed: () => _submit(form, l10n),
            ),
            body: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
              children: [
                // O banner na proporção do card do feed, com o selo: já é a prévia.
                NewsCoverPicker(
                  file: form.cover,
                  currentUrl: form.currentCoverUrl,
                  onPicked: _cubit.setCover,
                  onRemove: _cubit.clearCover,
                  aspectRatio: 2,
                  addLabel: l10n.adBannerAdd,
                  badge: l10n.newsAdLabel,
                ),
                const SizedBox(height: AppSizes.s8),
                Text(
                  l10n.adBannerHint,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s16),
                FormSection(
                  title: l10n.adSectionAd,
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: _cubit.changeTitle,
                        maxLength: 60,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                        decoration: arenaInputDecoration(
                          label: l10n.adNameLabel,
                          hintText: l10n.adNameHint,
                          icon: Icons.storefront_outlined,
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
                          label: l10n.newsLinkLabel,
                          hintText: l10n.adLinkHint,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.s10),
                        child: Text(
                          l10n.newsRegion,
                          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14),
                        ),
                      ),
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
                      const SizedBox(height: AppSizes.s16),
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
