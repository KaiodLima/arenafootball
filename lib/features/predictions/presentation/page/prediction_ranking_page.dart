import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_hub_cubit.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/hub_widgets.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/prediction_sheet.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/widgets/region_picker_sheet.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/page/qr_poster_page.dart';

/// Compartilhar texto (trocável no teste).
Future<void> Function(String text) predictionHubShare = ShareService.shareText;

/// Central do bolão da região: cabeçalho "Seu bolão" (posição, quem a conta
/// persegue, como pontua) e as abas Palpitar (próximos jogos abertos com o
/// palpite e os últimos palpites já jogados) e Ranking (pódio, lista até o
/// 50º, "Desafiar amigos" e "Sua posição" fixa embaixo).
class PredictionHubPage extends StatefulWidget {
  const PredictionHubPage({super.key});

  @override
  State<PredictionHubPage> createState() => _PredictionHubPageState();
}

class _PredictionHubPageState extends State<PredictionHubPage> with SingleTickerProviderStateMixin {
  late final PredictionHubCubit _cubit;
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (!_tabs.indexIsChanging && mounted) setState(() {});
    });
  Timer? _clock;
  final _tourHero = GlobalKey();
  final _tourMatch = GlobalKey();
  final _tourTabs = GlobalKey();
  bool _tourRequested = false;

  /// Tour do bolão na 1ª visita (com a central carregada).
  void _requestTour() {
    if (_tourRequested) return;
    _tourRequested = true;
    final l10n = AppLocalizations.of(context);
    TourService.request(
      context,
      TourIds.predictions,
      () => [
        TourStep(
          target: _tourHero,
          icon: Icons.emoji_events_rounded,
          title: l10n.tourPredictionsHeroTitle,
          body: l10n.tourPredictionsHeroBody,
        ),
        TourStep(
          target: _tourMatch,
          icon: Icons.sports_soccer_rounded,
          title: l10n.tourPredictionsMatchTitle,
          body: l10n.tourPredictionsMatchBody,
        ),
        TourStep(
          target: _tourTabs,
          icon: Icons.leaderboard_rounded,
          title: l10n.tourPredictionsTabsTitle,
          body: l10n.tourPredictionsTabsBody,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<PredictionHubCubit>(context);
    _load(BlocProvider.of<RegionCubit>(context).state.selectedRegion);
    // A contagem "Fecha em" anda com a tela aberta.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load(String region) => _cubit.load(
        region: region,
        uid: BlocProvider.of<SessionCubit>(context).state.user?.id ?? '',
        season: SeasonCollection.currentSeason,
      );

  Future<void> _pickRegion(String current) async {
    final regions = BlocProvider.of<RegionCubit>(context).state;
    final picked = await showRegionPicker(
      context,
      regions: regions.regions,
      selected: current,
      recent: regions.recentRegions,
    );
    if (picked != null && picked != current) await _load(picked);
  }

  Future<void> _predict(MatchDTO match, PredictionHubState state) async {
    final home = state.teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = state.teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    await showPredictionSheet(
      context,
      match: match,
      season: SeasonCollection.currentSeason,
      homeCrest: home?.imageUrl,
      awayCrest: away?.imageUrl,
    );
    if (mounted) await _cubit.refreshPrediction(match.id);
  }

  void _openMatch(MatchDTO match, PredictionHubState state) {
    final home = state.teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = state.teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    Navigator.pushNamed(context, AppRoutes.matchDetailsPage, arguments: {
      'match': match,
      'season': SeasonCollection.currentSeason,
      'homeCrest': home?.imageUrl,
      'awayCrest': away?.imageUrl,
    });
  }

  void _challenge(PredictionHubState state, int? position) {
    final l10n = AppLocalizations.of(context);
    predictionHubShare(
      state.mine != null && position != null
          ? l10n.predictionHubChallengeText(position, state.region, appLink)
          : l10n.predictionHubChallengeTextNoRank(state.region, appLink),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<SessionCubit>().state.user;
    final uid = user?.id ?? '';
    final now = _cubit.now();

    return BlocBuilder<PredictionHubCubit, PredictionHubState>(
      builder: (context, state) {
        final myIndex = uid.isEmpty ? -1 : state.entries.indexWhere((e) => e.uid == uid);
        final myPosition = myIndex >= 0 ? state.positionAt(myIndex) : state.myPosition;
        final onRanking = _tabs.index == 1;
        if (!state.loading) _requestTour();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.predictionRankingTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
            actions: [
              if (context.watch<SessionCubit>().state.isAdmin)
                IconButton(
                  key: const ValueKey('hub-qr'),
                  tooltip: l10n.qrMenu,
                  icon: const Icon(Icons.qr_code_2_rounded),
                  onPressed: () => openQrPoster(
                    context,
                    QrTarget.pool(title: l10n.qrPoolTitle, subtitle: l10n.qrPoolSubtitle),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.s12),
                child: _RegionPill(region: state.region, onTap: () => _pickRegion(state.region)),
              ),
            ],
          ),
          bottomNavigationBar: onRanking && uid.isNotEmpty && !state.loading
              ? _MyPositionBar(entry: state.mine, position: myPosition)
              : null,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _tourHero,
                  child: HubHero(
                    region: state.region,
                    loggedIn: uid.isNotEmpty,
                    mine: state.mine,
                    position: myPosition,
                    chase: PredictionHub.chase(state.entries, state.mine),
                    leader: PredictionHub.leads(state.entries, state.mine),
                    onSignIn: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false),
                  ),
                ),
              ),
              SliverPersistentHeader(pinned: true, delegate: _TabsHeader(_tabs, l10n, tourKey: _tourTabs)),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _PlayTab(
                  state: state,
                  loggedIn: uid.isNotEmpty,
                  now: now,
                  featuredKey: _tourMatch,
                  onRefresh: () => _load(state.region),
                  onPredict: (match) => _predict(match, state),
                  onOpenMatch: (match) => _openMatch(match, state),
                ),
                _RankingTab(
                  state: state,
                  uid: uid,
                  onRefresh: () => _load(state.region),
                  onChallenge: () => _challenge(state, myPosition),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Região atual num botão-pílula (abre a busca de regiões).
class _RegionPill extends StatelessWidget {
  final String region;
  final VoidCallback onTap;

  const _RegionPill({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.14),
      shape: const StadiumBorder(),
      child: InkWell(
        key: const ValueKey('hub-region'),
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.s120),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_rounded, size: AppSizes.s16, color: AppColors.white),
                const SizedBox(width: AppSizes.s4),
                Flexible(
                  child: Text(
                    region,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: AppSizes.s18, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final AppLocalizations l10n;
  final Key? tourKey;

  _TabsHeader(this.controller, this.l10n, {this.tourKey});

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.surface,
      elevation: overlapsContent ? 2 : 0,
      child: TabBar(
        key: tourKey,
        controller: controller,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.gold,
        indicatorWeight: 3,
        labelStyle: AppTypography.label().copyWith(fontWeight: FontWeight.w800),
        tabs: [
          Tab(icon: null, text: l10n.predictionHubTabPlay),
          Tab(text: l10n.predictionHubTabRanking),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeader oldDelegate) => oldDelegate.controller != controller;
}

/// Aba Palpitar: o jogo mais próximo em destaque, os demais em linha e os
/// últimos palpites já jogados.
class _PlayTab extends StatelessWidget {
  final PredictionHubState state;
  final bool loggedIn;
  final DateTime now;
  final Key? featuredKey;
  final Future<void> Function() onRefresh;
  final ValueChanged<MatchDTO> onPredict;
  final ValueChanged<MatchDTO> onOpenMatch;

  const _PlayTab({
    required this.state,
    required this.loggedIn,
    required this.now,
    this.featuredKey,
    required this.onRefresh,
    required this.onPredict,
    required this.onOpenMatch,
  });

  HubMatchPhase _phase(MatchDTO match) => hubPhaseOf(match, now) ?? HubMatchPhase.open;

  /// Aberto = palpitar; começado (travado) = abrir a partida.
  void _action(MatchDTO match) => _phase(match) == HubMatchPhase.open ? onPredict(match) : onOpenMatch(match);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final upcoming = state.upcoming;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, safeBottom(context, AppSizes.s32)),
        children: [
          HubSectionTitle(l10n.predictionHubUpcoming),
          if (state.loading && upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.s32),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (upcoming.isEmpty)
            ArenaEmptyState(message: l10n.predictionHubNoUpcoming, icon: Icons.event_busy_rounded)
          else ...[
            HubFeaturedMatch(
              key: featuredKey,
              match: upcoming.first,
              teams: state.teams,
              prediction: state.predictions[upcoming.first.id],
              now: now,
              phase: _phase(upcoming.first),
              onPredict: () => _action(upcoming.first),
            ),
            const SizedBox(height: AppSizes.s10),
            for (final match in upcoming.skip(1))
              HubMatchTile(
                match: match,
                teams: state.teams,
                prediction: state.predictions[match.id],
                now: now,
                phase: _phase(match),
                onPredict: () => _action(match),
              ),
          ],
          if (loggedIn) ...[
            HubSectionTitle(l10n.predictionHubRecent),
            if (state.recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4, vertical: AppSizes.s8),
                child: Text(l10n.predictionHubRecentEmpty, style: AppTypography.subtitle()),
              )
            else
              for (final match in state.recent)
                HubRecentPick(
                  key: ValueKey('hub-recent-${match.id}'),
                  match: match,
                  teams: state.teams,
                  prediction: state.predictions[match.id] ?? PredictionDTO(uid: '', home: 0, away: 0),
                  onTap: () => onOpenMatch(match),
                ),
          ],
        ],
      ),
    );
  }
}

/// Aba Ranking: "Palpiteiros" com "Desafiar amigos", o pódio e a lista.
class _RankingTab extends StatelessWidget {
  final PredictionHubState state;
  final String uid;
  final Future<void> Function() onRefresh;
  final VoidCallback onChallenge;

  const _RankingTab({required this.state, required this.uid, required this.onRefresh, required this.onChallenge});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = state.entries;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.s16, 0, AppSizes.s16, AppSizes.s24),
        children: [
          HubSectionTitle(
            l10n.predictionHubPredictors,
            trailing: TextButton.icon(
              key: const ValueKey('hub-challenge'),
              onPressed: onChallenge,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              icon: const Icon(Icons.group_add_rounded, size: AppSizes.s18),
              label: Text(l10n.predictionHubChallenge),
            ),
          ),
          if (state.loading && entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.s48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (state.errorMessage != null && entries.isEmpty)
            ArenaEmptyState(message: l10n.predictionRankingError, icon: Icons.cloud_off_rounded)
          else if (entries.isEmpty)
            ArenaEmptyState(message: l10n.predictionRankingEmpty, icon: Icons.scoreboard_outlined)
          else ...[
            HubPodium(entries: entries.take(3).toList(), positionAt: state.positionAt, uid: uid),
            const SizedBox(height: AppSizes.s16),
            for (var i = 3; i < entries.length; i++)
              HubRankingRow(entry: entries[i], position: state.positionAt(i), mine: entries[i].uid == uid),
          ],
        ],
      ),
    );
  }
}

/// "Sua posição", fixa embaixo na aba Ranking (mesmo fora do top 50).
class _MyPositionBar extends StatelessWidget {
  final PredictionRankingEntry? entry;
  final int? position;

  const _MyPositionBar({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = this.entry;
    // Fundo desce atrás da barra do sistema; o conteúdo fica acima dela.
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
        child: Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: AppColors.white, size: AppSizes.s28),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.predictionRankingYou, style: AppTypography.subtitle(color: AppColors.white)),
                  Text(
                    entry == null
                        ? l10n.predictionRankingNotRanked
                        : '${l10n.predictionRankingPoints(entry.points)} · '
                            '${l10n.predictionRankingStats(entry.exact, entry.count)}',
                    style: AppTypography.label(color: AppColors.white),
                  ),
                ],
              ),
            ),
            if (entry != null && position != null) Text('$positionº', style: hubDisplay(AppSizes.s32, AppColors.gold)),
          ],
        ),
      ),
    );
  }
}
