import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_scoreboard.dart';
import 'package:arena_soccer/utils/components/team_picker_sheet.dart';
import 'package:arena_soccer/features/news/presentation/widgets/today_matches_strip.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Publica um card de gol no feed: região, atalho com os jogos de hoje,
/// placar com escudos e − / +, prévia ao vivo do card e confirmação antes de
/// publicar. Opcionalmente grava o placar na partida de hoje. A tela fica
/// aberta depois de publicar, para o admin atualizar o placar de novo.
/// Com [initial] (card de gol tocado no feed), começa com os times, o placar e
/// a região daquele card.
class GoalNotificationPage extends StatefulWidget {
  final NewsDTO? initial;

  const GoalNotificationPage({super.key, this.initial});

  @override
  State<GoalNotificationPage> createState() => _GoalNotificationPageState();
}

class _GoalNotificationPageState extends State<GoalNotificationPage> {
  late final GoalNotificationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<GoalNotificationCubit>(context);
    final region = BlocProvider.of<RegionCubit>(context).state;
    final initial = widget.initial;
    _cubit.load(
      initialRegion: (initial != null && initial.region.isNotEmpty) ? initial.region : region.selectedRegion,
      season: region.selectedSeason,
      initial: initial,
    );
  }

  Future<void> _pickTeam(GoalFormData form, {required bool home}) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showTeamPickerSheet(
      context,
      title: home ? l10n.goalHome : l10n.goalAway,
      teams: form.teams,
      selected: home ? form.homeTeam : form.awayTeam,
    );
    if (picked == null) return;
    home ? _cubit.selectHomeTeam(picked) : _cubit.selectAwayTeam(picked);
  }

  Future<void> _confirmAndSubmit(GoalFormData form) async {
    if (!form.canSubmit) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.goalConfirmTitle),
        content: Text(
          l10n.goalConfirmMessage(form.homeTeam!, form.homeGoals, form.awayGoals, form.awayTeam!),
          style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.goalPublish),
          ),
        ],
      ),
    );
    if (confirmed == true) _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<GoalNotificationCubit, GoalNotificationState>(
      listener: (context, state) {
        if (state is SuccessGoalNotificationState) {
          showSnackBar(context: context, message: state.matchUpdated ? l10n.goalMatchUpdated : l10n.newsGoalCreated);
        }
        if (state is PartialGoalNotificationState) {
          showSnackBar(context: context, message: l10n.goalMatchUpdateFailed, isSuccess: false);
        }
        if (state is ErrorGoalNotificationState) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final form = state.form;
        final linked = form.linkedMatch;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.maybePop(context)),
            titleSpacing: 0,
            title: Text(
              l10n.newsGoalTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          bottomNavigationBar: ArenaSubmitBar(
            title: l10n.goalPublish,
            loading: state is SubmittingGoalNotificationState,
            onPressed: () => _confirmAndSubmit(form),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
            children: [
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
              const SizedBox(height: AppSizes.s20),
              if (form.todayMatches.isNotEmpty) ...[
                _Label(l10n.goalTodayMatches, hint: l10n.goalTodayMatchesHint),
                TodayMatchesStrip(matches: form.todayMatches, selected: linked, onPick: _cubit.pickMatch),
                const SizedBox(height: AppSizes.s20),
              ],
              _Label(l10n.goalScoreboard),
              GoalScoreboard(
                maxGoals: GoalFormData.maxGoals,
                errorText: form.sameTeam ? l10n.goalSameTeam : null,
                home: GoalSide(
                  label: l10n.goalHome,
                  team: form.homeTeam,
                  crest: form.crestOf(form.homeTeam),
                  goals: form.homeGoals,
                  onPickTeam: () => _pickTeam(form, home: true),
                  onIncrement: _cubit.incrementHome,
                  onDecrement: _cubit.decrementHome,
                ),
                away: GoalSide(
                  label: l10n.goalAway,
                  team: form.awayTeam,
                  crest: form.crestOf(form.awayTeam),
                  goals: form.awayGoals,
                  onPickTeam: () => _pickTeam(form, home: false),
                  onIncrement: _cubit.incrementAway,
                  onDecrement: _cubit.decrementAway,
                ),
              ),
              if (linked != null) ...[
                const SizedBox(height: AppSizes.s12),
                _UpdateMatchSwitch(
                  title: l10n.goalUpdateMatch,
                  hint: l10n.goalUpdateMatchHint,
                  value: form.updateMatch,
                  onChanged: _cubit.toggleUpdateMatch,
                ),
              ],
              const SizedBox(height: AppSizes.s24),
              if (form.canSubmit) ...[
                _Label(l10n.goalPreview),
                GoalCard(
                  news: NewsDTO(
                    tag: NewsDTO.goalTag,
                    homeTeam: form.homeTeam!,
                    awayTeam: form.awayTeam!,
                    homeGoals: '${form.homeGoals}',
                    awayGoals: '${form.awayGoals}',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String? hint;

  const _Label(this.text, {this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, 0, AppSizes.s4, AppSizes.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            style: AppTypography.label(color: AppColors.textSecondary)
                .copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
          ),
          if (hint != null) Text(hint!, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}

class _UpdateMatchSwitch extends StatelessWidget {
  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _UpdateMatchSwitch({required this.title, required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s10, AppSizes.s8, AppSizes.s10),
          child: Row(
            children: [
              const Icon(Icons.scoreboard_outlined, color: AppColors.primaryDark),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                    Text(hint, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
