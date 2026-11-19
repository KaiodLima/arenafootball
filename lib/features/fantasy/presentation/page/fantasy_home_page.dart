import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/tour_service.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_home_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_labels.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/components/tour/tour_step.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';

/// Home do Arena Fantasy (menu e selo com vários Fantasy): os campeonatos com
/// Fantasy ativo na região, com a rodada, o prazo e a situação da conta.
class FantasyHomePage extends StatefulWidget {
  /// Só para teste.
  final DateTime Function()? clock;

  const FantasyHomePage({super.key, this.clock});

  @override
  State<FantasyHomePage> createState() => _FantasyHomePageState();
}

class _FantasyHomePageState extends State<FantasyHomePage> {
  final _tourHeader = GlobalKey();
  final _tourPlay = GlobalKey();
  final _tourRanking = GlobalKey();
  bool _tourRequested = false;

  /// Tour do Fantasy na 1ª visita (com os cartões na tela), no 1º cartão.
  void _requestTour() {
    if (_tourRequested) return;
    _tourRequested = true;
    final l10n = AppLocalizations.of(context);
    TourService.request(
      context,
      TourIds.fantasy,
      () => [
        TourStep(
          target: _tourHeader,
          icon: Icons.calendar_month_rounded,
          title: l10n.tourFantasyRoundTitle,
          body: l10n.tourFantasyRoundBody,
        ),
        TourStep(
          target: _tourPlay,
          icon: Icons.sports_soccer_rounded,
          title: l10n.tourFantasyPlayTitle,
          body: l10n.tourFantasyPlayBody,
        ),
        TourStep(
          target: _tourRanking,
          icon: Icons.leaderboard_rounded,
          title: l10n.tourFantasyRankingTitle,
          body: l10n.tourFantasyRankingBody,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<FantasyHomeCubit>().load(
          season: SeasonCollection.currentSeason,
          uid: context.read<SessionCubit>().state.user?.id ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = context.select<RegionCubit, String>((cubit) => cubit.state.selectedRegion);
    final now = (widget.clock ?? DateTime.now)();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 0,
        title: Text(l10n.fantasyTitle,
            style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20)),
        actions: [
          // Regras: a config do único Fantasy da região; com vários, os padrões.
          BlocBuilder<FantasyHomeCubit, FantasyHomeState>(
            builder: (context, state) {
              final items = state.loaded ? state.forRegion(region) : const <FantasyHomeItem>[];
              return IconButton(
                key: const ValueKey('fantasy-open-rules'),
                tooltip: l10n.fantasyRulesTitle,
                icon: const Icon(Icons.menu_book_rounded),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.fantasyRulesPage,
                  arguments: items.length == 1 ? items.single.config : null,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FantasyHomeCubit, FantasyHomeState>(
        builder: (context, state) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final items = state.forRegion(region);
          if (items.isEmpty) return ArenaEmptyState(message: l10n.fantasyHomeEmpty, icon: Icons.stadium_outlined);
          _requestTour();
          return ListView(
            padding: EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, safeBottom(context, AppSizes.s24)),
            children: [
              Text(l10n.fantasyHomeIntro, style: AppTypography.subtitle().copyWith(fontSize: AppSizes.s14)),
              const SizedBox(height: AppSizes.s12),
              for (final item in items)
                item == items.first
                    ? FantasyHomeCard(
                        item: item,
                        now: now,
                        headerKey: _tourHeader,
                        playKey: _tourPlay,
                        rankingKey: _tourRanking,
                      )
                    : FantasyHomeCard(item: item, now: now),
            ],
          );
        },
      ),
    );
  }
}

/// Cartão de um Fantasy na home: campeonato, rodada/prazo, situação da conta,
/// total e posição, e os atalhos Escalar · Ranking.
class FantasyHomeCard extends StatelessWidget {
  final FantasyHomeItem item;
  final DateTime now;

  /// Alvos do tour (só no 1º cartão da lista).
  final Key? headerKey;
  final Key? playKey;
  final Key? rankingKey;

  const FantasyHomeCard({
    super.key,
    required this.item,
    required this.now,
    this.headerKey,
    this.playKey,
    this.rankingKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = item.config;
    final championship = config.toChampionship();
    final round = item.round;
    final status = item.statusAt(now);
    final roundText = config.currentRound <= 0 || round == null
        ? l10n.fantasyBadgeNoRound
        : round.closesAt != null && round.isOpenAt(now)
            ? '${l10n.fantasyRoundTitle(round.number)} · ${fantasyDeadlineLabel(l10n, round.closesAt!, now)}'
            : '${l10n.fantasyRoundTitle(round.number)} · '
                '${round.inProgressAt(now) ? l10n.fantasyRoundInProgressShort : l10n.fantasyRoundLocked}';
    final (statusText, statusIcon, statusColor) = switch (status) {
      FantasyHomeStatus.notJoined => (l10n.fantasyHomeJoin, Icons.login_rounded, AppColors.primaryDark),
      FantasyHomeStatus.noRound => (l10n.fantasyBadgeNoRound, Icons.event_busy_rounded, AppColors.textSecondary),
      FantasyHomeStatus.pickTeam => (l10n.fantasyHomePickTeam, Icons.warning_amber_rounded, AppColors.warning),
      FantasyHomeStatus.copied => (l10n.fantasyHomeCopied, Icons.content_copy_rounded, AppColors.primaryDark),
      FantasyHomeStatus.confirmed => (l10n.fantasyHomeConfirmed, Icons.check_circle_rounded, AppColors.primaryStrong),
      FantasyHomeStatus.locked => round?.inProgressAt(now) == true
          ? (l10n.fantasyRoundInProgress(round!.number), Icons.sports_soccer_rounded, AppColors.primaryDark)
          : (l10n.fantasyLockedNotice, Icons.lock_rounded, AppColors.textSecondary),
    };
    return Container(
      key: ValueKey('fantasy-home-${config.championshipDocId}'),
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.greyLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: headerKey,
            padding: const EdgeInsets.all(AppSizes.s16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryMedium]),
            ),
            child: Row(
              children: [
                TeamCrest(imageUrl: config.imageUrl, size: AppSizes.s44),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s16),
                      ),
                      Text(roundText,
                          style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s12)),
                    ],
                  ),
                ),
                if (item.joined)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fantasyPointsLabel(item.participant!.points),
                        key: ValueKey('fantasy-home-points-${config.championshipDocId}'),
                        style: AppTypography.title(color: AppColors.gold).copyWith(fontSize: AppSizes.s20),
                      ),
                      Text(
                        item.position == null ? 'pts' : l10n.fantasyHomePosition(item.position!),
                        style: AppTypography.subtitle(color: AppColors.whiteSoft).copyWith(fontSize: AppSizes.s10),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s12, AppSizes.s8, AppSizes.s8),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: AppSizes.s20),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child:
                      Text(statusText, style: AppTypography.label(color: statusColor).copyWith(fontSize: AppSizes.s14)),
                ),
                KeyedSubtree(
                  key: rankingKey,
                  child: TextButton(
                    key: ValueKey('fantasy-home-ranking-${config.championshipDocId}'),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.fantasyRankingPage, arguments: championship),
                    child: Text(l10n.fantasyTabOverall),
                  ),
                ),
                KeyedSubtree(
                  key: playKey,
                  child: FilledButton(
                    key: ValueKey('fantasy-home-play-${config.championshipDocId}'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.fantasyLineupPage, arguments: championship),
                    child: Text(item.joined ? l10n.fantasyHomePlay : l10n.fantasyHomeEnter),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
