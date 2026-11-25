import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_lineup_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_athlete_picker.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_pitch.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_score_sheet.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_top_athletes.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_ranking_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';

/// Arena Fantasy do campeonato: entrar e montar a escalação da rodada aberta
/// (5 atletas no campinho + capitão), até o prazo.
class FantasyLineupPage extends StatefulWidget {
  final ChampionshipDTO championship;

  const FantasyLineupPage({super.key, required this.championship});

  @override
  State<FantasyLineupPage> createState() => _FantasyLineupPageState();
}

class _FantasyLineupPageState extends State<FantasyLineupPage> {
  FantasyLineupCubit get _cubit => context.read<FantasyLineupCubit>();
  final _tourDeadline = GlobalKey();
  final _tourPitch = GlobalKey();
  final _tourCaptain = GlobalKey();
  final _tourSave = GlobalKey();
  bool _tourRequested = false;

  /// Tour da escalação na 1ª visita (com o campinho, a dica e o salvar na tela).
  void _requestTour(FantasyLineupState state) {
    if (_tourRequested) return;
    _tourRequested = true;
    final l10n = AppLocalizations.of(context);
    final captain = FantasySettings.captainLabel(state.config!.captainMultiplier);
    TourService.request(
      context,
      TourIds.fantasyLineup,
      () => [
        TourStep(
          target: _tourDeadline,
          icon: Icons.schedule_rounded,
          title: l10n.tourFantasyLineupDeadlineTitle,
          body: l10n.tourFantasyLineupDeadlineBody,
        ),
        TourStep(
          target: _tourPitch,
          icon: Icons.sports_soccer_rounded,
          title: l10n.tourFantasyLineupPitchTitle,
          body: l10n.tourFantasyLineupPitchBody,
        ),
        TourStep(
          target: _tourCaptain,
          icon: Icons.copyright_rounded,
          title: l10n.tourFantasyLineupCaptainTitle,
          body: l10n.tourFantasyLineupCaptainBody(captain),
        ),
        TourStep(
          target: _tourSave,
          icon: Icons.check_circle_rounded,
          title: l10n.tourFantasyLineupSaveTitle,
          body: l10n.tourFantasyLineupSaveBody,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionCubit>().state.user;
    _cubit.load(widget.championship, uid: user?.id ?? '', name: user?.name ?? '', photoUrl: user?.photoUrl ?? '');
  }

  Future<void> _onSlotTap(FantasyLineupState state, FantasySpot spot) async {
    if (!state.editable || state.showingLast) {
      // Rodada travada (ou o resultado da anterior): o atleta que já jogou
      // abre a pontuação detalhada.
      final lineup = state.showingLast ? state.lastLineup : state.saved;
      final round = state.showingLast ? state.lastRound : state.round;
      final id = lineup?.lineup.idAt(spot);
      if (id == null || round == null || !lineup!.playedIds.contains(id)) return;
      await showFantasyAthleteScore(
        context,
        fantasyId: widget.championship.id,
        round: round.number,
        athleteId: id,
        captain: lineup.lineup.captainId == id,
        athlete: state.athleteById[id],
        // Rodada fechada e apurada: a pontuação fica no cache até reapurar.
        scoringVersion: round.closed ? round.scoringVersion : 0,
      );
      return;
    }
    final current = state.draft.idAt(spot);
    if (current != null) {
      final action = await _slotActions(state, current);
      if (!mounted || action == null) return;
      if (action == _SlotAction.remove) return _cubit.remove(spot);
      if (action == _SlotAction.captain) return _cubit.setCaptain(current);
    }
    if (!mounted) return;
    final picked = await showFantasyAthletePicker(
      context,
      slot: spot.slot,
      athletes: state.athletes,
      lineup: state.draft,
      current: state.draft.idAt(spot),
    );
    if (picked != null && mounted) _cubit.place(spot, picked);
  }

  Future<_SlotAction?> _slotActions(FantasyLineupState state, String athleteId) {
    final l10n = AppLocalizations.of(context);
    final name = state.athleteById[athleteId]?.name ?? '';
    return showModalBottomSheet<_SlotAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
              child: Text(name, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
            ),
            ListTile(
              key: const ValueKey('fantasy-slot-swap'),
              leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryDark),
              title: Text(l10n.fantasySwapAthlete),
              onTap: () => Navigator.pop(context, _SlotAction.swap),
            ),
            if (state.draft.captainId != athleteId)
              ListTile(
                key: const ValueKey('fantasy-slot-captain'),
                leading: const Icon(Icons.copyright_rounded, color: AppColors.gold),
                title: Text(l10n.fantasyMakeCaptain),
                onTap: () => Navigator.pop(context, _SlotAction.captain),
              ),
            ListTile(
              key: const ValueKey('fantasy-slot-remove'),
              leading: const Icon(Icons.person_remove_outlined, color: AppColors.danger),
              title: Text(l10n.fantasyRemoveAthlete),
              onTap: () => Navigator.pop(context, _SlotAction.remove),
            ),
            const SizedBox(height: AppSizes.s8),
          ],
        ),
      ),
    );
  }

  void _openRanking() => Navigator.pushNamed(context, AppRoutes.fantasyRankingPage, arguments: widget.championship);

  void _openRules(FantasyConfigDTO? config) =>
      Navigator.pushNamed(context, AppRoutes.fantasyRulesPage, arguments: config);

  String? _errorText(AppLocalizations l10n, FantasyLineupState state) => switch (state.error) {
        FantasyLineupError.incomplete => l10n.fantasyErrorIncomplete(state.formation.total),
        FantasyLineupError.noCaptain => l10n.fantasyErrorCaptainMissing,
        FantasyLineupError.duplicate => l10n.fantasyErrorDuplicate,
        FantasyLineupError.position => l10n.fantasyErrorPosition,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<FantasyLineupCubit, FantasyLineupState>(
      listenWhen: (previous, current) => current.event != FantasyLineupEvent.none,
      listener: (context, state) => showSnackBar(
        context: context,
        message: switch (state.event) {
          FantasyLineupEvent.joined => l10n.fantasyJoined,
          FantasyLineupEvent.saved => l10n.fantasyLineupSaved,
          _ => state.failure ?? l10n.fantasyLineupSaveError,
        },
        isSuccess: state.event != FantasyLineupEvent.failed,
      ),
      builder: (context, state) {
        final showsLineup = !state.loading && state.editable && !state.showingLast;
        if (showsLineup) _requestTour(state);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.fantasyTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
            actions: [
              IconButton(
                key: const ValueKey('fantasy-open-rules'),
                tooltip: l10n.fantasyRulesTitle,
                icon: const Icon(Icons.menu_book_rounded),
                onPressed: () => _openRules(state.config),
              ),
              IconButton(
                key: const ValueKey('fantasy-open-ranking'),
                tooltip: l10n.fantasyRankingTitle,
                icon: const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
                onPressed: _openRanking,
              ),
            ],
          ),
          bottomNavigationBar: state.editable && !state.showingLast
              ? KeyedSubtree(
                  key: _tourSave,
                  child: ArenaSubmitBar(
                    title: l10n.fantasyConfirmLineup,
                    loading: state.busy,
                    onPressed: () {
                      if (state.canSave) _cubit.save();
                    },
                  ),
                )
              : null,
          body: state.loading ? const Center(child: CircularProgressIndicator()) : _body(context, l10n, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, FantasyLineupState state) {
    final config = state.config!;
    if (!config.active) {
      return ArenaEmptyState(message: l10n.fantasyInactive, icon: Icons.stadium_outlined);
    }
    final error = state.editable ? _errorText(l10n, state) : null;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.s16,
        AppSizes.s16,
        AppSizes.s16,
        state.editable ? AppSizes.s24 : safeBottom(context, AppSizes.s24),
      ),
      children: [
        _Header(championship: widget.championship, state: state, statusKey: _tourDeadline),
        const SizedBox(height: AppSizes.s16),
        // Total geral da conta + atalho para os rankings.
        if (state.joined) ...[
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: ListTile(
              key: const ValueKey('fantasy-my-total'),
              onTap: _openRanking,
              leading: const Icon(Icons.leaderboard_rounded, color: AppColors.primaryDark),
              title: Text(l10n.fantasyMyTotal, style: AppTypography.label(color: AppColors.textSecondary)),
              subtitle: Text(
                l10n.fantasyPointsValue(fantasyPointsLabel(state.participant!.points)),
                style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
              ),
              trailing: Text(l10n.fantasySeeRanking, style: AppTypography.label().copyWith(fontSize: AppSizes.s12)),
            ),
          ),
          const SizedBox(height: AppSizes.s16),
        ],
        if (state.isGuest)
          _Notice(icon: Icons.login_rounded, text: l10n.fantasyGuest)
        else if (!state.joined)
          _JoinCard(
              busy: state.busy, formation: state.formation, onJoin: _cubit.join, onRules: () => _openRules(config))
        else if (state.hasLastResult) ...[
          _RoundSwitch(state: state, onChanged: _cubit.showLast),
          const SizedBox(height: AppSizes.s12),
        ],
        if (state.isGuest || !state.joined)
          const SizedBox.shrink()
        else if (state.showingLast) ...[
          // Resultado da rodada anterior: o parcial/final e os pontos de cada atleta.
          if (state.lastLineup!.points != null) ...[
            _RoundScoreCard(round: state.lastRound!, points: state.lastLineup!.points!),
            const SizedBox(height: AppSizes.s12),
          ],
          FantasyPitch(
            key: const ValueKey('fantasy-last-pitch'),
            lineup: state.lastLineup!.lineup,
            athletes: state.athleteById,
            teams: state.teams,
            points: state.lastLineup!.playedPoints,
            editable: false,
            onSlotTap: (slot) => _onSlotTap(state, slot),
            onCaptainTap: (_) {},
          ),
        ] else if (state.round == null)
          _Notice(icon: Icons.event_busy_rounded, text: l10n.fantasyNoOpenRound)
        else ...[
          if (state.formationChanged && state.editable) ...[
            _Notice(icon: Icons.groups_rounded, text: l10n.fantasyFormationChanged(state.formation.total)),
            const SizedBox(height: AppSizes.s12),
          ],
          if (state.saved?.copied == true && !state.dirty) ...[
            _Notice(icon: Icons.content_copy_rounded, text: l10n.fantasyCopiedLineup),
            const SizedBox(height: AppSizes.s12),
          ],
          if (!state.roundOpen && state.saved?.points != null) ...[
            _RoundScoreCard(round: state.round!, points: state.saved!.points!),
            const SizedBox(height: AppSizes.s12),
          ],
          if (!state.roundOpen) ...[
            state.round!.inProgressAt(state.now)
                ? _Notice(
                    icon: Icons.sports_soccer_rounded,
                    text: l10n.fantasyRoundInProgress(state.round!.number),
                  )
                : _Notice(icon: Icons.lock_rounded, text: l10n.fantasyLockedNotice),
            const SizedBox(height: AppSizes.s12),
          ],
          FantasyPitch(
            key: _tourPitch,
            lineup: state.draft,
            athletes: state.athleteById,
            teams: state.teams,
            points: state.roundOpen ? const {} : (state.saved?.playedPoints ?? const {}),
            editable: state.editable,
            onSlotTap: (slot) => _onSlotTap(state, slot),
            onCaptainTap: _cubit.setCaptain,
          ),
          const SizedBox(height: AppSizes.s12),
          if (state.editable)
            KeyedSubtree(
              key: _tourCaptain,
              child: Text(
                error ?? l10n.fantasyCaptainTip(FantasySettings.captainLabel(config.captainMultiplier)),
                key: const ValueKey('fantasy-lineup-hint'),
                style: AppTypography.label(color: error == null ? AppColors.textSecondary : AppColors.danger)
                    .copyWith(fontSize: AppSizes.s12),
              ),
            ),
          if (state.editable && state.dirty && state.saved != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _cubit.discard,
                icon: const Icon(Icons.undo_rounded),
                label: Text(l10n.fantasyDiscard),
              ),
            ),
        ],
        // Os atletas que mais pontuaram na última rodada fechada.
        if (state.topRound != null) ...[
          const SizedBox(height: AppSizes.s16),
          FantasyTopAthletesCard(
            round: state.topRound!,
            athletes: state.topAthletes,
            onAthleteTap: (athlete) => showFantasyAthleteScore(
              context,
              fantasyId: widget.championship.id,
              round: state.topRound!,
              athleteId: athlete.athleteId,
            ),
            onSeeAll: () => Navigator.pushNamed(
              context,
              AppRoutes.fantasyRankingPage,
              arguments: FantasyRankingArgs(widget.championship, tab: FantasyRankingTab.athletes),
            ),
          ),
        ],
      ],
    );
  }
}

