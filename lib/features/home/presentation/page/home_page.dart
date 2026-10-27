import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/push_target.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_cubit.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/deep_link_service.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/championships/presentation/widgets/championships_tab.dart';
import 'package:arena_soccer/features/highlights/presentation/widgets/highlights_carousel.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_cubit.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/features/home/presentation/widgets/admin_publish_sheet.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_bottom_bar.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_drawer.dart';
import 'package:arena_soccer/features/home/presentation/widgets/home_header.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';
import 'package:arena_soccer/features/news/presentation/widgets/news_tab.dart';
import 'package:arena_soccer/features/notifications/presentation/widgets/push_topics_listener.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/players/presentation/player_navigation.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/widgets/teams_tab.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/section_header.dart';
import 'package:arena_soccer/utils/components/show_snackbar.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

/// Casca da home: header escuro (saudação + região), folha clara com a aba
/// selecionada, barra de navegação inferior e, para o admin, o botão "Publicar".
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final HomeCubit _homeCubit;
  StreamSubscription<PushTarget>? _pushTabs;
  StreamSubscription<DeepLinkTarget>? _deepLinks;

  @override
  void initState() {
    super.initState();
    _homeCubit = BlocProvider.of<HomeCubit>(context);
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user != null) _homeCubit.loadFavoriteTeam(user.favoriteTeam, teamId: user.favoriteTeamId);
    if (user != null && user.isAdmin) _homeCubit.watchPendingPlayerRequests();

    // Push: pede a permissão (Android 13+) e abre a aba da notificação tocada.
    final push = sl<PushService>();
    push.requestPermission();
    PushTopicsListener.syncNow(context);
    _openPushTab(push.takePending());
    _pushTabs = push.targets.listen(_openPushTab);

    // Links compartilhados: o que abriu o app e os que chegam com ele aberto.
    final deepLinks = sl<DeepLinkService>();
    _openDeepLink(deepLinks.takePending());
    _deepLinks = deepLinks.targets.listen(_openDeepLink);
  }

  @override
  void dispose() {
    _pushTabs?.cancel();
    _deepLinks?.cancel();
    super.dispose();
  }

  /// `aba` do payload: "tabelas" abre a aba de partidas; "solicitacoes" o
  /// painel de pedidos de jogador (admin); "sou_jogador" a situação do pedido
  /// do usuário; o resto, o feed.
  void _openPushTab(PushTarget? target) {
    if (target == null) return;
    if (target.hasScreen) {
      _openPushScreen(target);
      return;
    }
    final tab = target.tab;
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    final route = switch (tab) {
      'solicitacoes' when user != null && user.isAdmin => AppRoutes.playerRequestsPanelPage,
      'sou_jogador' when user != null => AppRoutes.playerRequestPage,
      'solicitacoes_time' when user != null && user.isAdmin => AppRoutes.teamRequestsPanelPage,
      'meu_time' when user != null => AppRoutes.teamRequestPage,
      'solicitacoes_parceiro' when user != null && user.isAdmin => AppRoutes.partnerRequestsPanelPage,
      'parceiro' when user != null => AppRoutes.partnerRequestPage,
      'noticias_pendentes' when user != null && user.isAdmin => AppRoutes.partnerRequestsPanelPage,
      'conquistas' when user != null => AppRoutes.achievementsPage,
      _ => null,
    };
    if (route != null) {
      // Pode vir do initState (push que abriu o app): navega depois do frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushNamed(context, route);
      });
      return;
    }
    _homeCubit.selectTab(tab == 'tabelas' ? HomeTab.tables : HomeTab.news);
  }

  /// Push com tela: a notícia, ou a partida (detalhes) / a votação dela (votar
  /// se aberta, o eleito se encerrada). Partida não encontrada: a aba.
  Future<void> _openPushScreen(PushTarget target) async {
    // Pode vir do initState (push que abriu o app): navega depois do frame.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (target.screen == PushTarget.newsScreen) {
      Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'newsId': target.id});
      return;
    }
    final season = target.season.isEmpty ? SeasonCollection.currentSeason : target.season;
    final match = await _homeCubit.findMatch(target.id, season: season);
    if (!mounted) return;
    if (match == null) {
      _openPushTab(PushTarget(tab: target.tab));
      return;
    }
    if (target.screen == PushTarget.votingScreen) {
      Navigator.pushNamed(
        context,
        match.isVotingOpen ? AppRoutes.voteBestPlayerPage : AppRoutes.electedPlayerPage,
        arguments: {'match': match, 'season': season},
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.matchDetailsPage,
      // Temporada nula = a corrente (como os outros acessos à tela).
      arguments: {'match': match, 'season': season == SeasonCollection.currentSeason ? null : season},
    );
  }

  /// Abre o destino do link (notícia, atleta ou destaque); `/app` fica na
  /// home. Pode vir do initState: navega depois do frame.
  void _openDeepLink(DeepLinkTarget? target) {
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (target) {
        case NewsLinkTarget(:final id):
          Navigator.pushNamed(context, AppRoutes.newsDetailsPage, arguments: {'newsId': id});
        case AthleteLinkTarget(:final season, :final id):
          // Temporada nula = a corrente (como os outros acessos à tela).
          openAthlete(context, {'playerId': id, 'season': season == SeasonCollection.currentSeason ? null : season});
        case HighlightLinkTarget(:final id):
          _openHighlight(id);
        case AppLinkTarget():
          break;
      }
    });
  }

  Future<void> _openHighlight(String id) async {
    final response = await _homeCubit.findHighlight(id);
    if (!mounted) return;
    final highlight = response.isRight ? response.right : null;
    if (highlight == null) {
      final l10n = AppLocalizations.of(context);
      showSnackBar(
        context: context,
        message: response.isLeft ? response.left.toString() : l10n.deepLinkHighlightNotFound,
        isSuccess: false,
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.highlightDetailsPage, arguments: {'highlight': highlight});
  }

  /// Escolha do time pelo menu (quem pulou a etapa no cadastro). Na volta,
  /// carrega o escudo do time escolhido no header e no menu.
  Future<void> _chooseTeam() async {
    await Navigator.pushNamed(context, AppRoutes.chooseTeamPage, arguments: const ChooseTeamArgs(canGoBack: true));
    if (!mounted) return;
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    if (user != null && user.hasFavoriteTeam) {
      _homeCubit.loadFavoriteTeam(user.favoriteTeam, teamId: user.favoriteTeamId);
    }
  }

  Future<void> _logout() async {
    await BlocProvider.of<SessionCubit>(context).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginPage, (_) => false);
  }

  Widget _tabContent(HomeTab tab, RegionState region, AppLocalizations l10n) {
    final key = ValueKey('${tab.name}-${region.selectedRegion}-${region.selectedSeason}');
    switch (tab) {
      case HomeTab.news:
        return NewsTab(
          key: key,
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HighlightsCarousel(),
              SectionHeader(title: l10n.homeLatestNews),
            ],
          ),
        );
      case HomeTab.championships:
        return ChampionshipsTab(key: key);
      case HomeTab.teams:
        return TeamsTab(key: key);
      case HomeTab.tables:
        return MatchesTab(key: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Papéis da conta no menu: jogador aprovado e dono/treinador de time.
    final myPlayer = context.watch<MyPlayerCubit>().state;
    final ownedTeam = context.watch<OwnedTeamCubit>().state;
    final partner = context.watch<PartnerCubit>().state;
    final l10n = AppLocalizations.of(context);
    final session = context.watch<SessionCubit>().state;
    final region = context.watch<RegionCubit>().state;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, home) {
        // Times e tabelas dependem da temporada; notícias e campeonatos, só da região.
        final showSeason = home.tab == HomeTab.teams || home.tab == HomeTab.tables;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            drawer: HomeDrawer(
              user: session.user,
              favoriteTeamImage: home.favoriteTeamImage,
              pendingPlayerRequests: home.pendingPlayerRequests,
              pendingTeamRequests: home.pendingTeamRequests,
              pendingPartnerRequests: home.pendingPartnerRequests + home.pendingPartnerNews,
              playerTeam: myPlayer.teamName,
              playerId: myPlayer.playerId,
              playerSeason: myPlayer.season,
              ownedTeam: ownedTeam.teamName,
              isPartner: partner.isPartner,
              onChooseTeam: _chooseTeam,
              onLogout: _logout,
            ),
            body: Column(
              children: [
                HomeHeader(
                  user: session.user,
                  region: region.selectedRegion,
                  favoriteTeamImage: home.favoriteTeamImage,
                  showSeason: showSeason,
                  onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  // A folha clara sobe sobre o header (cantos arredondados por cima do
                  // gradiente) e cresce o mesmo tanto, para continuar encostada na barra.
                  child: LayoutBuilder(
                    builder: (context, constraints) => OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: constraints.maxHeight + AppSizes.sheetOverlap,
                      child: Transform.translate(
                        offset: const Offset(0, -AppSizes.sheetOverlap),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _tabContent(home.tab, region, l10n),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: HomeBottomBar(selected: home.tab, onSelected: _homeCubit.selectTab),
            // Admin: todos os cadastros; parceiro: só o que ele pode publicar.
            floatingActionButton: session.isAdmin || partner.permissions.canPublish && partner.isPartner
                ? FloatingActionButton(
                    tooltip: l10n.homePublishTitle,
                    onPressed: () => session.isAdmin
                        ? AdminPublishSheet.show(context)
                        : AdminPublishSheet.showPartner(context, partner.permissions),
                    child: const Icon(Icons.add_rounded),
                  )
                : null,
          ),
        );
      },
    );
  }
}
