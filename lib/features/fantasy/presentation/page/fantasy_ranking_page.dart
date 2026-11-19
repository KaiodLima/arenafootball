import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_ranking_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_ranking_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_score_sheet.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_top_athletes.dart';

/// Abas do ranking do Fantasy (na ordem da tela).
enum FantasyRankingTab { round, athletes, overall, history }

/// Argumento da rota quando abre numa aba (senão, só o [ChampionshipDTO]).
class FantasyRankingArgs {
  final ChampionshipDTO championship;
  final FantasyRankingTab tab;

  const FantasyRankingArgs(this.championship, {this.tab = FantasyRankingTab.round});

  /// Da rota: [FantasyRankingArgs] ou o [ChampionshipDTO].
  static FantasyRankingArgs of(Object? arguments) =>
      arguments is FantasyRankingArgs ? arguments : FantasyRankingArgs(arguments as ChampionshipDTO);
}

/// Rankings do Arena Fantasy do campeonato: Rodada · Atletas · Geral · Histórico.
class FantasyRankingPage extends StatefulWidget {
  final ChampionshipDTO championship;
  final FantasyRankingTab initialTab;

  const FantasyRankingPage({super.key, required this.championship, this.initialTab = FantasyRankingTab.round});

  @override
  State<FantasyRankingPage> createState() => _FantasyRankingPageState();
}

class _FantasyRankingPageState extends State<FantasyRankingPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: FantasyRankingTab.values.length, vsync: this, initialIndex: widget.initialTab.index);

  FantasyRankingCubit get _cubit => context.read<FantasyRankingCubit>();
  final _tourTabs = GlobalKey();
  final _tourRound = GlobalKey();
  final _tourMine = GlobalKey();
  bool _tourRequested = false;

  /// Tour dos rankings na 1ª visita (aba Rodada com as rodadas na tela).
  void _requestTour() {
    if (_tourRequested) return;
    _tourRequested = true;
    final l10n = AppLocalizations.of(context);
    TourService.request(
      context,
      TourIds.fantasyRanking,
      () => [
        TourStep(
          target: _tourTabs,
          icon: Icons.view_week_rounded,
          title: l10n.tourFantasyRankTabsTitle,
          body: l10n.tourFantasyRankTabsBody,
        ),
        TourStep(
          target: _tourRound,
          icon: Icons.swap_horiz_rounded,
          title: l10n.tourFantasyRankRoundTitle,
          body: l10n.tourFantasyRankRoundBody,
        ),
        TourStep(
          target: _tourMine,
          icon: Icons.person_pin_rounded,
          title: l10n.tourFantasyRankMineTitle,
          body: l10n.tourFantasyRankMineBody,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit.load(widget.championship, uid: context.read<SessionCubit>().state.user?.id ?? '');
    // Histórico: carrega só ao abrir a aba (uma leitura por rodada).
    // Atletas: os craques da rodada só ao abrir a aba (uma consulta por rodada).
    _onTab();
    _tabs.addListener(_onTab);
  }

  void _onTab() {
    if (_tabs.index == FantasyRankingTab.history.index) _cubit.loadHistory();
    if (_tabs.index == FantasyRankingTab.athletes.index) _cubit.loadTopAthletes();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.fantasyRankingTitle,
                style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
            Text(
              widget.championship.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12),
            ),
          ],
        ),
        bottom: TabBar(
          key: _tourTabs,
          controller: _tabs,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.whiteSoft,
          dividerColor: AppColors.transparent,
          tabs: [
            Tab(text: l10n.fantasyTabRound),
            Tab(text: l10n.fantasyTabAthletes),
            Tab(text: l10n.fantasyTabOverall),
            Tab(text: l10n.fantasyTabHistory),
          ],
        ),
      ),
      body: BlocBuilder<FantasyRankingCubit, FantasyRankingState>(
        builder: (context, state) {
          if (state.roundsLoaded && state.rounds.isNotEmpty && _tabs.index == FantasyRankingTab.round.index) {
            _requestTour();
          }
          return TabBarView(
            controller: _tabs,
            children: [
              _RoundTab(state: state, selectorKey: _tourRound, mineKey: _tourMine),
              _AthletesTab(state: state, fantasyId: widget.championship.id),
              _OverallTab(state: state),
              _HistoryTab(state: state, fantasyId: widget.championship.id),
            ],
          );
        },
      ),
    );
  }
}

/// Lista com pódio (3 primeiros) e as linhas do 4º em diante.
class _RankingList extends StatelessWidget {
  final List<FantasyRankingEntry> entries;
  final String uid;
  final List<Widget> header;

  const _RankingList({required this.entries, required this.uid, this.header = const []});

  @override
  Widget build(BuildContext context) {
    final positions = fantasyPositions(entries);
    return RefreshIndicator(
      onRefresh: () async => context.read<FantasyRankingCubit>().refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, AppSizes.s24),
        children: [
          ...header,
          if (entries.isNotEmpty) ...[
            FantasyPodium(entries: entries.take(3).toList(), positions: positions, uid: uid),
            const SizedBox(height: AppSizes.s16),
          ],
          for (var i = 3; i < entries.length; i++)
            FantasyRankingRow(entry: entries[i], position: positions[i], mine: entries[i].uid == uid),
        ],
      ),
    );
  }
}

