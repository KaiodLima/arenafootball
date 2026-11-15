import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/event_polls/presentation/widgets/event_poll_feed_card.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/predictions/presentation/widgets/prediction_sheet.dart';
import 'package:arena_soccer/features/qr_codes/domain/now_feed.dart';
import 'package:arena_soccer/features/qr_codes/presentation/bloc/now_cubit.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/arena_hero_background.dart';
import 'package:arena_soccer/utils/components/safe_bottom.dart';
import 'package:arena_soccer/utils/components/team_crest.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/constants/app_typography.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

TextStyle _display(double size, Color color) =>
    TextStyle(fontFamily: 'Anton', fontSize: size, color: color, height: 1.05, letterSpacing: 0.3);

Color _teamColor(TeamDTO? team) => TeamPalette.orDefault(team?.primaryColor ?? '', team?.secondaryColor ?? '').ring;

/// "Acontecendo agora" da região do QR fixo (`/agora/<idRegiao>`): o mais
/// importante em destaque (votação aberta > ao vivo > evento > próximo jogo >
/// bolão) e, abaixo, as votações, os jogos ao vivo, os eventos, os próximos
/// jogos e os atalhos do bolão e do álbum.
class NowPage extends StatefulWidget {
  final String regionId;

  const NowPage({super.key, required this.regionId});

  @override
  State<NowPage> createState() => _NowPageState();
}

