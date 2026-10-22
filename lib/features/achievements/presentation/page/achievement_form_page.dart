import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievement_form_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_icons.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Admin: cadastro/edição de conquista, com a prévia da medalha no topo.
class AchievementFormPage extends StatefulWidget {
  const AchievementFormPage({super.key});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  late final AchievementFormCubit _cubit = BlocProvider.of<AchievementFormCubit>(context);
  late final TextEditingController _title = TextEditingController(text: _cubit.state.draft.title);
  late final TextEditingController _description = TextEditingController(text: _cubit.state.draft.description);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AchievementFormCubit, AchievementFormState>(
      listener: (context, state) {
        if (state.saved) {
          showSnackBar(context: context, message: l10n.achievementSaved);
          Navigator.pop(context);
        } else if (state.errorMessage != null) {
          showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
        }
      },
      builder: (context, state) {
        final draft = state.draft;
        final metric = draft.metric ?? AchievementMetric.votes;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              state.isNew ? l10n.achievementsNew : l10n.achievementsEdit,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  children: [
                    // Prévia.
                    Center(
                      child: Column(
                        children: [
                          MedalBadge(tier: draft.tier, icon: draft.icon, unlocked: true, size: AppSizes.s100),
                          const SizedBox(height: AppSizes.s8),
                          Text(
                            draft.title.isEmpty ? l10n.achievementPreview : draft.title,
                            style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                          ),
                          Text(
                            '${achievementTierLabel(l10n, draft.tier)} · ${l10n.achievementsPoints(draft.points)}',
                            style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.s20),
                    ArenaTextField(
                      controller: _title,
                      labelText: l10n.achievementFieldTitle,
                      errorText: () => state.missingTitle ? l10n.achievementTitleRequired : null,
                      onChaged: (value) => _cubit.edit((d) => d.copyWith(title: value)),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    ArenaTextField(
                      controller: _description,
                      labelText: l10n.achievementFieldDescription,
                      maxLines: 3,
                      onChaged: (value) => _cubit.edit((d) => d.copyWith(description: value)),
                    ),
                    _Label(l10n.achievementFieldCategory),
                    _Chips(
                      children: [
                        for (final category in AchievementCategory.values)
                          ArenaChoiceChip(
                            label: achievementCategoryLabel(l10n, category),
                            selected: draft.category == category,
                            onTap: () => _cubit.edit((d) => d.copyWith(category: category)),
                          ),
                      ],
                    ),
                    _Label(l10n.achievementFieldTier),
                    _Chips(
                      children: [
                        for (final tier in AchievementTier.values)
                          ArenaChoiceChip(
                            label: achievementTierLabel(l10n, tier),
                            selected: draft.tier == tier,
                            onTap: () => _cubit.edit((d) => d.copyWith(tier: tier)),
                          ),
                      ],
                    ),
                    _Label(l10n.achievementFieldIcon),
                    Wrap(
                      spacing: AppSizes.s8,
                      runSpacing: AppSizes.s8,
                      children: [
                        for (final entry in achievementIcons.entries)
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _cubit.edit((d) => d.copyWith(icon: entry.key)),
                            child: Container(
                              width: AppSizes.s44,
                              height: AppSizes.s44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: draft.icon == entry.key ? AppColors.primary : AppColors.surface,
                                border: Border.all(color: AppColors.greyLight),
                              ),
                              child: Icon(
                                entry.value,
                                size: AppSizes.s22,
                                color: draft.icon == entry.key ? AppColors.white : AppColors.primaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    _Label(l10n.achievementFieldMetric),
                    ArenaCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AchievementMetric>(
                          isExpanded: true,
                          value: metric,
                          items: [
                            for (final option in AchievementMetric.values)
                              DropdownMenuItem(value: option, child: Text(achievementMetricLabel(l10n, option))),
                          ],
                          onChanged: (value) {
                            if (value != null) _cubit.edit((d) => d.copyWith(metric: value));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s12),
                    if (!metric.isBoolean)
                      _Stepper(
                        label: l10n.achievementFieldGoal,
                        value: draft.goal,
                        onChanged: (value) => _cubit.edit((d) => d.copyWith(goal: value.clamp(1, 100000))),
                      ),
                    _Stepper(
                      label: l10n.achievementFieldPoints,
                      value: draft.points,
                      step: 5,
                      onChanged: (value) => _cubit.edit((d) => d.copyWith(points: value.clamp(0, 10000))),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.achievementFieldSecret, style: AppTypography.body()),
                      value: draft.secret,
                      onChanged: (value) => _cubit.edit((d) => d.copyWith(secret: value)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.achievementFieldActive, style: AppTypography.body()),
                      value: draft.active,
                      onChanged: (value) => _cubit.edit((d) => d.copyWith(active: value)),
                    ),
                  ],
                ),
              ),
              ArenaSubmitBar(title: l10n.achievementSave, loading: state.saving, onPressed: _cubit.save),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSizes.s20, bottom: AppSizes.s8),
        child: Text(text, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
      );
}

class _Chips extends StatelessWidget {
  final List<Widget> children;

  const _Chips({required this.children});

  @override
  Widget build(BuildContext context) => Wrap(spacing: AppSizes.s8, runSpacing: AppSizes.s8, children: children);
}

/// Número com − e +.
class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  const _Stepper({required this.label, required this.value, required this.onChanged, this.step = 1});

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
      child: Row(
        children: [
          Expanded(
            child:
                Text(label, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
          ),
          IconButton.filledTonal(onPressed: () => onChanged(value - step), icon: const Icon(Icons.remove_rounded)),
          SizedBox(
            width: AppSizes.s64,
            child: Text('$value',
                textAlign: TextAlign.center, style: AppTypography.title().copyWith(fontSize: AppSizes.s20)),
          ),
          IconButton.filledTonal(onPressed: () => onChanged(value + step), icon: const Icon(Icons.add_rounded)),
        ],
      ),
    );
  }
}
