import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_switch_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/picked_image_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cadastro de destaque (carrossel do topo da home).
class HighlightFormPage extends StatelessWidget {
  const HighlightFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<HighlightFormCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.highlightFormTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<HighlightFormCubit, HighlightFormState>(
        listener: (context, state) {
          if (state is SuccessHighlightFormState) {
            showSnackBar(context: context, message: l10n.highlightCreated);
            Navigator.pop(context);
          }
          if (state is ErrorHighlightFormState) {
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
                const SizedBox(height: AppSizes.s12),
                Image.asset(AppImages.logo, height: AppSizes.s100),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.highlightTitleLabel,
                  onChaged: cubit.changeTitle,
                  icon: const Icon(Icons.account_box_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                PickedImageField(file: form.image, onPicked: cubit.setImage),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.highlightLinkLabel,
                  onChaged: cubit.changeLink,
                  keyboardType: TextInputType.url,
                  icon: const Icon(Icons.link, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s8),
                ArenaSwitchField(
                  label: l10n.highlightVisibleLabel,
                  value: form.isVisible,
                  onChanged: cubit.changeVisible,
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaButton.primary(
                  title: l10n.highlightRegisterButton,
                  isLoading: state is SubmittingHighlightFormState,
                  function: () {
                    if (!form.isTitleValid) {
                      showSnackBar(context: context, message: l10n.highlightTitleRequired, isSuccess: false);
                      return;
                    }
                    cubit.submit();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