class _NowPageState extends State<NowPage> {
  late final NowCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<NowCubit>(context);
    _load();
  }

  Future<void> _load() => _cubit.load(regionId: widget.regionId, season: SeasonCollection.currentSeason);

  ({String? home, String? away}) _crests(MatchDTO match, TeamDirectory teams) => (
        home: teams.resolve(id: match.homeTeamId, name: match.homeTeam)?.imageUrl,
        away: teams.resolve(id: match.awayTeamId, name: match.awayTeam)?.imageUrl,
      );

  void _openVote(MatchDTO match) => Navigator.pushNamed(
        context,
        match.isVotingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
        arguments: {'match': match, 'season': SeasonCollection.currentSeason},
      );

  void _openMatch(MatchDTO match, TeamDirectory teams) {
    final crests = _crests(match, teams);
    Navigator.pushNamed(context, AppRoutes.matchDetailsPage, arguments: {
      'match': match,
      'season': null,
      'homeCrest': crests.home,
      'awayCrest': crests.away,
    });
  }

  void _predict(MatchDTO match, TeamDirectory teams) {
    final crests = _crests(match, teams);
    showPredictionSheet(
      context,
      match: match,
      season: SeasonCollection.currentSeason,
      homeCrest: crests.home,
      awayCrest: crests.away,
    );
  }

  void _openEvent(NewsDTO news) => Navigator.pushNamed(context, AppRoutes.eventPollPage, arguments: {'news': news});

  void _openPool() => Navigator.pushNamed(context, AppRoutes.predictionRankingPage);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final albumOpen = context.watch<AlbumEventCubit>().state.visible;

    return BlocBuilder<NowCubit, NowState>(
      builder: (context, state) {
        final feed = state.feed;
        final teams = state.teams;
        final now = _cubit.now();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            surfaceTintColor: AppColors.transparent,
            titleSpacing: 0,
            title: Text(
              l10n.nowTitle,
              style: AppTypography.title(color: AppColors.white).copyWith(fontSize: AppSizes.s20),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: safeBottom(context, AppSizes.s32)),
              children: [
                _Header(region: state.region),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s16, AppSizes.s16, 0),
                  child: state.loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.s48),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      : state.region.isEmpty
                          ? ArenaEmptyState(message: l10n.nowRegionGone, icon: Icons.location_off_rounded)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _spotlight(context, feed, teams, now),
                                if (feed.quiet) ...[
                                  const SizedBox(height: AppSizes.s10),
                                  Text(l10n.nowQuiet(state.region), style: AppTypography.subtitle()),
                                ],
                                ..._sections(context, feed, teams, now),
                                _SectionTitle(l10n.nowSectionMore),
                                _ShortcutRow(
                                  showAlbum: albumOpen,
                                  onPool: _openPool,
                                  onAlbum: () => Navigator.pushNamed(context, AppRoutes.albumPage),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// O destaque do topo, conforme a prioridade do [NowFeed].
  Widget _spotlight(BuildContext context, NowFeed feed, TeamDirectory teams, DateTime now) {
    final l10n = AppLocalizations.of(context);
    switch (feed.highlight) {
      case NowHighlight.vote:
        final match = feed.votes.first;
        return _MatchSpotlight(
          key: const ValueKey('now-spotlight-vote'),
          match: match,
          teams: teams,
          badge: l10n.qrKindVote,
          badgeIcon: Icons.how_to_vote_rounded,
          // Votação = partida jogada: o placar no lugar do "VS".
          showScore: true,
          action: l10n.nowVote,
          onAction: () => _openVote(match),
        );
      case NowHighlight.live:
        final match = feed.live.first;
        return _MatchSpotlight(
          key: const ValueKey('now-spotlight-live'),
          match: match,
          teams: teams,
          badge: l10n.nowLiveBadge,
          badgeIcon: Icons.circle,
          live: true,
          showScore: true,
          action: l10n.nowWatch,
          onAction: () => _openMatch(match, teams),
        );
      case NowHighlight.event:
        final news = feed.events.first;
        return EventPollFeedCard(key: const ValueKey('now-spotlight-event'), news: news, onTap: () => _openEvent(news));
      case NowHighlight.upcoming:
        final match = feed.upcoming.first;
        final kickoff = PredictionHub.kickoffOf(match, now);
        final closes = kickoff == null ? '' : PredictionHub.closesIn(kickoff, now);
        return _MatchSpotlight(
          key: const ValueKey('now-spotlight-upcoming'),
          match: match,
          teams: teams,
          badge: closes.isEmpty ? l10n.qrKindMatch : '${l10n.qrKindMatch} · ${l10n.predictionHubClosesIn(closes)}',
          badgeIcon: Icons.timer_outlined,
          action: l10n.nowPredict,
          onAction: () => _predict(match, teams),
        );
      case NowHighlight.pool:
        return _PoolSpotlight(key: const ValueKey('now-spotlight-pool'), onTap: _openPool);
    }
  }

  /// As listas abaixo do destaque (sem repetir o item em destaque).
  List<Widget> _sections(BuildContext context, NowFeed feed, TeamDirectory teams, DateTime now) {
    final l10n = AppLocalizations.of(context);
    final highlight = feed.highlight;
    final votes = highlight == NowHighlight.vote ? feed.votes.skip(1).toList() : feed.votes;
    final live = highlight == NowHighlight.live ? feed.live.skip(1).toList() : feed.live;
    final events = highlight == NowHighlight.event ? feed.events.skip(1).toList() : feed.events;
    final upcoming = highlight == NowHighlight.upcoming ? feed.upcoming.skip(1).toList() : feed.upcoming;
    return [
      if (votes.isNotEmpty) ...[
        _SectionTitle(l10n.nowSectionVotes),
        for (final match in votes)
          _MatchRow(match: match, teams: teams, action: l10n.nowVote, gold: true, onAction: () => _openVote(match)),
      ],
      if (live.isNotEmpty) ...[
        _SectionTitle(l10n.nowSectionLive),
        for (final match in live)
          _MatchRow(
            match: match,
            teams: teams,
            live: true,
            action: l10n.nowWatch,
            onAction: () => _openMatch(match, teams),
          ),
      ],
      if (events.isNotEmpty) ...[
        _SectionTitle(l10n.nowSectionEvents),
        for (final news in events) EventPollFeedCard(news: news, onTap: () => _openEvent(news)),
      ],
      if (upcoming.isNotEmpty) ...[
        _SectionTitle(l10n.nowSectionUpcoming),
        for (final match in upcoming)
          _MatchRow(
            match: match,
            teams: teams,
            detail: () {
              final kickoff = PredictionHub.kickoffOf(match, now);
              final closes = kickoff == null ? '' : PredictionHub.closesIn(kickoff, now);
              return closes.isEmpty ? '' : l10n.predictionHubClosesIn(closes);
            }(),
            action: l10n.nowPredict,
            gold: true,
            onAction: () => _predict(match, teams),
            onTap: () => _openMatch(match, teams),
          ),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  final String region;

  const _Header({required this.region});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ArenaHeroBackground(
      watermarkFactor: 0.8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s16, AppSizes.s20, AppSizes.s20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(AppSizes.s14)),
              child: const Icon(Icons.bolt_rounded, color: AppColors.black, size: AppSizes.s28),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.nowTitle.toUpperCase(), style: _display(AppSizes.s24, AppColors.white)),
                  if (region.isNotEmpty)
                    Text(l10n.nowIn(region), style: AppTypography.label(color: AppColors.whiteSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.s4, AppSizes.s20, AppSizes.s4, AppSizes.s8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: AppSizes.s12, letterSpacing: 1.1),
      ),
    );
  }
}

/// Partida em destaque: metades nas cores dos times, escudos grandes, o selo
/// (votação/ao vivo/palpite), o placar (ao vivo) e o botão principal.
class _MatchSpotlight extends StatelessWidget {
  final MatchDTO match;
  final TeamDirectory teams;
  final String badge;
  final IconData badgeIcon;
  final String action;
  final VoidCallback onAction;
  final bool live;
  final bool showScore;

  const _MatchSpotlight({
    super.key,
    required this.match,
    required this.teams,
    required this.badge,
    required this.badgeIcon,
    required this.action,
    required this.onAction,
    this.live = false,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final home = teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    Widget side(TeamDTO? team, String name) => Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                child: TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s56),
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _display(AppSizes.s16, AppColors.white),
              ),
            ],
          ),
        );

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ColoredBox(color: Color.lerp(_teamColor(home), AppColors.black, 0.25)!)),
                Expanded(child: ColoredBox(color: Color.lerp(_teamColor(away), AppColors.black, 0.35)!)),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.black.withValues(alpha: 0.05), AppColors.black.withValues(alpha: 0.55)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.s16),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                        decoration: BoxDecoration(
                          color: live ? AppColors.danger : AppColors.gold,
                          borderRadius: BorderRadius.circular(AppSizes.s20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon,
                                size: live ? AppSizes.s10 : AppSizes.s14,
                                color: live ? AppColors.white : AppColors.black),
                            const SizedBox(width: AppSizes.s4),
                            Flexible(
                              child: Text(
                                badge.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(color: live ? AppColors.white : AppColors.black).copyWith(
                                  fontSize: AppSizes.s12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Text(
                      [match.date, match.time].where((p) => p.trim().isNotEmpty).join(' · '),
                      style: AppTypography.label(color: AppColors.white).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.s12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    side(home, match.homeTeam),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.s16),
                      child: Text(
                        showScore ? '${match.homeGoals} × ${match.awayGoals}' : 'VS',
                        style: _display(showScore ? AppSizes.s32 : AppSizes.s28, AppColors.gold),
                      ),
                    ),
                    side(away, match.awayTeam),
                  ],
                ),
                const SizedBox(height: AppSizes.s14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('now-spotlight-action'),
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.black,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                    ),
                    child: Text(action, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6)),
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

