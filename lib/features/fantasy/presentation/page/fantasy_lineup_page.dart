import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_lineup_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_athlete_picker.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_pitch.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_button.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_submit_bar.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
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

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionCubit>().state.user;
    _cubit.load(widget.championship, uid: user?.id ?? '', name: user?.name ?? '', photoUrl: user?.photoUrl ?? '');
  }

  Future<void> _onSlotTap(FantasyLineupState state, FantasySlot slot) async {
    if (!state.editable) return;
    final current = state.draft.idAt(slot);
    if (current != null) {
      final action = await _slotActions(state, slot, current);
      if (!mounted || action == null) return;
      if (action == _SlotAction.remove) return _cubit.remove(slot);
      if (action == _SlotAction.captain) return _cubit.setCaptain(current);
    }
    if (!mounted) return;
    final picked = await showFantasyAthletePicker(
      context,
      slot: slot,
      athletes: state.athletes,
      lineup: state.draft,
    );
    if (picked != null && mounted) _cubit.place(slot, picked);
  }

  Future<_SlotAction?> _slotActions(FantasyLineupState state, FantasySlot slot, String athleteId) {
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

  String? _errorText(AppLocalizations l10n, FantasyLineupState state) => switch (state.error) {
        FantasyLineupError.incomplete => l10n.fantasyErrorIncomplete,
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
                key: const ValueKey('fantasy-open-ranking'),
                tooltip: l10n.fantasyRankingTitle,
                icon: const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
                onPressed: _openRanking,
              ),
            ],
          ),
          bottomNavigationBar: state.editable
              ? ArenaSubmitBar(
                  title: l10n.fantasyConfirmLineup,
                  loading: state.busy,
                  onPressed: () {
                    if (state.canSave) _cubit.save();
                  },
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
        _Header(championship: widget.championship, state: state),
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
          _JoinCard(busy: state.busy, onJoin: _cubit.join)
        else if (state.round == null)
          _Notice(icon: Icons.event_busy_rounded, text: l10n.fantasyNoOpenRound)
        else ...[
          if (state.saved?.copied == true && !state.dirty) ...[
            _Notice(icon: Icons.content_copy_rounded, text: l10n.fantasyCopiedLineup),
            const SizedBox(height: AppSizes.s12),
          ],
          if (!state.roundOpen) ...[
            _Notice(icon: Icons.lock_rounded, text: l10n.fantasyLockedNotice),
            const SizedBox(height: AppSizes.s12),
          ],
          FantasyPitch(
            lineup: state.draft,
            athletes: state.athleteById,
            teams: state.teams,
            editable: state.editable,
            onSlotTap: (slot) => _onSlotTap(state, slot),
            onCaptainTap: _cubit.setCaptain,
          ),
          const SizedBox(height: AppSizes.s12),
          if (state.editable)
            Text(
              error ?? l10n.fantasyCaptainTip(FantasySettings.captainLabel(config.captainMultiplier)),
              key: const ValueKey('fantasy-lineup-hint'),
              style: AppTypography.label(color: error == null ? AppColors.textSecondary : AppColors.danger)
                  .copyWith(fontSize: AppSizes.s12),
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
      ],
    );
  }
}

enum _SlotAction { swap, captain, remove }

class _Header extends StatelessWidget {
  final ChampionshipDTO championship;
  final FantasyLineupState state;

  const _Header({required this.championship, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final round = state.round;
    final status = round == null
        ? l10n.fantasyNoOpenRoundShort
        : state.roundOpen && round.closesAt != null
            ? fantasyDeadlineLabel(l10n, round.closesAt!, state.now)
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
          Container(
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
        ],
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  final bool busy;
  final VoidCallback onJoin;

  const _JoinCard({required this.busy, required this.onJoin});

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
          Text(l10n.fantasyJoinText, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
          const SizedBox(height: AppSizes.s16),
          ArenaButton.primary(
            key: const ValueKey('fantasy-join'),
            title: l10n.fantasyJoin,
            isLoading: busy,
            function: onJoin,
          ),
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
