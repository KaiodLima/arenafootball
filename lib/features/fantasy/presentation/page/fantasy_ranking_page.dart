import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_ranking_view.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
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
        elevation: 0,
        scrolledUnderElevation: 0,
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
        actions: [
          BlocBuilder<FantasyRankingCubit, FantasyRankingState>(
            buildWhen: (previous, current) => previous.config != current.config,
            builder: (context, state) => IconButton(
              key: const ValueKey('fantasy-open-rules'),
              tooltip: l10n.fantasyRulesTitle,
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.fantasyRulesPage, arguments: state.config),
            ),
          ),
        ],
        // Abas em pílula (dourada sobre o escuro), como o seletor da guerra das torcidas.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(AppSizes.s48),
          child: Container(
            height: AppSizes.s40,
            margin: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSizes.s8),
            padding: const EdgeInsets.all(AppSizes.s4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.s20),
            ),
            child: TabBar(
              key: _tourTabs,
              controller: _tabs,
              indicator: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s16)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.whiteSoft,
              labelStyle: AppTypography.label().copyWith(fontSize: AppSizes.s12, fontWeight: FontWeight.w800),
              unselectedLabelStyle: AppTypography.label().copyWith(fontSize: AppSizes.s12),
              labelPadding: EdgeInsets.zero,
              dividerColor: AppColors.transparent,
              splashBorderRadius: BorderRadius.circular(AppSizes.s16),
              tabs: [
                Tab(text: l10n.fantasyTabRound),
                Tab(text: l10n.fantasyTabAthletes),
                Tab(text: l10n.fantasyTabOverall),
                Tab(text: l10n.fantasyTabHistory),
              ],
            ),
          ),
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

/// Espaço reservado no fim das listas para o cartão "Sua posição" flutuante.
const double _floatingReserve = AppSizes.s100;

/// Lista (com pódio opcional) + o cartão "Sua posição" flutuando embaixo.
class _RankingList extends StatelessWidget {
  final List<FantasyRankingEntry> entries;
  final String uid;
  final List<Widget> header;

  /// Sem pódio, as linhas começam do 1º que não está em [skipUids].
  final bool podium;
  final Set<String> skipUids;
  final Widget? floating;

  const _RankingList({
    required this.entries,
    required this.uid,
    this.header = const [],
    this.podium = true,
    this.skipUids = const {},
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    final positions = fantasyPositions(entries);
    final first = podium ? 3 : 0;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => context.read<FantasyRankingCubit>().refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSizes.s16,
              AppSizes.s16,
              AppSizes.s16,
              safeBottom(context, floating == null ? AppSizes.s24 : _floatingReserve),
            ),
            children: [
              ...header,
              if (podium && entries.isNotEmpty) ...[
                FantasyPodium(entries: entries.take(3).toList(), positions: positions, uid: uid),
                const SizedBox(height: AppSizes.s16),
              ],
              for (var i = first; i < entries.length; i++)
                if (!skipUids.contains(entries[i].uid))
                  FantasyRankingRow(
                    entry: entries[i],
                    position: positions[i],
                    mine: entries[i].uid == uid,
                    fraction: FantasyRankingView.barFraction(entries, i),
                    gap: FantasyRankingView.gapToAbove(entries, i),
                    abovePosition: i > 0 ? positions[i - 1] : null,
                    tied: FantasyRankingView.isTied(positions, i),
                  ),
            ],
          ),
        ),
        if (floating != null) Positioned(left: 0, right: 0, bottom: 0, child: floating!),
      ],
    );
  }
}

/// "Sua posição" flutuante: margem, cantos e respiro da barra do sistema.
class _FloatingMine extends StatelessWidget {
  final Widget child;

  const _FloatingMine({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSizes.s12),
        child: child,
      ),
    );
  }
}

/// O cartão "Sua posição" com quem a conta persegue nas [entries].
Widget _myPositionCard(
  FantasyRankingState state,
  List<FantasyRankingEntry> entries,
  FantasyMyPosition mine,
  String emptyText, {
  Key? key,
}) {
  final points = mine.points;
  return _FloatingMine(
    key: key,
    child: FantasyMyPositionCard(
      points: points,
      position: mine.position,
      emptyText: emptyText,
      chase: points == null ? null : FantasyRankingView.chase(entries, state.uid, points),
    ),
  );
}

/// Números da conta no cabeçalho: pontos, posição e participantes.
List<FantasyHeroStat> _heroStats(
  AppLocalizations l10n,
  FantasyRankingState state,
  List<FantasyRankingEntry> entries,
  FantasyMyPosition mine,
) =>
    [
      if (state.uid.isNotEmpty) ...[
        FantasyHeroStat(
          value: mine.points == null ? '–' : fantasyPointsLabel(mine.points!),
          label: l10n.fantasyHeroPoints,
        ),
        FantasyHeroStat(
          value: mine.position == null ? '–' : '${mine.position}º',
          label: l10n.fantasyHeroPosition,
          highlight: mine.position != null,
        ),
      ],
      FantasyHeroStat(
        value: '${FantasyRankingView.participants(entries, total: state.config?.participants ?? 0)}',
        label: l10n.fantasyHeroParticipants,
      ),
    ];

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
    final entries = state.roundEntries;
    final mine = state.uid.isEmpty
        ? null
        : _myPositionCard(state, entries, state.myRound, l10n.fantasyNotPlayedRound, key: mineKey);
    return Column(
      children: [
        FantasyRankingHero(
          top: _RoundSelector(key: selectorKey, state: state),
          stats: state.roundLoading ? const [] : _heroStats(l10n, state, entries, state.myRound),
        ),
        Expanded(
          child: state.roundLoading
              ? const Center(child: CircularProgressIndicator())
              : entries.isEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: ArenaEmptyState(message: l10n.fantasyRankingEmpty, icon: Icons.leaderboard_outlined),
                        ),
                        if (mine != null) mine,
                      ],
                    )
                  : _RankingList(entries: entries, uid: state.uid, floating: mine),
        ),
      ],
    );
  }
}

