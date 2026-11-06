
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_report_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/booking_icon.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/player_grid_sheet.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_action_pad.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_game_info.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_header.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_lineup.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_save_bar.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_report/report_timeline.dart';
import 'package:arena_soccer/features/players/presentation/widgets/quick_player_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';
import 'package:arena_soccer/utils/components/arena_text_field.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/delay_match_sheet.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';

/// Súmula da partida (admin), no molde dos "match centers" (FotMob,
/// SofaScore): cabeçalho com as cores dos times, placar, status e as etapas
/// do jogo; painel de lançamento por time (Gol, Amarelo, Vermelho → grade de
/// atletas com o minuto do relógio); abas Lances (linha do tempo), Escalação
/// e Jogo; e a barra flutuante "N mudanças · Salvar".
class MatchReportPage extends StatelessWidget {
  final String? homeCrest;
  final String? awayCrest;
  final Color? homeColor;
  final Color? awayColor;

  const MatchReportPage({super.key, this.homeCrest, this.awayCrest, this.homeColor, this.awayColor});

  Color get _home => homeColor ?? AppColors.primary;

  /// Visitante sem cor (ou com a mesma do mandante): laranja, para os lados
  /// não se confundirem.
  Color get _away => awayColor != null && awayColor != homeColor ? awayColor! : AppColors.teamOrange;

  Future<void> _close(BuildContext context, MatchReportState state) async {
    if (!state.dirty) {
      Navigator.pop(context);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showArenaConfirm(
      context,
      title: l10n.matchReportDiscardTitle,
      message: l10n.matchReportDiscardMessage,
      confirmLabel: l10n.matchReportDiscard,
      icon: Icons.edit_off_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (discard && context.mounted) Navigator.pop(context);
  }

  /// Painel: abre a grade de atletas do lado e lança o gol ou o cartão.
  Future<void> _launch(BuildContext context, MatchReportState state, PadAction action) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<MatchReportCubit>(context);
    final match = state.match!;
    final team = action.side == MatchSide.home ? match.homeTeam : match.awayTeam;
    final booking = action.booking;
    final picked = await showPlayerGridSheet(
      context,
      title: booking == null
          ? l10n.reportGoalOf(team)
          : '${booking == BookingType.yellow ? l10n.matchReportYellow : l10n.matchReportRed} · $team',
      icon: booking == null
          ? const Icon(Icons.sports_soccer_rounded, color: AppColors.primary, size: AppSizes.s28)
          : BookingIcon(type: booking, size: AppSizes.s28),
      color: action.side == MatchSide.home ? _home : _away,
      squad: state.squadOf(action.side),
      lineup: match.lineup.of(action.side),
      minute: MatchReport.suggestedMinute(match, DateTime.now()),
      goal: booking == null,
    );
    if (picked == null) return;
    if (booking == null) {
      cubit.addGoal(action.side, scorer: picked.player, assistant: picked.assistant, minute: picked.minute);
    } else if (picked.player != null) {
      cubit.addBooking(action.side, player: picked.player!, type: booking, minute: picked.minute);
    }
  }

  /// Toque num lance: editar (gol) ou apagar.
  Future<void> _eventMenu(BuildContext context, MatchReportState state, ReportEvent event) async {
    final l10n = AppLocalizations.of(context);
    final cubit = BlocProvider.of<MatchReportCubit>(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.isGoal)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.reportEditEvent),
                onTap: () => Navigator.pop(sheet, 'edit'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              title: Text(l10n.reportDeleteEvent, style: AppTypography.label(color: AppColors.danger)),
              onTap: () => Navigator.pop(sheet, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    if (choice == 'delete') {
      event.isGoal ? cubit.removeGoal(event.id) : cubit.removeBooking(event.id);
      return;
    }
    final goal = event.goal!;
    final match = state.match!;
    final team = goal.side == MatchSide.home ? match.homeTeam : match.awayTeam;
    final picked = await showPlayerGridSheet(
      context,
      title: l10n.reportGoalOf(team),
      icon: const Icon(Icons.sports_soccer_rounded, color: AppColors.primary, size: AppSizes.s28),
      color: goal.side == MatchSide.home ? _home : _away,
      squad: state.squadOf(goal.side),
      lineup: match.lineup.of(goal.side),
      minute: goal.minute,
      goal: true,
    );
    if (picked != null) {
      cubit.updateGoal(goal.id, scorer: picked.player, assistant: picked.assistant, minute: picked.minute);
    }
  }

  Future<void> _editNumber(BuildContext context, MatchSide side, LineupEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: entry.number?.toString() ?? '');
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.matchReportShirtNumber(entry.playerName),
      confirmLabel: l10n.commonSave,
      icon: Icons.tag_rounded,
      tone: ArenaAlertTone.primary,
      content: ArenaTextField(controller: controller, keyboardType: TextInputType.number, autofocus: true, hintText: '10'),
    );
    if (confirmed && context.mounted) {
      BlocProvider.of<MatchReportCubit>(context).setNumber(side, entry.playerId, int.tryParse(controller.text.trim()));
    }
    controller.dispose();
  }

