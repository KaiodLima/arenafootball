import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_admin_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_score_sheet.dart';

/// "22/11 18:00" (hora do aparelho).
String _when(DateTime date) {
  final local = date.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
}

/// Painel do admin do Arena Fantasy: Rodadas (apuração ao vivo + "Reapurar")
/// e Participantes (paginados, com o histórico de cada um).
class FantasyAdminPage extends StatefulWidget {
  final ChampionshipDTO championship;

  /// 0 = Rodadas, 1 = Participantes.
  final int initialTab;

  const FantasyAdminPage({super.key, required this.championship, this.initialTab = 0});

  @override
  State<FantasyAdminPage> createState() => _FantasyAdminPageState();
}

class _FantasyAdminPageState extends State<FantasyAdminPage> {
  FantasyAdminCubit get _cubit => context.read<FantasyAdminCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load(widget.championship);
  }

  Future<void> _confirmRescore() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fantasyRescoreTitle),
        content: Text(l10n.fantasyRescoreText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.fantasyCancel)),
          TextButton(
            key: const ValueKey('fantasy-rescore-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.fantasyRescore),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await _cubit.rescore();
  }

  Future<void> _openParticipant(FantasyParticipantDTO participant) async {
    _cubit.openParticipant(participant.uid);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: _ParticipantSheet(participant: participant, fantasyId: widget.championship.id),
          ),
        ),
      ),
    );
    if (mounted) _cubit.closeParticipant();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: BlocListener<FantasyAdminCubit, FantasyAdminState>(
        listenWhen: (_, current) => current.rescore != FantasyRescoreResult.none,
        listener: (context, state) => showSnackBar(
          context: context,
          message: state.rescore == FantasyRescoreResult.requested
              ? l10n.fantasyRescoreRequested
              : (state.failure ?? l10n.fantasyRescoreError),
          isSuccess: state.rescore == FantasyRescoreResult.requested,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.fantasyFollowTitle,
                    style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
                Text(
                  widget.championship.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
                ),
              ],
            ),
            actions: [
              BlocBuilder<FantasyAdminCubit, FantasyAdminState>(
                buildWhen: (a, b) => a.rescoring != b.rescoring,
                builder: (context, state) => IconButton(
                  key: const ValueKey('fantasy-rescore'),
                  tooltip: l10n.fantasyRescore,
                  icon: state.rescoring
                      ? const SizedBox.square(
                          dimension: AppSizes.s20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Icon(Icons.refresh_rounded),
                  onPressed: state.rescoring ? null : _confirmRescore,
                ),
              ),
            ],
            bottom: TabBar(
              indicatorColor: AppColors.gold,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.whiteSoft,
              dividerColor: AppColors.transparent,
              tabs: [Tab(text: l10n.fantasyAdminRounds), Tab(text: l10n.fantasyAdminParticipants)],
            ),
          ),
          body: BlocBuilder<FantasyAdminCubit, FantasyAdminState>(
            builder: (context, state) => TabBarView(
              children: [
                _RoundsTab(state: state),
                _ParticipantsTab(state: state, onOpen: _openParticipant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundsTab extends StatelessWidget {
  final FantasyAdminState state;

  const _RoundsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!state.roundsLoaded) return const Center(child: CircularProgressIndicator());
    if (state.rounds.isEmpty) {
      return ArenaEmptyState(message: l10n.fantasyAdminNoRounds, icon: Icons.event_note_rounded);
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
      children: [for (final round in state.rounds) FantasyAdminRoundCard(round: round)],
    );
  }
}

/// Cartão da rodada no painel: status, prazo, partidas terminadas,
/// escalações, quando foi apurada, "Finalizada" e os parâmetros congelados.
class FantasyAdminRoundCard extends StatelessWidget {
  final FantasyRoundDTO round;

  const FantasyAdminRoundCard({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (status, color) = switch (round.status) {
      'aberta' => (l10n.fantasyStatusOpen, AppColors.primary),
      'fechada' => (l10n.fantasyStatusClosed, AppColors.primaryDark),
      _ => (l10n.fantasyStatusEmpty, AppColors.grey),
    };
    final params = round.params;
    Widget line(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: AppSizes.s6),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.s16, color: AppColors.textSecondary),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: Text(text,
                    style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12)),
              ),
            ],
          ),
        );
    return Container(
      key: ValueKey('fantasy-admin-round-${round.number}'),
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.fantasyRoundTitle(round.number),
                    style: AppTypography.title().copyWith(fontSize: AppSizes.s16)),
              ),
              if (round.finished)
                Container(
                  margin: const EdgeInsets.only(right: AppSizes.s6),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s10)),
                  child: Text(l10n.fantasyStatusFinished,
                      style: AppTypography.label(color: AppColors.primaryDark).copyWith(fontSize: AppSizes.s10)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.s10)),
                child:
                    Text(status, style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s10)),
              ),
            ],
          ),
          if (round.closesAt != null) line(Icons.schedule_rounded, l10n.fantasyAdminDeadline(_when(round.closesAt!))),
          line(
            Icons.sports_soccer_rounded,
            l10n.fantasyAdminMatches(round.matchesFinished, round.matchIds.length),
          ),
          if (round.scored) line(Icons.groups_rounded, l10n.fantasyAdminLineups(round.lineups)),
          line(
            Icons.fact_check_outlined,
            round.processedAt != null
                ? l10n.fantasyAdminScoredAt(_when(round.processedAt!))
                : l10n.fantasyAdminNotScored,
          ),
          if (params != null)
            line(
              Icons.tune_rounded,
              l10n.fantasyAdminParams(
                params.minMinutes,
                params.minDefenseMinutes,
                FantasySettings.captainLabel(params.captain),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticipantsTab extends StatelessWidget {
  final FantasyAdminState state;
  final ValueChanged<FantasyParticipantDTO> onOpen;

  const _ParticipantsTab({required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.participants.isEmpty) {
      return state.participantsLoading
          ? const Center(child: CircularProgressIndicator())
          : ArenaEmptyState(message: l10n.fantasyAdminNoParticipants, icon: Icons.groups_outlined);
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s8, AppSizes.s16, safeBottom(context, AppSizes.s24)),
      children: [
        for (final p in state.participants)
          ListTile(
            key: ValueKey('fantasy-participant-${p.uid}'),
            contentPadding: EdgeInsets.zero,
            onTap: () => onOpen(p),
            leading: FantasyAvatar(name: p.name, photoUrl: p.photoUrl, size: AppSizes.s40),
            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              p.firstRound > 0 ? l10n.fantasyAdminSince(p.firstRound) : l10n.fantasyAdminSinceStart,
              style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
            ),
            trailing: Text(
              l10n.fantasyPointsValue(fantasyPointsLabel(p.points)),
              style: AppTypography.label(color: AppColors.primaryDark),
            ),
          ),
        if (state.hasMore)
          Center(
            child: state.participantsLoading
                ? const Padding(padding: EdgeInsets.all(AppSizes.s12), child: CircularProgressIndicator())
                : TextButton(
                    key: const ValueKey('fantasy-participants-more'),
                    onPressed: context.read<FantasyAdminCubit>().loadMore,
                    child: Text(l10n.fantasyLoadMore),
                  ),
          ),
      ],
    );
  }
}

/// Folha do participante: as escalações dele em cada rodada fechada.
class _ParticipantSheet extends StatelessWidget {
  final FantasyParticipantDTO participant;
  final String fantasyId;

  const _ParticipantSheet({required this.participant, required this.fantasyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<FantasyAdminCubit, FantasyAdminState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s16),
          children: [
            Row(
              children: [
                FantasyAvatar(name: participant.name, photoUrl: participant.photoUrl, size: AppSizes.s48),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(participant.name, style: AppTypography.title().copyWith(fontSize: AppSizes.s18)),
                      Text(
                        l10n.fantasyPointsValue(fantasyPointsLabel(participant.points)),
                        style: AppTypography.label(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s16),
            if (state.historyLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.history.isEmpty)
              Text(l10n.fantasyAdminNoLineups, style: AppTypography.subtitle())
            else
              for (final item in state.history)
                FantasyHistoryCard(
                  item: item,
                  athletes: state.athletes,
                  onAthleteTap: (id, captain) => showFantasyAthleteScore(
                    context,
                    fantasyId: fantasyId,
                    round: item.round.number,
                    athleteId: id,
                    captain: captain,
                    athlete: state.athletes[id],
                  ),
                ),
          ],
        );
      },
    );
  }
}
