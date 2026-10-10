import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_dropdown_field.dart';
import 'package:arena_soccer/utils/components/arena_switch_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/picked_image_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cadastro de notícia. Com [news], edita a notícia existente.
class NewsFormPage extends StatefulWidget {
  final NewsDTO? news;

  const NewsFormPage({super.key, this.news});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  late final NewsFormCubit _cubit;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  late final TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    final news = widget.news;
    _titleController = TextEditingController(text: news?.title);
    _descriptionController = TextEditingController(text: news?.description);
    _tagController = TextEditingController(text: news?.tag);
    _linkController = TextEditingController(text: news?.link);
    _cubit = BlocProvider.of<NewsFormCubit>(context);
    _cubit.load(news: news, initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _attachPhotos() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) _cubit.addAlbumPhotos(picked.map((file) => File(file.path)).toList());
  }

  void _submit(NewsFormData form, AppLocalizations l10n) {
    if (form.titleError == NewsTitleError.required) {
      showSnackBar(context: context, message: l10n.newsTitleRequired, isSuccess: false);
      return;
    }
    _cubit.submit();
  }

  String? _titleErrorText(NewsFormData form, AppLocalizations l10n) {
    if (form.title.isEmpty) return null;
    return form.titleError == NewsTitleError.tooShort ? l10n.newsTitleTooShort : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.news != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.newsEditTitle : l10n.newsCreateTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<NewsFormCubit, NewsFormState>(
        listener: (context, state) {
          if (state is SuccessNewsFormState) {
            showSnackBar(context: context, message: isEditing ? l10n.newsUpdated : l10n.newsCreated);
            Navigator.pop(context);
          }
          if (state is ErrorNewsFormState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          final form = state.form;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s12),
                if (!isEditing) Image.asset(AppImages.logo, height: AppSizes.s100),
                const SizedBox(height: AppSizes.s16),
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.s8),
                    child: Row(
                      children: [
                        const Icon(Icons.numbers, color: AppColors.primary, size: AppSizes.s24),
                        const SizedBox(width: AppSizes.s16),
                        Expanded(child: Text(widget.news!.id, style: const TextStyle(fontSize: AppSizes.s18))),
                      ],
                    ),
                  ),
                ArenaTextField(
                  labelText: l10n.newsTitleLabel,
                  controller: _titleController,
                  onChaged: _cubit.changeTitle,
                  errorText: () => _titleErrorText(form, l10n),
                  icon: Icon(
                    Icons.text_fields_outlined,
                    size: AppSizes.s24,
                    color: _titleErrorText(form, l10n) == null ? AppColors.primary : AppColors.danger,
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                PickedImageField(
                  file: form.cover,
                  currentUrl: widget.news?.imageUrl,
                  onPicked: _cubit.setCover,
                ),
                if (!isEditing) ...[
                  const SizedBox(height: AppSizes.s8),
                  ArenaButton.primary(title: l10n.newsAttachPhotos, function: _attachPhotos),
                  const SizedBox(height: AppSizes.s8),
                  _AlbumPreview(files: form.album, onRemove: _cubit.removeAlbumPhoto),
                ],
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.newsDescriptionLabel,
                  controller: _descriptionController,
                  onChaged: _cubit.changeDescription,
                  maxLines: 5,
                  icon: const Icon(Icons.text_fields_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.newsTagLabel,
                  controller: _tagController,
                  onChaged: _cubit.changeTag,
                  icon: const Icon(Icons.label, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.newsLinkLabel,
                  controller: _linkController,
                  onChaged: _cubit.changeLink,
                  keyboardType: TextInputType.url,
                  icon: const Icon(Icons.link, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaSwitchField(
                  label: l10n.newsVisibleLabel,
                  value: form.isVisible,
                  onChanged: _cubit.changeVisible,
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaButton.primary(
                  title: isEditing ? l10n.newsUpdateButton : l10n.newsRegisterButton,
                  isLoading: state is SubmittingNewsFormState,
                  function: () => _submit(form, l10n),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Miniaturas das fotos do álbum; o "x" remove a foto.
class _AlbumPreview extends StatelessWidget {
  final List<File> files;
  final ValueChanged<int> onRemove;

  const _AlbumPreview({required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: files.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSizes.s8),
        itemBuilder: (context, index) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              child: Image.file(files[index], width: size.width * 0.3, height: size.height * 0.2, fit: BoxFit.cover),
            ),
            Positioned(
              top: AppSizes.s4,
              right: AppSizes.s4,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: const CircleAvatar(
                  radius: AppSizes.s12,
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.close, size: AppSizes.s16, color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