  Future<void> _addPlayer(BuildContext context, MatchSide side) async {
    final l10n = AppLocalizations.of(context);
    final result = await showQuickPlayerSheet(
      context,
      title: l10n.matchReportAddPlayer,
      hint: l10n.matchReportAddPlayerHint,
      confirmLabel: l10n.matchReportAdd,
    );
    if (result == null || !context.mounted) return;
    await BlocProvider.of<MatchReportCubit>(context)
        .addPlayer(side, name: result.name, position: result.position, photo: result.photo);
  }

  String _eventLabel(AppLocalizations l10n, ReportEvent event) {
    final minute = event.minute == null ? '' : "${event.minute}' ";
    final goal = event.goal;
    if (goal != null) return '⚽ $minute${goal.hasScorer ? goal.scorerName : l10n.reportGoalNoScorer}';
    final booking = event.booking!;
    return '${booking.type == BookingType.yellow ? '🟨' : '🟥'} $minute${booking.playerName}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<MatchReportCubit, MatchReportState>(
      listener: (context, state) {
        final cubit = BlocProvider.of<MatchReportCubit>(context);
        final error = state.errorMessage;
        if (error != null) showSnackBar(context: context, message: error, isSuccess: false);
        switch (state.notice) {
          case MatchReportNotice.eventAdded:
            final event = state.lastEvent;
            if (event != null) {
              showSnackBar(
                context: context,
                message: _eventLabel(l10n, event),
                actionLabel: l10n.reportUndo,
                onAction: cubit.undoLast,
                durationSeconds: 4,
              );
            }
          case MatchReportNotice.saved:
            final cards = state.publishedCards;
            showSnackBar(
              context: context,
              message: cards < 0
                  ? l10n.matchGoalsSavedCardsFailed
                  : cards > 0
                      ? l10n.matchReportSavedWithCards(cards)
                      : l10n.matchReportSaved,
              isSuccess: cards >= 0,
            );
          case MatchReportNotice.playerAdded:
            showSnackBar(context: context, message: l10n.matchReportPlayerAdded);
          case MatchReportNotice.phaseChanged:
          case null:
            break;
        }
      },
      builder: (context, state) {
        final match = state.match;
        if (match == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final cubit = BlocProvider.of<MatchReportCubit>(context);
        return PopScope(
          canPop: !state.dirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _close(context, state);
          },
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.white,
                surfaceTintColor: AppColors.transparent,
                elevation: 0,
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => _close(context, state),
                ),
                title: Text(
                  l10n.matchReportTitle,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s18),
                ),
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: ReportHeader(
                      match: match,
                      homeCrest: homeCrest,
                      awayCrest: awayCrest,
                      homeColor: _home,
                      awayColor: _away,
                      busy: state.busy,
                      onPhase: cubit.setPhase,
                      onDelay: () => showDelayMatchSheet(
                        context,
                        match: match,
                        canStartNow: canStartMatchNow(match, MatchCardStatus.of(match, DateTime.now())),
                        onDelay: cubit.delay,
                        onStartNow: () => cubit.setPhase(MatchPhase.start),
                        onPause: () => cubit.setPhase(MatchPhase.wait),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ReportActionPad(
                      homeTeam: match.homeTeam,
                      awayTeam: match.awayTeam,
                      homeColor: _home,
                      awayColor: _away,
                      onAction: (action) => _launch(context, state, action),
                    ),
                  ),
                  SliverPersistentHeader(pinned: true, delegate: _TabsHeader(l10n)),
                ],
                body: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s8, AppSizes.s12, AppSizes.s120),
                      children: [
                        ReportTimeline(
                          events: state.timeline,
                          duration: match.durationMinutes,
                          homeColor: _home,
                          awayColor: _away,
                          onTap: (event) => _eventMenu(context, state, event),
                        ),
                      ],
                    ),
                    ReportLineup(
                      state: state,
                      homeCrest: homeCrest,
                      awayCrest: awayCrest,
                      homeColor: _home,
                      awayColor: _away,
                      onRole: cubit.setRole,
                      onNumber: (side, entry) => _editNumber(context, side, entry),
                      onAddPlayer: (side) => _addPlayer(context, side),
                    ),
                    ReportGameInfo(
                      match: match,
                      busy: state.busy,
                      onChanged: cubit.setInfo,
                      onToggleVoting: cubit.toggleVoting,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: state.dirty
                  ? ReportSaveBar(
                      changes: state.changeCount,
                      newGoals: state.newGoals,
                      publishCards: state.publishCards,
                      saving: state.saving,
                      onPublishCards: cubit.togglePublishCards,
                      onSave: cubit.save,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

/// Abas fixas no topo ao rolar.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  final AppLocalizations l10n;

  _TabsHeader(this.l10n);

  @override
  double get minExtent => AppSizes.s48;

  @override
  double get maxExtent => AppSizes.s48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.background,
      child: TabBar(
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.label().copyWith(fontSize: AppSizes.s14, fontWeight: FontWeight.w800),
        tabs: [
          Tab(text: l10n.matchReportTabEvents),
          Tab(text: l10n.matchReportTabLineup),
          Tab(text: l10n.matchReportTabGame),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsHeader old) => old.l10n != l10n;
}

/// Cadastro rápido do atleta: nome, posição e foto (opcional).