enum _SlotAction { swap, captain, remove }

class _Header extends StatelessWidget {
  final ChampionshipDTO championship;
  final FantasyLineupState state;

  /// Alvo do tour na pílula do prazo.
  final Key? statusKey;

  const _Header({required this.championship, required this.state, this.statusKey});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final round = state.round;
    final status = round == null
        ? l10n.fantasyNoOpenRoundShort
        : state.roundOpen && round.closesAt != null
            ? fantasyDeadlineLabel(l10n, round.closesAt!, state.now)
            : round.inProgressAt(state.now)
                ? l10n.fantasyRoundInProgressShort
                : l10n.fantasyRoundLocked;
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryMedium]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          TeamCrest(imageUrl: championship.imageUrl, size: AppSizes.s48),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  championship.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
                ),
                const SizedBox(height: AppSizes.s2),
                Text(
                  round == null ? l10n.fantasyTitle : l10n.fantasyRoundTitle(round.number),
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
          ),
          KeyedSubtree(
            key: statusKey,
            child: Container(
              key: const ValueKey('fantasy-round-status'),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
              decoration: BoxDecoration(
                color: state.roundOpen ? AppColors.gold : AppColors.whiteMuted,
                borderRadius: BorderRadius.circular(AppSizes.s20),
              ),
              child: Text(
                status,
                style: AppTypography.label(color: state.roundOpen ? AppColors.primaryDark : AppColors.white)
                    .copyWith(fontSize: AppSizes.s12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  final bool busy;
  final FantasyFormation formation;
  final VoidCallback onJoin;
  final VoidCallback onRules;

  const _JoinCard({required this.busy, required this.formation, required this.onJoin, required this.onRules});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fantasyJoinTitle, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
          const SizedBox(height: AppSizes.s6),
          Text(l10n.fantasyJoinText(formation.total), style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
          const SizedBox(height: AppSizes.s16),
          ArenaButton.primary(
            key: const ValueKey('fantasy-join'),
            title: l10n.fantasyJoin,
            isLoading: busy,
            function: onJoin,
          ),
          const SizedBox(height: AppSizes.s8),
          ArenaButton.outlined(
            key: const ValueKey('fantasy-join-rules'),
            title: l10n.fantasyRulesSeeRules,
            function: onRules,
          ),
        ],
      ),
    );
  }
}

