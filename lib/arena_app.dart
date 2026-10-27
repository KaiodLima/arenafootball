import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_totals_repair_cubit.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievement_form_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/manage_achievements_cubit.dart';
import 'package:arena_soccer/features/achievements/presentation/page/achievement_form_page.dart';
import 'package:arena_soccer/features/achievements/presentation/page/achievements_page.dart';
import 'package:arena_soccer/features/achievements/presentation/page/manage_achievements_page.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/navigation/route_stack.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_cubit.dart';
import 'package:arena_soccer/features/fan_card/presentation/page/fan_card_page.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/match_goals_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/page/global_results_page.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/choose_team_page.dart';
import 'package:arena_soccer/features/auth/presentation/page/login_page.dart';
import 'package:arena_soccer/features/auth/presentation/page/register_user_page.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_form_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/manage_championships_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/page/championship_details_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/championship_form_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/groups_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/manage_championships_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/standings_page.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_cubit.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/page/manage_highlights_page.dart';
import 'package:arena_soccer/features/predictions/presentation/bloc/prediction_ranking_cubit.dart';
import 'package:arena_soccer/features/predictions/presentation/page/prediction_ranking_page.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/page/manage_regions_page.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_cubit.dart';
import 'package:arena_soccer/features/notifications/presentation/page/notifications_panel_page.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/page/highlight_details_page.dart';
import 'package:arena_soccer/features/highlights/presentation/page/highlight_form_page.dart';
import 'package:arena_soccer/features/home/presentation/page/home_page.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_details_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_details_page.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/voting_rules_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/page/voting_rules_page.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_form_page.dart';
import 'package:arena_soccer/features/matches/presentation/page/matches_page.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/page/ad_form_page.dart';
import 'package:arena_soccer/features/news/presentation/page/goal_notification_page.dart';
import 'package:arena_soccer/features/news/presentation/page/news_by_id_page.dart';
import 'package:arena_soccer/features/news/presentation/page/news_details_page.dart';
import 'package:arena_soccer/features/news/presentation/page/news_form_page.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_request_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_requests_panel_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/page/partner_request_page.dart';
import 'package:arena_soccer/features/partner_requests/presentation/page/partner_requests_panel_page.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_requests_panel_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/page/player_request_page.dart';
import 'package:arena_soccer/features/player_requests/presentation/page/player_requests_panel_page.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_cubit.dart';
import 'package:arena_soccer/features/players/presentation/page/player_profile_page.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/presentation/page/player_form_page.dart';
import 'package:arena_soccer/features/players/presentation/page/team_players_page.dart';
import 'package:arena_soccer/features/splash/presentation/page/splash_page.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/seasons_panel_cubit.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/team_links_cubit.dart';
import 'package:arena_soccer/features/seasons/presentation/page/seasons_panel_page.dart';
import 'package:arena_soccer/features/home/presentation/page/admin_panel_page.dart';
import 'package:arena_soccer/features/home/presentation/page/settings_page.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_cubit.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/page/fan_ranking_page.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';
import 'package:arena_soccer/features/stats/presentation/page/stats_ranking_page.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/my_team_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_request_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_requests_panel_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/page/team_request_page.dart';
import 'package:arena_soccer/features/team_requests/presentation/page/team_requests_panel_page.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_cubit.dart';
import 'package:arena_soccer/features/teams/presentation/page/edit_team_page.dart';
import 'package:arena_soccer/features/teams/presentation/page/team_form_page.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/page/elected_player_page.dart';
import 'package:arena_soccer/features/voting/presentation/page/vote_best_player_page.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/themes/app_theme.dart';

