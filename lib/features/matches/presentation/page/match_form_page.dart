import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_dropdown_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_images.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Cadastro de partida (admin): região, mandante, visitante, data, hora e
/// local. Placar começa 0 x 0 e a votação fechada.
class MatchFormPage extends StatefulWidget {
  const MatchFormPage({super.key});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  late final MatchFormCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<MatchFormCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  void _submit(MatchFormData form, AppLocalizations l10n) {
    if (!form.canSubmit) {
      showSnackBar(context: context, message: l10n.matchesFieldsRequired, isSuccess: false);
      return;
    }
    _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchesFormTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<MatchFormCubit, MatchFormState>(
        listener: (context, state) {
          if (state is SuccessMatchFormState) showSnackBar(context: context, message: l10n.matchesCreated);
          if (state is ErrorMatchFormState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
        },
        builder: (context, state) {
          final form = state.form;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.s12),
                Image.asset(AppImages.logo, height: AppSizes.s100),
                const SizedBox(height: AppSizes.s32),
                Text(l10n.matchesRegionLabel, style: const TextStyle(fontSize: AppSizes.s18)),
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s16),
                _Label(icon: Icons.shield, text: l10n.matchesHomeTeamLabel),
                ArenaDropdownField(
                  value: form.homeTeam,
                  items: form.teams,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectHomeTeam,
                ),
                const SizedBox(height: AppSizes.s16),
                _Label(icon: Icons.shield_outlined, text: l10n.matchesAwayTeamLabel),
                ArenaDropdownField(
                  value: form.awayTeam,
                  items: form.teams,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectAwayTeam,
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.matchesDateLabel,
                  onChaged: _cubit.changeDate,
                  keyboardType: TextInputType.datetime,
                  icon: const Icon(Icons.calendar_month, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.matchesTimeLabel,
                  onChaged: _cubit.changeTime,
                  keyboardType: TextInputType.datetime,
                  icon: const Icon(Icons.lock_clock, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaTextField(
                  labelText: l10n.matchesVenueLabel,
                  onChaged: _cubit.changeVenue,
                  icon: const Icon(Icons.stadium, color: AppColors.primary, size: AppSizes.s24),
                ),
                const SizedBox(height: AppSizes.s16),
                ArenaButton.primary(
                  title: l10n.matchesRegisterButton,
                  isLoading: state is SubmittingMatchFormState,
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

class _Label extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Label({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: AppSizes.s24),
        const SizedBox(width: AppSizes.s8),
        Text(text, style: const TextStyle(fontSize: AppSizes.s18)),
      ],
    );
  }
}