/// "Sua pontuação na rodada N": o parcial (ou final) da conta na rodada,
/// gravado pelas functions a cada partida terminada.
/// Seletor no alto da tela: o resultado da rodada anterior (com os pontos)
/// ou a rodada atual (escalar / em andamento).
class _RoundSwitch extends StatelessWidget {
  final FantasyLineupState state;
  final ValueChanged<bool> onChanged;

  const _RoundSwitch({required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = state.lastRound!;
    final points = state.lastLineup!.points;
    final round = state.round;
    final currentLabel = round == null
        ? l10n.fantasyNoOpenRoundShort
        : '${l10n.fantasyRoundTitle(round.number)} · '
            '${state.roundOpen ? l10n.fantasySwitchPick : round.inProgressAt(state.now) ? l10n.fantasyRoundInProgressShort : l10n.fantasyRoundLocked}';
    Widget tab(bool isLast, String label) {
      final selected = state.showingLast == isLast;
      return Expanded(
        child: GestureDetector(
          key: ValueKey(isLast ? 'fantasy-switch-last' : 'fantasy-switch-current'),
          onTap: () => onChanged(isLast),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryDark : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.s12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(color: selected ? AppColors.white : AppColors.textSecondary)
                  .copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          tab(
            true,
            '${l10n.fantasyRoundTitle(last.number)} · ${l10n.fantasySwitchResult}'
            '${points == null ? '' : ' · ${l10n.fantasyCardPoints(fantasyPointsLabel(points))}'}',
          ),
          tab(false, currentLabel),
        ],
      ),
    );
  }
}

class _RoundScoreCard extends StatelessWidget {
  final FantasyRoundDTO round;
  final double points;

  const _RoundScoreCard({required this.round, required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = round.finished
        ? l10n.fantasyRoundFinal
        : l10n.fantasyRoundPartialCount(round.matchesFinished, round.matchIds.length);
    return Container(
      key: const ValueKey('fantasy-round-score'),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryMedium]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.scoreboard_rounded, color: AppColors.gold),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.fantasyRoundScoreTitle(round.number),
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s14)),
                Text(status,
                    style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12)),
              ],
            ),
          ),
          Text(
            fantasyPointsLabel(points),
            style: AppTypography.title(color: AppColors.gold).copyWith(fontSize: AppSizes.s28),
          ),
          const SizedBox(width: AppSizes.s4),
          Text('pts', style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s12),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.s12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: AppSizes.s20),
          const SizedBox(width: AppSizes.s10),
          Expanded(
            child:
                Text(text, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s14)),
          ),
        ],
      ),
    );
  }
}
