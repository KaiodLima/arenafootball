import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_dropdown_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/picked_image_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cadastro de time (admin): grava o time e a linha dele na classificação.
class TeamFormPage extends StatefulWidget {
  const TeamFormPage({super.key});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  late final TeamFormCubit _cubit;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<TeamFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(TeamFormData form, AppLocalizations l10n) {
    if (!form.isNameValid) {
      showSnackBar(context: context, message: l10n.teamsNameRequired, isSuccess: false);
      return;
    }
    _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teamsFormTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<TeamFormCubit, TeamFormState>(
        listener: (context, state) {
          if (state is SuccessTeamFormState) {
            _nameController.clear();
            _descriptionController.clear();
            showSnackBar(context: context, message: l10n.teamsCreated);
          }
          if (state is ErrorTeamFormState) {
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
                Row(
                  children: [
                    const Icon(Icons.numbers, color: AppColors.primary, size: AppSizes.s24),
                    Text(form.nextNumber?.toString() ?? '', style: const TextStyle(fontSize: AppSizes.s18)),
                  ],
                ),
                const SizedBox(height: AppSizes.s16),
                Text(l10n.teamsRegionLabel, style: const TextStyle(fontSize: AppSizes.s18)),
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.teamsNameLabel,
                  controller: _nameController,
                  onChaged: _cubit.changeName,
                  keyboardType: TextInputType.name,
                  icon: const Icon(Icons.shield, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.teamsDescriptionLabel,
                  controller: _descriptionController,
                  onChaged: _cubit.changeDescription,
                  icon: const Icon(Icons.description_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                PickedImageField(file: form.crest, onPicked: _cubit.setCrest),
                const SizedBox(height: AppSizes.s32),
                ArenaButton.primary(
                  title: l10n.teamsRegisterButton,
                  isLoading: state is SubmittingTeamFormState,
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
