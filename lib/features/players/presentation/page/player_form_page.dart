import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_dropdown_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cadastro de jogador (admin). A foto é enviada depois, na tela do elenco.
class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  late final PlayerFormCubit _cubit;
  final _nameController = TextEditingController();
  final _goalsController = TextEditingController();
  final _assistsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PlayerFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalsController.dispose();
    _assistsController.dispose();
    super.dispose();
  }

  void _submit(PlayerFormData form, AppLocalizations l10n) {
    switch (form.error) {
      case PlayerFormError.name:
        showSnackBar(context: context, message: l10n.playersNameRequired, isSuccess: false);
      case PlayerFormError.team:
        showSnackBar(context: context, message: l10n.playersTeamRequired, isSuccess: false);
      case null:
        _cubit.submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playersFormTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<PlayerFormCubit, PlayerFormState>(
        listener: (context, state) {
          if (state is SuccessPlayerFormState) {
            _nameController.clear();
            _goalsController.clear();
            _assistsController.clear();
            showSnackBar(context: context, message: l10n.playersCreated);
          }
          if (state is ErrorPlayerFormState) {
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
                  labelText: l10n.playersNameLabel,
                  controller: _nameController,
                  onChaged: _cubit.changeName,
                  icon: const Icon(Icons.account_box_outlined, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                Row(
                  children: [
                    Expanded(
                      child: ArenaTextField(
                        labelText: l10n.playersGoalsLabel,
                        controller: _goalsController,
                        onChaged: _cubit.changeGoals,
                        keyboardType: TextInputType.number,
                        icon: const Icon(Icons.sports_soccer_outlined, color: AppColors.primary, size: AppSizes.s24),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s14),
                    Expanded(
                      child: ArenaTextField(
                        labelText: l10n.playersAssistsLabel,
                        controller: _assistsController,
                        onChaged: _cubit.changeAssists,
                        keyboardType: TextInputType.number,
                        icon: const Icon(Icons.account_box_outlined, color: AppColors.primary, size: AppSizes.s24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s8),
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                Text(l10n.playersTeamLabel, style: const TextStyle(fontSize: AppSizes.s16)),
                ArenaDropdownField(value: form.selectedTeam, items: form.teams, onChanged: _cubit.selectTeam),
                const SizedBox(height: AppSizes.s16),
                ArenaButton.primary(
                  title: l10n.playersRegisterButton,
                  isLoading: state is SubmittingPlayerFormState,
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
