import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_cubit.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_state.dart';
import 'package:arena_soccer/features/news/presentation/widgets/ad_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/goal_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/result_card.dart';
import 'package:arena_soccer/features/news/presentation/widgets/vote_call_card.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/arena_empty_state.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';
import 'package:arena_soccer/utils/components/arena_alert_sheet.dart';

/// Aba Início da home: feed de notícias da região selecionada.
/// [header] entra no topo da lista e rola junto (ex.: destaques).
/// O [NewsFeedCubit] vive na rota da home: a aba é recriada (key) ao trocar
/// de aba ou de região, mas só a troca de região reabre a consulta.
class NewsTab extends StatefulWidget {
  final Widget? header;

  const NewsTab({super.key, this.header});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  /// Distância (px) do fim da lista em que a próxima página é pedida.
  static const double _loadMoreThreshold = 600;

  @override
  void initState() {
    super.initState();
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    BlocProvider.of<NewsFeedCubit>(context).watch(region: region);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical && notification.metrics.extentAfter < _loadMoreThreshold) {
      BlocProvider.of<NewsFeedCubit>(context).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = context.watch<SessionCubit>().state.isAdmin;
    // Parceiro: edita/apaga só o que publicou.
    final partner = context.watch<PartnerCubit>().state;
    final header = widget.header;

    return BlocConsumer<NewsFeedCubit, NewsFeedState>(
      listener: (context, state) {
        // Com o feed vazio o erro já aparece na tela; aqui só o de ação
        // (ex.: falha ao excluir ou ao buscar mais notícias).
        if (state is ErrorNewsFeedState && state.news.isNotEmpty) {
          showSnackBar(context: context, message: state.errorMessage, isSuccess: false);
        }
      },
      builder: (context, state) {
        final Widget? placeholder;
        if (state is LoadingNewsFeedState && state.news.isEmpty) {
          placeholder = const Padding(
            padding: EdgeInsets.only(top: AppSizes.s48),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is ErrorNewsFeedState && state.news.isEmpty) {
          placeholder = ArenaEmptyState.error(message: l10n.newsLoadError);
        } else if (state.news.isEmpty) {
          placeholder = ArenaEmptyState(message: l10n.newsEmpty, icon: Icons.article_outlined);
        } else {
          placeholder = null;
        }

        // Itens: cabeçalho (opcional), placeholder ou notícias, e o
        // indicador de "carregando mais" no fim.
        final headerCount = header != null ? 1 : 0;
        final bodyCount = placeholder != null ? 1 : state.news.length;
        final footerCount = state.loadingMore ? 1 : 0;

        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // Espaço no fim para o FAB do admin não cobrir o último card.
            padding: const EdgeInsets.fromLTRB(AppSizes.s16, AppSizes.s20, AppSizes.s16, AppSizes.s100),
            itemCount: headerCount + bodyCount + footerCount,
            itemBuilder: (context, index) {
              if (index < headerCount) return header!;
              final bodyIndex = index - headerCount;
              if (bodyIndex >= bodyCount) return const _LoadingMoreIndicator();
              if (placeholder != null) return placeholder;
              final news = state.news[bodyIndex];
              return _NewsItem(news: news, isAdmin: isAdmin, canManage: isAdmin || partner.owns(news.authorId));
            },
          ),
        );
      },
    );
  }
}

