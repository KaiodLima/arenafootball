import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Publica um card de publicidade no feed (notícia com tag "publicidade").
class AdFormPage extends StatefulWidget {
  const AdFormPage({super.key});

  @override
  State<AdFormPage> createState() => _AdFormPageState();
}

class _AdFormPageState extends State<AdFormPage> {
  late final NewsFormCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<NewsFormCubit>(context);
    _cubit.load(
      initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion,
      tag: NewsDTO.adTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newsAdTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<NewsFormCubit, NewsFormState>(
        listener: (context, state) {
          if (state is SuccessNewsFormState) {
            showSnackBar(context: context, message: l10n.newsAdCreated);
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
                Text(l10n.newsRegionLabel, style: const TextStyle(fontSize: AppSizes.s18)),
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s24),
                ArenaTextField(
                  labelText: l10n.newsTitleLabel,
                  onChaged: _cubit.changeTitle,
                  icon: const Icon(Icons.text_fields_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                PickedImageField(file: form.cover, onPicked: _cubit.setCover),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.newsDescriptionLabel,
                  onChaged: _cubit.changeDescription,
                  maxLines: 5,
                  icon: const Icon(Icons.text_fields_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.newsLinkLabel,
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
                  title: l10n.newsPublishButton,
                  isLoading: state is SubmittingNewsFormState,
                  function: _cubit.submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
