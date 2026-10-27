import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/relative_time.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/send_manual_push_usecase.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_cubit.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_card.dart';
import 'package:arena_soccer/utils/components/arena_choice_chip.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_input_decoration.dart';
import 'package:arena_soccer/utils/components/arena_segmented_pill.dart';
import 'package:arena_soccer/utils/components/form_section.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Painel de notificações push (admin): quais ações enviam, o histórico de
/// envios e o aviso manual.
class NotificationsPanelPage extends StatefulWidget {
  const NotificationsPanelPage({super.key});

  @override
  State<NotificationsPanelPage> createState() => _NotificationsPanelPageState();
}

class _NotificationsPanelPageState extends State<NotificationsPanelPage> {
  late final NotificationsPanelCubit _cubit;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<NotificationsPanelCubit>(context)..load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _confirmSend(NotificationsPanelState state, AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final audience = state.notice.region.isEmpty ? l10n.pushAllRegions : state.notice.region;
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.pushSendConfirmTitle,
      message: l10n.pushSendConfirmMessage(audience),
      confirmLabel: l10n.pushSend,
      icon: Icons.campaign_outlined,
      tone: ArenaAlertTone.primary,
    );
    if (confirmed) await _cubit.sendNotice();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(
          l10n.pushPanelTitle,
          style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
        ),
      ),
      body: BlocConsumer<NotificationsPanelCubit, NotificationsPanelState>(
        listener: (context, state) {
          if (state is ErrorNotificationsPanelState) {
            showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
          }
          if (state is NoticeSentNotificationsPanelState) {
            _titleController.clear();
            _bodyController.clear();
            showSnackBar(context: context, message: l10n.pushSent);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s8),
                child: ArenaSegmentedPill(
                  segments: [
                    ArenaSegment(label: l10n.pushTabActions, icon: Icons.tune_rounded),
                    ArenaSegment(label: l10n.pushTabHistory, icon: Icons.history_rounded),
                    ArenaSegment(label: l10n.pushTabSend, icon: Icons.campaign_outlined),
                  ],
                  selectedIndex: _tab,
                  onChanged: (index) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _tab = index);
                  },
                ),
              ),
              Expanded(
                child: switch (_tab) {
                  0 => _ActionsTab(state: state, onToggle: _cubit.toggle),
                  1 => _HistoryTab(state: state),
                  _ => _SendTab(
                      state: state,
                      titleController: _titleController,
                      bodyController: _bodyController,
                      onTitle: _cubit.changeNoticeTitle,
                      onBody: _cubit.changeNoticeBody,
                      onRegion: _cubit.changeNoticeRegion,
                      onSend: () => _confirmSend(state, l10n),
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ícone, nome, descrição (quando dispara e para quem) de cada ação.
({IconData icon, String name, String description}) _describe(PushAction action, AppLocalizations l10n) {
  return switch (action) {
    PushAction.goal => (
        icon: Icons.sports_soccer_rounded,
        name: l10n.pushActionGoal,
        description: l10n.pushActionGoalHint
      ),
    PushAction.news => (icon: Icons.article_outlined, name: l10n.pushActionNews, description: l10n.pushActionNewsHint),
    PushAction.match => (
        icon: Icons.scoreboard_outlined,
        name: l10n.pushActionMatch,
        description: l10n.pushActionMatchHint
      ),
    PushAction.votingOpen => (
        icon: Icons.how_to_vote_outlined,
        name: l10n.pushActionVotingOpen,
        description: l10n.pushActionVotingOpenHint
      ),
    PushAction.votingClosed => (
        icon: Icons.emoji_events_outlined,
        name: l10n.pushActionVotingClosed,
        description: l10n.pushActionVotingClosedHint
      ),
    PushAction.dailyGame => (
        icon: Icons.today_outlined,
        name: l10n.pushActionDailyGame,
        description: l10n.pushActionDailyGameHint
      ),
    PushAction.notice => (
        icon: Icons.campaign_outlined,
        name: l10n.pushActionNotice,
        description: l10n.pushActionNoticeHint
      ),
    PushAction.playerRequest => (
        icon: Icons.how_to_reg_outlined,
        name: l10n.pushActionPlayerRequest,
        description: l10n.pushActionPlayerRequestHint
      ),
    PushAction.playerRequestAnswer => (
        icon: Icons.mark_email_read_outlined,
        name: l10n.pushActionPlayerRequestAnswer,
        description: l10n.pushActionPlayerRequestAnswerHint
      ),
    PushAction.teamRequest => (
        icon: Icons.add_moderator_outlined,
        name: l10n.pushActionTeamRequest,
        description: l10n.pushActionTeamRequestHint
      ),
    PushAction.teamRequestAnswer => (
        icon: Icons.verified_outlined,
        name: l10n.pushActionTeamRequestAnswer,
        description: l10n.pushActionTeamRequestAnswerHint
      ),
    PushAction.partnerRequest => (
        icon: Icons.handshake_outlined,
        name: l10n.pushActionPartnerRequest,
        description: l10n.pushActionPartnerRequestHint
      ),
    PushAction.partnerRequestAnswer => (
        icon: Icons.verified_user_outlined,
        name: l10n.pushActionPartnerRequestAnswer,
        description: l10n.pushActionPartnerRequestAnswerHint
      ),
    PushAction.partnerNews => (
        icon: Icons.pending_actions_rounded,
        name: l10n.pushActionPartnerNews,
        description: l10n.pushActionPartnerNewsHint
      ),
    PushAction.partnerNewsAnswer => (
        icon: Icons.fact_check_outlined,
        name: l10n.pushActionPartnerNewsAnswer,
        description: l10n.pushActionPartnerNewsAnswerHint
      ),
    PushAction.achievement => (
        icon: Icons.military_tech_outlined,
        name: l10n.pushActionAchievement,
        description: l10n.pushActionAchievementHint
      ),
  };
}

class _ActionsTab extends StatelessWidget {
  final NotificationsPanelState state;
  final void Function(PushAction action, bool enabled) onToggle;

  const _ActionsTab({required this.state, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!state.configLoaded) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.s12),
          child: Text(l10n.pushActionsIntro, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
        ),
        for (final action in PushAction.values)
          Builder(builder: (context) {
            final info = _describe(action, l10n);
            final enabled = state.isEnabled(action);
            return ArenaCard(
              margin: const EdgeInsets.only(bottom: AppSizes.s8),
              padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s10, AppSizes.s4, AppSizes.s10),
              onTap: () => onToggle(action, !enabled),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.s40,
                    height: AppSizes.s40,
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.primarySoft : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info.icon,
                        size: AppSizes.s20, color: enabled ? AppColors.primaryDark : AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info.name,
                            style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                        const SizedBox(height: AppSizes.s2),
                        Text(info.description, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) => onToggle(action, value),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final NotificationsPanelState state;

  const _HistoryTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!state.historyLoaded) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (state.history.isEmpty) {
      return ArenaEmptyState(message: l10n.pushHistoryEmpty, icon: Icons.notifications_none_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s24),
      itemCount: state.history.length,
      itemBuilder: (context, index) => _LogCard(log: state.history[index]),
    );
  }
}

class _LogCard extends StatelessWidget {
  final PushLogDTO log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final action = PushAction.fromKey(log.type);
    final info = action == null ? null : _describe(action, l10n);
    final (statusLabel, statusColor) = switch (log.status) {
      PushLogStatus.sent => (l10n.pushStatusSent, AppColors.primaryDark),
      PushLogStatus.disabled => (l10n.pushStatusDisabled, AppColors.textSecondary),
      PushLogStatus.error => (l10n.pushStatusError, AppColors.danger),
    };
    final audience = log.target == 'todos'
        ? l10n.pushAllRegions
        : log.region.isNotEmpty
            ? log.region
            : l10n.pushAudienceTeams;
    final date = log.date;

    return ArenaCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s8),
      padding: const EdgeInsets.all(AppSizes.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.s36,
            height: AppSizes.s36,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(info?.icon ?? Icons.notifications_outlined, size: AppSizes.s18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        info?.name ?? log.type,
                        style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.s8),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.label(color: statusColor).copyWith(fontSize: AppSizes.s12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s4),
                Text(log.title,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                if (log.body.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(log.body, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
                ],
                const SizedBox(height: AppSizes.s6),
                Text(
                  [audience, if (date != null) RelativeTime.format(date, l10n)].join(' · '),
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                if (log.status == PushLogStatus.error && log.error.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    log.error,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle(color: AppColors.danger).copyWith(fontSize: AppSizes.s12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendTab extends StatelessWidget {
  final NotificationsPanelState state;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final ValueChanged<String> onTitle;
  final ValueChanged<String> onBody;
  final ValueChanged<String> onRegion;
  final VoidCallback onSend;

  const _SendTab({
    required this.state,
    required this.titleController,
    required this.bodyController,
    required this.onTitle,
    required this.onBody,
    required this.onRegion,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notice = state.notice;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s24),
      children: [
        FormSection(
          title: l10n.pushNoticeSection,
          child: Column(
            children: [
              TextField(
                controller: titleController,
                onChanged: onTitle,
                maxLength: SendManualPushUseCase.titleMax,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                decoration: arenaInputDecoration(label: l10n.pushNoticeTitle, icon: Icons.title_rounded),
              ),
              const SizedBox(height: AppSizes.s6),
              TextField(
                controller: bodyController,
                onChanged: onBody,
                maxLength: SendManualPushUseCase.bodyMax,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.body(),
                decoration: arenaInputDecoration(label: l10n.pushNoticeBody).copyWith(alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        FormSection(
          title: l10n.pushNoticeAudience,
          child: Wrap(
            spacing: AppSizes.s8,
            runSpacing: AppSizes.s8,
            children: [
              ArenaChoiceChip(
                label: l10n.pushAllRegions,
                icon: Icons.public_rounded,
                selected: notice.region.isEmpty,
                onTap: () => onRegion(''),
              ),
              for (final region in state.regions)
                ArenaChoiceChip(
                  label: region,
                  icon: Icons.place_outlined,
                  selected: notice.region == region,
                  onTap: () => onRegion(region),
                ),
            ],
          ),
        ),
        FormSection(
          title: l10n.pushNoticePreview,
          child: _NotificationPreview(
            title: notice.title.trim().isEmpty ? l10n.pushNoticeTitle : notice.title.trim(),
            body: notice.body.trim().isEmpty ? l10n.pushNoticeBody : notice.body.trim(),
          ),
        ),
        const SizedBox(height: AppSizes.s8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(AppSizes.s48 + AppSizes.s4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.fieldRadius)),
          ),
          onPressed: notice.canSend && !state.sending ? onSend : null,
          icon: state.sending
              ? const SizedBox(
                  width: AppSizes.s18,
                  height: AppSizes.s18,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(l10n.pushSend),
        ),
        const SizedBox(height: AppSizes.s8),
        Text(
          l10n.pushNoticeHint,
          textAlign: TextAlign.center,
          style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
        ),
      ],
    );
  }
}

/// Como a notificação aparece no Android (aproximação).
class _NotificationPreview extends StatelessWidget {
  final String title;
  final String body;

  const _NotificationPreview({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.s28,
            height: AppSizes.s28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.sports_soccer_rounded, size: AppSizes.s16, color: AppColors.white),
          ),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arena Football · ${l10n.timeJustNow}',
                  style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                ),
                const SizedBox(height: AppSizes.s2),
                Text(title, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
                const SizedBox(height: AppSizes.s2),
                Text(body, style: AppTypography.body().copyWith(fontSize: AppSizes.s14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