/// ◀ RODADA N ▶ com o estado da rodada (abas Rodada e Atletas), no escuro.
class _RoundSelector extends StatelessWidget {
  final FantasyRankingState state;

  const _RoundSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<FantasyRankingCubit>();
    final round = state.round;
    return Row(
      children: [
        IconButton(
          key: const ValueKey('fantasy-round-older'),
          onPressed: state.hasOlder ? cubit.olderRound : null,
          color: AppColors.white,
          disabledColor: AppColors.whiteMuted,
          icon: const Icon(Icons.chevron_left_rounded, size: AppSizes.s32),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                l10n.fantasyRoundTitle(state.selectedRound ?? 0).toUpperCase(),
                textAlign: TextAlign.center,
                style: hubDisplay(AppSizes.s28, AppColors.white),
              ),
              if (round != null) ...[
                const SizedBox(height: AppSizes.s4),
                FantasyRoundStatusBadge(round: round),
              ],
            ],
          ),
        ),
        IconButton(
          key: const ValueKey('fantasy-round-newer'),
          onPressed: state.hasNewer ? cubit.newerRound : null,
          color: AppColors.white,
          disabledColor: AppColors.whiteMuted,
          icon: const Icon(Icons.chevron_right_rounded, size: AppSizes.s32),
        ),
      ],
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
        FantasyRankingHero(top: _RoundSelector(state: state)),
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
                            AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: AppSizes.s4, bottom: AppSizes.s10),
                            child: Text(
                              l10n.fantasyTopAthletesHeader.toUpperCase(),
                              style: AppTypography.label(color: AppColors.textSecondary)
                                  .copyWith(fontSize: AppSizes.s12, letterSpacing: 1),
                            ),
                          ),
                          for (var i = 0; i < state.topAthletes.length; i++)
                            FantasyTopAthleteRow(
                              athlete: state.topAthletes[i],
                              position: positions[i],
                              tied: FantasyRankingView.isTied(positions, i),
                              boxed: true,
                              onTap: () => showFantasyAthleteScore(
                                context,
                                fantasyId: fantasyId,
                                round: round,
                                athleteId: state.topAthletes[i].athleteId,
                                scoringVersion: state.round?.scoringVersion ?? 0,
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

/// Aba Geral. Com campeão, a faixa festiva toma o lugar do pódio (o campeão é
/// o 1º do geral; o pódio repetiria o mesmo nome logo abaixo) e as linhas
/// seguem do 2º, com as medalhas de prata e bronze na posição.
class _OverallTab extends StatelessWidget {
  final FantasyRankingState state;

  const _OverallTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final champions = state.config?.champions ?? const [];
    final entries = state.overallEntries;
    final mine = state.uid.isEmpty ? null : _myPositionCard(state, entries, state.myOverall, l10n.fantasyNotJoined);
    return Column(
      children: [
        FantasyRankingHero(
          top: Padding(
            padding: const EdgeInsets.only(top: AppSizes.s8),
            child: Text(l10n.fantasyOverallTitle, style: hubDisplay(AppSizes.s24, AppColors.white)),
          ),
          stats: state.overallLoading ? const [] : _heroStats(l10n, state, entries, state.myOverall),
        ),
        Expanded(
          child: state.overallLoading
              ? const Center(child: CircularProgressIndicator())
              : entries.isEmpty && champions.isEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: ArenaEmptyState(message: l10n.fantasyRankingEmpty, icon: Icons.leaderboard_outlined),
                        ),
                        if (mine != null) mine,
                      ],
                    )
                  : _RankingList(
                      entries: entries,
                      uid: state.uid,
                      podium: champions.isEmpty,
                      skipUids: {for (final c in champions) c.uid},
                      floating: mine,
                      header: [
                        if (champions.isNotEmpty) ...[
                          FantasyChampionBanner(champions: champions),
                          const SizedBox(height: AppSizes.s16),
                        ],
                      ],
                    ),
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
        padding: EdgeInsets.fromLTRB(AppSizes.s12, AppSizes.s12, AppSizes.s12, safeBottom(context, AppSizes.s24)),
        children: [
          for (final item in state.history)
            FantasyHistoryCard(
              item: item,
              athletes: state.athletes,
              captainMultiplier: item.round.params?.captain ?? state.config?.captainMultiplier,
              onAthleteTap: (id, captain) => showFantasyAthleteScore(
                context,
                fantasyId: fantasyId,
                round: item.round.number,
                athleteId: id,
                captain: captain,
                athlete: state.athletes[id],
                scoringVersion: item.round.scoringVersion,
              ),
            ),
        ],
      ),
    );
  }
}