/// Indicador pequeno no fim da lista enquanto a próxima página chega.
class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.s16),
      child: Center(
        child: SizedBox(
          width: AppSizes.s24,
          height: AppSizes.s24,
          child: CircularProgressIndicator(strokeWidth: AppSizes.s2, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _NewsItem extends StatelessWidget {
  final NewsDTO news;
  final bool isAdmin;

  /// Mostra editar/apagar: admin, ou o parceiro que publicou.
  final bool canManage;

  const _NewsItem({required this.news, required this.isAdmin, required this.canManage});

  Future<void> _openLink() async {
    final uri = Uri.tryParse(news.link);
    if (uri != null) await launchUrl(uri);
  }

  Widget? _adminMenu(BuildContext context, {required bool onImage, required bool canEdit}) {
    if (!canManage) return null;
    final l10n = AppLocalizations.of(context);
    return CardMenuButton(
      onImage: onImage,
      actions: [
        if (canEdit)
          CardMenuAction(
            icon: Icons.edit_outlined,
            label: l10n.commonEdit,
            onSelected: () => Navigator.pushNamed(
              context,
              news.isAd ? AppRoutes.publishAdPage : AppRoutes.registerNewsPage,
              arguments: {'news': news},
            ),
          ),
        CardMenuAction(
          icon: Icons.delete_outline_rounded,
          label: l10n.commonDelete,
          destructive: true,
          onSelected: () => _confirmDelete(context),
        ),
      ],
    );
  }

  /// Partida dos cards automáticos (resultado e votação), montada do card.
  MatchDTO _matchOfCard() => MatchDTO(
        id: news.matchId,
        homeTeam: news.homeTeam,
        awayTeam: news.awayTeam,
        homeTeamId: news.homeTeamId,
        awayTeamId: news.awayTeamId,
        homeGoals: int.tryParse(news.homeGoals) ?? 0,
        awayGoals: int.tryParse(news.awayGoals) ?? 0,
        championshipId: news.championshipId ?? 0,
        isVotingOpen: news.votingOpen,
      );

  /// Card "Vote no craque": votar (aberta) ou ver o eleito (encerrada).
  void _openVoting(BuildContext context) {
    Navigator.pushNamed(
      context,
      news.votingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
      // As telas de votação exigem a temporada: sem ela no card, a atual.
      arguments: {
        'match': _matchOfCard(),
        'season': news.season.isEmpty ? SeasonCollection.currentSeason : news.season
      },
    );
  }

  /// Detalhes da partida do card de resultado (o stream completa os dados).
  void _openMatch(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.matchDetailsPage,
      arguments: {
        'match': _matchOfCard(),
        'season': news.season.isEmpty ? null : news.season,
        'homeCrest': news.homeCrest.isEmpty ? null : news.homeCrest,
        'awayCrest': news.awayCrest.isEmpty ? null : news.awayCrest,
        'homeColor': colorFromHex(news.homeColor),
        'awayColor': colorFromHex(news.awayColor),
        'championshipLabel': news.championshipTitle.isEmpty ? null : news.championshipTitle,
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = BlocProvider.of<NewsFeedCubit>(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showArenaConfirm(
      context,
      title: l10n.newsDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      icon: Icons.delete_outline_rounded,
      tone: ArenaAlertTone.danger,
    );
    if (confirmed) await cubit.delete(news.id);
  }

  /// Tela do atleta, na temporada gravada no card (os jogadores são por
  /// temporada).
  void _openAthlete(BuildContext context, String playerId, String name) {
    openAthlete(
      context,
      {'playerId': playerId, 'season': news.season.isEmpty ? null : news.season, 'name': name},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (news.isGoal) {
      return GoalCard(
        news: news,
        trailing: _adminMenu(context, onImage: false, canEdit: false),
        // Admin: lança o próximo gol do mesmo jogo partindo deste placar.
        onTap: isAdmin
            ? () => Navigator.pushNamed(context, AppRoutes.goalNotificationPage, arguments: {'news': news})
            : null,
        onScorerTap: news.hasScorer ? () => _openAthlete(context, news.scorerId, news.scorerName) : null,
        onAssistantTap: news.hasAssistant ? () => _openAthlete(context, news.assistantId, news.assistantName) : null,
      );
    }
    if (news.isVoteCall) {
      return VoteCallCard(
        news: news,
        trailing: _adminMenu(context, onImage: true, canEdit: false),
        onTap: news.matchId.isEmpty ? null : () => _openVoting(context),
      );
    }
    if (news.isResult) {
      return ResultCard(
        news: news,
        trailing: _adminMenu(context, onImage: true, canEdit: false),
        onTap: news.matchId.isEmpty ? null : () => _openMatch(context),
      );
    }
    if (news.isAd) {
      return AdCard(
        news: news,
        onTap: news.link.isNotEmpty ? _openLink : null,
        trailing: _adminMenu(context, onImage: true, canEdit: true),
      );
    }
    return NewsCard(
      news: news,
      onTap: () => Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'news': news}),
      trailing: _adminMenu(context, onImage: true, canEdit: true),
    );
  }
}