class ArenaApp extends StatelessWidget {
  const ArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppSession.navigatorKey,
      // Pilha de rotas: Atleta/Time voltam à tela já aberta em vez de empilhar.
      navigatorObservers: [routeStackObserver],
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.loginPage: (_) => BlocProvider<LoginCubit>(
              create: (_) => LoginCubit(sl(), sl(), sl(), sl()),
              child: const LoginPage(),
            ),
        AppRoutes.registerUserPage: (_) => BlocProvider<RegisterUserCubit>(
              create: (_) => RegisterUserCubit(sl()),
              child: const RegisterUserPage(),
            ),
        AppRoutes.chooseTeamPage: (_) => BlocProvider<ChooseTeamCubit>(
              create: (_) => ChooseTeamCubit(sl(), sl(), sl()),
              child: const ChooseTeamPage(),
            ),
        AppRoutes.fanCardPage: (_) => BlocProvider<FanCardCubit>(
              create: (_) => FanCardCubit(sl(), sl(), sl()),
              child: const FanCardPage(),
            ),
        // Feed de notícias, campeonatos e partidas da aba de tabelas vivem na
        // home: trocar de aba não reabre as consultas (cada doc relido é
        // cobrado).
        AppRoutes.home: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<HomeCubit>(create: (_) => HomeCubit(sl(), sl(), sl(), sl(), sl(), sl())),
                BlocProvider<ChampionshipsCubit>(create: (_) => ChampionshipsCubit(sl())),
                BlocProvider<MatchesCubit>(create: (_) => MatchesCubit(sl(), sl(), sl(), sl(), sl(), sl())),
                BlocProvider<NewsFeedCubit>(create: (_) => NewsFeedCubit(sl(), sl(), sl())),
              ],
              child: const HomePage(),
            ),

        // Notícias
        // `news` (já carregada) ou `newsId` (deep link: busca antes de mostrar).
        AppRoutes.newsDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final news = args?['news'] as NewsDTO?;
          if (news != null) return NewsDetailsPage(news: news);
          return BlocProvider<NewsByIdCubit>(
            create: (_) => NewsByIdCubit(sl()),
            child: NewsByIdPage(newsId: args?['newsId'] as String? ?? ''),
          );
        },
        // Sem argumento cria; com `news` edita.
        AppRoutes.registerNewsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<NewsFormCubit>(
            create: (_) => NewsFormCubit(sl(), sl(), sl(), sl(), sl()),
            child: NewsFormPage(news: args?['news'] as NewsDTO?, tag: args?['tag'] as String?),
          );
        },
        // `news` opcional: anúncio a editar.
        AppRoutes.publishAdPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<NewsFormCubit>(
            create: (_) => NewsFormCubit(sl(), sl(), sl(), sl(), sl()),
            child: AdFormPage(news: args?['news'] as NewsDTO?),
          );
        },
        // Opcionais: `news` (card de gol tocado pelo admin) ou `match` + `season`
        // (card de partida tocado pelo admin) preenchem times e placar.
        AppRoutes.goalNotificationPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<GoalNotificationCubit>(
            create: (_) => GoalNotificationCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
            child: GoalNotificationPage(
              initial: args?['news'] as NewsDTO?,
              initialMatch: args?['match'] as MatchDTO?,
              season: args?['season'] as String?,
            ),
          );
        },

        // Destaques
        AppRoutes.highlightDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<HighlightNewsCubit>(
            create: (_) => HighlightNewsCubit(sl()),
            child: HighlightDetailsPage(highlight: args?['highlight'] as HighlightDTO),
          );
        },
        // `highlight` opcional: destaque a editar.
        AppRoutes.registerHighlightPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<HighlightFormCubit>(
            create: (_) => HighlightFormCubit(sl(), sl(), sl(), sl()),
            child: HighlightFormPage(highlight: args?['highlight'] as HighlightDTO?),
          );
        },
        AppRoutes.notificationsPanelPage: (_) => BlocProvider<NotificationsPanelCubit>(
              create: (_) => NotificationsPanelCubit(sl(), sl(), sl(), sl(), sl()),
              child: const NotificationsPanelPage(),
            ),
        AppRoutes.manageRegionsPage: (_) => BlocProvider<ManageRegionsCubit>(
              create: (_) => ManageRegionsCubit(sl(), sl(), sl(), sl(), sl(), sl()),
              child: const ManageRegionsPage(),
            ),
        AppRoutes.manageHighlightsPage: (_) => BlocProvider<ManageHighlightsCubit>(
              create: (_) => ManageHighlightsCubit(sl(), sl(), sl(), sl()),
              child: const ManageHighlightsPage(),
            ),

        // Times e jogadores
        AppRoutes.registerTeamPage: (_) => BlocProvider<TeamFormCubit>(
              create: (_) => TeamFormCubit(sl(), sl(), sl(), sl()),
              child: const TeamFormPage(),
            ),
        // `team` obrigatório; `season` nulo = atual. Devolve o time salvo.
        AppRoutes.editTeamPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return BlocProvider<EditTeamCubit>(
            create: (_) => EditTeamCubit(sl(), team: args['team'] as TeamDTO, season: args['season'] as String?),
            child: const EditTeamPage(),
          );
        },
        AppRoutes.teamPlayersPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<TeamPlayersCubit>(
            create: (_) => TeamPlayersCubit(sl(), sl(), sl(), sl(), sl(), sl()),
            child: TeamPlayersPage(team: args?['team'] as TeamDTO, championshipId: args?['championshipId'] as int?),
          );
        },
        // `playerId` obrigatório; `season` nulo = corrente; `player` (opcional) aparece na hora.
        AppRoutes.playerProfilePage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return BlocProvider<PlayerProfileCubit>(
            create: (_) => PlayerProfileCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
            child: PlayerProfilePage(
              playerId: args['playerId'] as String,
              season: args['season'] as String?,
              name: args['name'] as String?,
              initial: args['player'] as PlayerDTO?,
            ),
          );
        },
        AppRoutes.playerRequestPage: (_) => BlocProvider<PlayerRequestCubit>(
              create: (_) => PlayerRequestCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
              child: const PlayerRequestPage(),
            ),
        AppRoutes.playerRequestsPanelPage: (_) => BlocProvider<PlayerRequestsPanelCubit>(
              create: (_) => PlayerRequestsPanelCubit(sl(), sl(), sl(), sl(), sl(), sl()),
              child: const PlayerRequestsPanelPage(),
            ),
        // Pedido de time e, aprovado, a área "Meu time" do dono (mesma rota).
        AppRoutes.teamRequestPage: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<TeamRequestCubit>(create: (_) => TeamRequestCubit(sl(), sl(), sl(), sl(), sl())),
                BlocProvider<MyTeamCubit>(create: (_) => MyTeamCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl())),
              ],
              child: const TeamRequestPage(),
            ),
        AppRoutes.teamRequestsPanelPage: (_) => BlocProvider<TeamRequestsPanelCubit>(
              create: (_) => TeamRequestsPanelCubit(sl(), sl(), sl(), sl(), sl()),
              child: const TeamRequestsPanelPage(),
            ),
        // Pedido "Sou parceiro" e, aprovado, a área do parceiro (mesma rota).
        AppRoutes.partnerRequestPage: (_) => BlocProvider<PartnerRequestCubit>(
              create: (_) => PartnerRequestCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
              child: const PartnerRequestPage(),
            ),
        AppRoutes.partnerRequestsPanelPage: (_) => BlocProvider<PartnerRequestsPanelCubit>(
              create: (_) => PartnerRequestsPanelCubit(sl(), sl(), sl(), sl(), sl(), sl()),
              child: const PartnerRequestsPanelPage(),
            ),
        AppRoutes.registerPlayerPage: (_) => BlocProvider<PlayerFormCubit>(
              create: (_) => PlayerFormCubit(sl(), sl(), sl(), sl(), sl()),
              child: const PlayerFormPage(),
            ),

        // Estatísticas. `region`/`season` opcionais: sem eles, usa o RegionCubit.
        AppRoutes.statsRankingPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<StatsRankingCubit>(
            create: (_) => StatsRankingCubit(sl(), sl()),
            child: StatsRankingPage(
              type: args?['type'] as StatsRankingType? ?? StatsRankingType.goals,
              region: args?['region'] as String?,
              season: args?['season'] as String?,
              championshipId: args?['championshipId'] as int?,
            ),
          );
        },

        // Conquistas da conta logada (o cubit é global).
        AppRoutes.achievementsPage: (context) => const AchievementsPage(),
        // Admin: catálogo de conquistas e o formulário (`achievement` nulo = nova; `order` = posição).
        AppRoutes.manageAchievementsPage: (context) => BlocProvider<ManageAchievementsCubit>(
              create: (_) => ManageAchievementsCubit(sl(), sl(), sl(), sl())..watch(),
              child: const ManageAchievementsPage(),
            ),
        AppRoutes.achievementFormPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<AchievementFormCubit>(
            create: (_) => AchievementFormCubit(
              sl(),
              initial: args?['achievement'] as AchievementDTO?,
              order: args?['order'] as int? ?? 0,
            ),
            child: const AchievementFormPage(),
          );
        },
        // Admin: regras da votação de melhor jogador.
        AppRoutes.votingRulesPage: (context) => BlocProvider<VotingRulesCubit>(
              create: (_) => VotingRulesCubit(sl(), sl())..load(),
              child: const VotingRulesPage(),
            ),
        // Detalhes da partida: `match` obrigatório; escudos, cores e o nome da competição opcionais.
        AppRoutes.matchDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          final season = args['season'] as String?;
          return BlocProvider<MatchDetailsCubit>(
            create: (_) =>
                MatchDetailsCubit(sl(), sl(), sl(), sl(), match: args['match'] as MatchDTO)..start(season: season),
            child: MatchDetailsPage(
              season: season,
              homeCrest: args['homeCrest'] as String?,
              awayCrest: args['awayCrest'] as String?,
              homeColor: args['homeColor'] as Color?,
              awayColor: args['awayColor'] as Color?,
              championshipLabel: args['championshipLabel'] as String?,
            ),
          );
        },
        // Partidas. `region`/`season` opcionais: sem eles, usa o RegionCubit.
        AppRoutes.matchesPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<MatchesCubit>(
            create: (_) => MatchesCubit(sl(), sl(), sl(), sl(), sl(), sl()),
            child: MatchesPage(
              championshipId: args?['championshipId'] as int?,
              region: args?['region'] as String?,
              season: args?['season'] as String?,
            ),
          );
        },
        AppRoutes.registerMatchPage: (_) => BlocProvider<MatchFormCubit>(
              create: (_) => MatchFormCubit(sl(), sl(), sl(), sl(), sl()),
              child: const MatchFormPage(),
            ),

        // Campeonatos, grupos e classificação
        AppRoutes.championshipDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<ChampionshipDetailsCubit>(
            create: (_) => ChampionshipDetailsCubit(sl()),
            child: ChampionshipDetailsPage(championship: args?['championship'] as ChampionshipDTO),
          );
        },
        AppRoutes.adminPanelPage: (_) => const AdminPanelPage(),
        AppRoutes.settingsPage: (_) => const SettingsPage(),
        AppRoutes.predictionRankingPage: (_) => BlocProvider<PredictionRankingCubit>(
              create: (_) => PredictionRankingCubit(sl()),
              child: const PredictionRankingPage(),
            ),
        AppRoutes.fanRankingPage: (_) => BlocProvider<FanRankingCubit>(
              create: (_) => FanRankingCubit(sl()),
              child: const FanRankingPage(),
            ),
        AppRoutes.seasonsPanelPage: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<SeasonsPanelCubit>(create: (_) => SeasonsPanelCubit(sl(), sl())),
                BlocProvider<TeamLinksCubit>(create: (_) => TeamLinksCubit(sl())),
                BlocProvider<PlayerTotalsRepairCubit>(create: (_) => PlayerTotalsRepairCubit(sl())),
              ],
              child: const SeasonsPanelPage(),
            ),
        AppRoutes.manageChampionshipsPage: (_) => BlocProvider<ManageChampionshipsCubit>(
              create: (_) => ManageChampionshipsCubit(sl(), sl(), sl()),
              child: const ManageChampionshipsPage(),
            ),
        // `championship` opcional: campeonato a editar (sem ele, cadastra um novo).
        AppRoutes.championshipFormPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<ChampionshipFormCubit>(
            create: (_) => ChampionshipFormCubit(sl(), sl(), sl()),
            child: ChampionshipFormPage(championship: args?['championship'] as ChampionshipDTO?),
          );
        },
        AppRoutes.groupsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<GroupsCubit>(
            create: (_) => GroupsCubit(sl(), sl()),
            child: GroupsPage(
              region: args?['region'] as String?,
              season: args?['season'] as String?,
              championshipId: args?['championshipId'] as int?,
            ),
          );
        },
        AppRoutes.standingsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<StandingsCubit>(
            create: (_) => StandingsCubit(sl(), sl(), sl()),
            child: StandingsPage(
              region: args?['region'] as String,
              season: args?['season'] as String,
              group: args?['group'] as String,
              groupId: args?['groupId'] as String? ?? '',
            ),
          );
        },

        // Votação de melhor jogador
        AppRoutes.voteBestPlayerPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<VoteBestPlayerCubit>(
            create: (_) => VoteBestPlayerCubit(sl(), sl(), sl(), sl()),
            child: VoteBestPlayerPage(match: args?['match'] as MatchDTO, season: args?['season'] as String),
          );
        },
        AppRoutes.electedPlayerPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<ElectedPlayerCubit>(
            create: (_) => ElectedPlayerCubit(sl()),
            child: ElectedPlayerPage(match: args?['match'] as MatchDTO, season: args?['season'] as String),
          );
        },

        // Os gols dos jogos encerrados vêm sob demanda (MatchGoalsCubit).
        AppRoutes.globalResultsPage: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<GlobalResultsCubit>(create: (_) => GlobalResultsCubit(sl())),
                BlocProvider<MatchGoalsCubit>(create: (_) => MatchGoalsCubit(sl())),
              ],
              child: const GlobalResultsPage(),
            ),
      },
    );
  }
}
