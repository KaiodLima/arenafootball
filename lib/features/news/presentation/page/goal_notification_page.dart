import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_dropdown_field.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Publica um card de gol no feed. A tela fica aberta depois de publicar,
/// para o admin atualizar o placar de novo.
class GoalNotificationPage extends StatefulWidget {
  const GoalNotificationPage({super.key});

  @override
  State<GoalNotificationPage> createState() => _GoalNotificationPageState();
}

class _GoalNotificationPageState extends State<GoalNotificationPage> {
  late final GoalNotificationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<GoalNotificationCubit>(context);
    _cubit.load(initialRegion: BlocProvider.of<RegionCubit>(context).state.selectedRegion);
  }

  void _submit(GoalFormData form, AppLocalizations l10n) {
    if (!form.hasTeams) {
      showSnackBar(context: context, message: l10n.newsGoalTeamsRequired, isSuccess: false);
      return;
    }
    _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const labelStyle = TextStyle(fontSize: AppSizes.s18);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newsGoalTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<GoalNotificationCubit, GoalNotificationState>(
        listener: (context, state) {
          if (state is SuccessGoalNotificationState) {
            showSnackBar(context: context, message: l10n.newsGoalCreated);
          }
          if (state is ErrorGoalNotificationState) {
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
                Text(l10n.newsRegionLabel, style: labelStyle),
                ArenaDropdownField(
                  value: form.selectedRegion,
                  items: form.regions,
                  icon: Icons.change_circle_outlined,
                  onChanged: _cubit.selectRegion,
                ),
                const SizedBox(height: AppSizes.s8),
                Text(l10n.newsHomeTeamLabel, style: labelStyle),
                ArenaDropdownField(value: form.homeTeam, items: form.teams, onChanged: _cubit.selectHomeTeam),
                const SizedBox(height: AppSizes.s8),
                Text(l10n.newsAwayTeamLabel, style: labelStyle),
                ArenaDropdownField(value: form.awayTeam, items: form.teams, onChanged: _cubit.selectAwayTeam),
                const SizedBox(height: AppSizes.s24),
                Text(l10n.newsScoreLabel, style: labelStyle),
                const SizedBox(height: AppSizes.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppSizes.s80,
                      child: ArenaTextField(keyboardType: TextInputType.number, onChaged: _cubit.changeHomeGoals),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                      child: Text('X', style: TextStyle(fontSize: AppSizes.s24)),
                    ),
                    SizedBox(
                      width: AppSizes.s80,
                      child: ArenaTextField(keyboardType: TextInputType.number, onChaged: _cubit.changeAwayGoals),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s24),
                ArenaButton.primary(
                  title: l10n.newsPublishButton,
                  isLoading: state is SubmittingGoalNotificationState,
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
