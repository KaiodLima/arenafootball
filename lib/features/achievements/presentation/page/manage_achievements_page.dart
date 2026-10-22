import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/manage_achievements_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/achievement_labels.dart';
import 'package:arena_soccer/features/achievements/presentation/widgets/medal_badge.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Admin: conquistas cadastradas (ativas e inativas), com ativar/desativar,
/// editar, excluir e criar as sugeridas quando o catálogo está vazio.
class ManageAchievementsPage extends StatelessWidget {
  const ManageAchievementsPage({super.key});

  void _openForm(BuildContext context, {AchievementDTO? achievement}) {
    final cubit = BlocProvider.of<ManageAchievementsCubit>(context);
    Navigator.pushNamed(
      context,
      AppRoutes.achievementFormPage,
      arguments: {'achievement': achievement, 'order': cubit.state.nextOrder},
    );
  }

  Future<void> _delete(BuildContext context, AchievementDTO achievement) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<ManageAchievementsCubit>(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.achievementDeleteConfirm(achievement.title),
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await cubit.delete(achievement, notice: l10n.achievementDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<ManageAchievementsCubit>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.achievementsManageTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.achievementsNew,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<ManageAchievementsCubit, ManageAchievementsState>(
        listener: (context, state) {
          if (state.notice != null) showSnackBar(context: context, message: state.notice!);
          if (state.errorMessage != null) {
            showSnackBar(context: context, message: state.errorMessage!, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (state.achievements.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.s24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ArenaEmptyState(message: l10n.achievementsManageEmpty, icon: Icons.military_tech_outlined),
                  const SizedBox(height: AppSizes.s16),
                  ArenaButton.primary(
                    title: l10n.achievementsCreateSuggested,
                    isLoading: state.working,
                    function: () => cubit.createSuggested(notice: l10n.achievementsSuggestedCreated),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s100),
            itemCount: state.achievements.length,
            itemBuilder: (context, index) {
              final achievement = state.achievements[index];
              final metric = achievement.metric;
              return ArenaCard(
                margin: const EdgeInsets.only(bottom: AppSizes.s10),
                onTap: () => _openForm(context, achievement: achievement),
                padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s4, AppSizes.s10),
                child: Opacity(
                  opacity: achievement.active ? 1 : 0.55,
                  child: Row(
                    children: [
                      MedalBadge(tier: achievement.tier, icon: achievement.icon, unlocked: true, size: AppSizes.s48),
                      const SizedBox(width: AppSizes.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s16),
                            ),
                            Text(
                              [
                                if (metric != null) '${achievementMetricLabel(l10n, metric)} · ${achievement.goal}',
                                '${achievementTierLabel(l10n, achievement.tier)} · ${l10n.achievementsPoints(achievement.points)}',
                                if (!achievement.active) l10n.achievementInactive,
                              ].join('\n'),
                              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: achievement.active,
                        activeThumbColor: AppColors.primary,
                        onChanged: (value) => cubit.setActive(achievement, value),
                      ),
                      CardMenuButton(
                        actions: [
                          CardMenuAction(
                            icon: Icons.edit_outlined,
                            label: l10n.achievementsEdit,
                            onSelected: () => _openForm(context, achievement: achievement),
                          ),
                          CardMenuAction(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.commonDelete,
                            destructive: true,
                            onSelected: () => _delete(context, achievement),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