/// Sem nada ativo: o bolão em destaque.
class _PoolSpotlight extends StatelessWidget {
  final VoidCallback onTap;

  const _PoolSpotlight({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: AppSizes.s32),
              const SizedBox(width: AppSizes.s10),
              Expanded(child: Text(l10n.qrPoolTitle.toUpperCase(), style: _display(AppSizes.s22, AppColors.white))),
            ],
          ),
          const SizedBox(height: AppSizes.s6),
          Text(l10n.qrPoolSubtitle, style: AppTypography.body(color: AppColors.whiteSoft)),
          const SizedBox(height: AppSizes.s12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
              shape: const StadiumBorder(),
            ),
            child: Text(l10n.nowPool, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// Partida em linha: escudos, nomes, quando (ou o placar ao vivo), o detalhe
/// e o botão da ação.
class _MatchRow extends StatelessWidget {
  final MatchDTO match;
  final TeamDirectory teams;
  final String action;
  final VoidCallback onAction;
  final VoidCallback? onTap;
  final String detail;
  final bool gold;
  final bool live;

  const _MatchRow({
    required this.match,
    required this.teams,
    required this.action,
    required this.onAction,
    this.onTap,
    this.detail = '',
    this.gold = false,
    this.live = false,
  });

  @override
  Widget build(BuildContext context) {
    final home = teams.resolve(id: match.homeTeamId, name: match.homeTeam);
    final away = teams.resolve(id: match.awayTeamId, name: match.awayTeam);
    Widget line(TeamDTO? team, String name, int goals) => Row(
          children: [
            Container(width: AppSizes.s4, height: AppSizes.s20, color: _teamColor(team)),
            const SizedBox(width: AppSizes.s6),
            TeamCrest(imageUrl: team?.imageUrl, size: AppSizes.s22),
            const SizedBox(width: AppSizes.s6),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary),
              ),
            ),
            if (live) Text('$goals', style: _display(AppSizes.s18, AppColors.textPrimary)),
          ],
        );
    final info = [
      if (live)
        AppLocalizations.of(context).nowLiveBadge
      else
        [match.date, match.time].where((p) => p.isNotEmpty).join(' · '),
      if (detail.isNotEmpty) detail,
    ].join('  ·  ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.s16),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.s16),
          onTap: onTap ?? onAction,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s16),
              border: Border.all(color: live ? AppColors.danger.withValues(alpha: 0.5) : AppColors.greyLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line(home, match.homeTeam, match.homeGoals),
                      const SizedBox(height: AppSizes.s6),
                      line(away, match.awayTeam, match.awayGoals),
                      const SizedBox(height: AppSizes.s6),
                      Text(
                        info,
                        style: AppTypography.subtitle(color: live ? AppColors.danger : AppColors.textSecondary)
                            .copyWith(fontSize: AppSizes.s12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.s10),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: gold ? AppColors.gold : AppColors.primaryDark,
                    foregroundColor: gold ? AppColors.black : AppColors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                  ),
                  child: Text(action, style: const TextStyle(fontSize: AppSizes.s12, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Atalhos fixos: bolão e álbum (se ligado).
class _ShortcutRow extends StatelessWidget {
  final bool showAlbum;
  final VoidCallback onPool;
  final VoidCallback onAlbum;

  const _ShortcutRow({required this.showAlbum, required this.onPool, required this.onAlbum});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget tile(IconData icon, String label, VoidCallback onTap) => Expanded(
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.s16),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.s16),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s14, horizontal: AppSizes.s8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.s16),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: AppColors.primary, size: AppSizes.s28),
                    const SizedBox(height: AppSizes.s6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontSize: AppSizes.s12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        tile(Icons.emoji_events_rounded, l10n.qrKindPool, onPool),
        if (showAlbum) ...[const SizedBox(width: AppSizes.s10), tile(Icons.style_rounded, l10n.qrKindAlbum, onAlbum)],
      ],
    );
  }
}