class _RoundTab extends StatelessWidget {
  final FantasyRankingState state;

  /// Alvos do tour (só nesta aba; a de Atletas usa o mesmo seletor sem chave).
  final Key? selectorKey;
  final Key? mineKey;

  const _RoundTab({required this.state, this.selectorKey, this.mineKey});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!state.roundsLoaded) return const Center(child: CircularProgressIndicator());
    if (state.rounds.isEmpty) {
      return ArenaEmptyState(message: l10n.fantasyNoClosedRound, icon: Icons.event_note_rounded);
    }
    return Column(
      children: [
        _RoundSelector(key: selectorKey, state: state),
        Expanded(
          child: state.roundLoading
              ? const Center(child: CircularProgressIndicator())
              : state.roundEntries.isEmpty
                  ? ArenaEmptyState(message: l10n.fantasyRankingEmpty, icon: Icons.leaderboard_outlined)
                  : _RankingList(entries: state.roundEntries, uid: state.uid),
        ),
        if (state.uid.isNotEmpty)
          KeyedSubtree(
            key: mineKey,
            child: FantasyMyPositionCard(
              points: state.myRound.points,
              position: state.myRound.position,
              emptyText: l10n.fantasyNotPlayedRound,
            ),
          ),
      ],
    );
  }
}

/// ◀ Rodada N ▶ entre as rodadas fechadas (abas Rodada e Atletas).
class _RoundSelector extends StatelessWidget {
  final FantasyRankingState state;

  const _RoundSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<FantasyRankingCubit>();
    final round = state.round;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s8, AppSizes.s8, AppSizes.s8, 0),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('fantasy-round-older'),
            onPressed: state.hasOlder ? cubit.olderRound : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.fantasyRoundTitle(state.selectedRound ?? 0),
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: AppSizes.s18),
                ),
                if (round != null && !round.finished)
                  Text(
                    round.scored ? l10n.fantasyRoundPartial : l10n.fantasyAwaitingScore,
                    style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s12),
                  ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('fantasy-round-newer'),
            onPressed: state.hasNewer ? cubit.newerRound : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

/// Aba Atletas: os que mais pontuaram na rodada escolhida (top 20), toque =
/// pontuação detalhada.
class _AthletesTab extends StatelessWidget {
  final FantasyRankingState state;
  final String fantasyId;

  const _AthletesTab({required this.state, required this.fantasyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!state.roundsLoaded) return const Center(child: CircularProgressIndicator());
    if (state.rounds.isEmpty) {
      return ArenaEmptyState(message: l10n.fantasyNoClosedRound, icon: Icons.event_note_rounded);
    }
    final round = state.selectedRound ?? 0;
    final positions = fantasyAthletePositions(state.topAthletes);
    return Column(
      children: [
        _RoundSelector(state: state),
        Expanded(
          child: state.topLoading
              ? const Center(child: CircularProgressIndicator())
              : state.topAthletes.isEmpty
                  ? ArenaEmptyState(message: l10n.fantasyTopAthletesEmpty, icon: Icons.sports_soccer_rounded)
                  : RefreshIndicator(
                      onRefresh: () async => context.read<FantasyRankingCubit>().refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                            AppSizes.s16, AppSizes.s8, AppSizes.s16, safeBottom(context, AppSizes.s24)),
                        children: [
                          for (var i = 0; i < state.topAthletes.length; i++)
                            FantasyTopAthleteRow(
                              athlete: state.topAthletes[i],
                              position: positions[i],
                              onTap: () => showFantasyAthleteScore(
                                context,
                                fantasyId: fantasyId,
                                round: round,
                                athleteId: state.topAthletes[i].athleteId,
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

class _OverallTab extends StatelessWidget {
  final FantasyRankingState state;

  const _OverallTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final champions = state.config?.champions ?? const [];
    return Column(
      children: [
        Expanded(
          child: state.overallLoading
              ? const Center(child: CircularProgressIndicator())
              : state.overallEntries.isEmpty && champions.isEmpty
                  ? ArenaEmptyState(message: l10n.fantasyRankingEmpty, icon: Icons.leaderboard_outlined)
                  : _RankingList(
                      entries: state.overallEntries,
                      uid: state.uid,
                      header: [
                        if (champions.isNotEmpty) ...[
                          FantasyChampionBanner(champions: champions),
                          const SizedBox(height: AppSizes.s16),
                        ],
                      ],
                    ),
        ),
        if (state.uid.isNotEmpty)
          FantasyMyPositionCard(
            points: state.myOverall.points,
            position: state.myOverall.position,
            emptyText: l10n.fantasyNotJoined,
          ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final FantasyRankingState state;
  final String fantasyId;

  const _HistoryTab({required this.state, required this.fantasyId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.uid.isEmpty) return ArenaEmptyState(message: l10n.fantasyGuest, icon: Icons.login_rounded);
    if (!state.historyLoaded) return const Center(child: CircularProgressIndicator());
    if (state.history.isEmpty) return ArenaEmptyState(message: l10n.fantasyHistoryEmpty, icon: Icons.history_rounded);
    return RefreshIndicator(
      onRefresh: () => context.read<FantasyRankingCubit>().loadHistory(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
        children: [
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
      ),
    );
  }
}
