import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_cubit.dart';
import 'package:arena_soccer/features/global_results/presentation/page/global_results_page.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/login_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/page/login_page.dart';
import 'package:arena_soccer/features/auth/presentation/page/register_user_page.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/page/championship_details_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/groups_page.dart';
import 'package:arena_soccer/features/championships/presentation/page/standings_page.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_cubit.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/page/highlight_details_page.dart';
import 'package:arena_soccer/features/highlights/presentation/page/highlight_form_page.dart';
import 'package:arena_soccer/features/home/presentation/page/home_page.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_form_page.dart';
import 'package:arena_soccer/features/matches/presentation/page/matches_page.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/page/ad_form_page.dart';
import 'package:arena_soccer/features/news/presentation/page/goal_notification_page.dart';
import 'package:arena_soccer/features/news/presentation/page/news_details_page.dart';
import 'package:arena_soccer/features/news/presentation/page/news_form_page.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/players/presentation/page/player_form_page.dart';
import 'package:arena_soccer/features/players/presentation/page/team_players_page.dart';
import 'package:arena_soccer/features/splash/presentation/page/splash_page.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';
import 'package:arena_soccer/features/stats/presentation/page/stats_ranking_page.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_cubit.dart';
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
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.loginPage: (_) => BlocProvider<LoginCubit>(
              create: (_) => LoginCubit(sl()),
              child: const LoginPage(),
            ),
        AppRoutes.registerUserPage: (_) => BlocProvider<RegisterUserCubit>(
              create: (_) => RegisterUserCubit(sl(), sl(), sl()),
              child: const RegisterUserPage(),
            ),
        AppRoutes.home: (_) => BlocProvider<HomeCubit>(
              create: (_) => HomeCubit(sl()),
              child: const HomePage(),
            ),

        // Notícias
        AppRoutes.newsDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return NewsDetailsPage(news: args?['news'] as NewsDTO);
        },
        // Sem argumento cria; com `news` edita.
        AppRoutes.registerNewsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<NewsFormCubit>(
            create: (_) => NewsFormCubit(sl(), sl(), sl()),
            child: NewsFormPage(news: args?['news'] as NewsDTO?),
          );
        },
        AppRoutes.publishAdPage: (_) => BlocProvider<NewsFormCubit>(
              create: (_) => NewsFormCubit(sl(), sl(), sl()),
              child: const AdFormPage(),
            ),
        AppRoutes.goalNotificationPage: (_) => BlocProvider<GoalNotificationCubit>(
              create: (_) => GoalNotificationCubit(sl(), sl(), sl()),
              child: const GoalNotificationPage(),
            ),

        // Destaques
        AppRoutes.highlightDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<HighlightNewsCubit>(
            create: (_) => HighlightNewsCubit(sl()),
            child: HighlightDetailsPage(highlight: args?['highlight'] as HighlightDTO),
          );
        },
        AppRoutes.registerHighlightPage: (_) => BlocProvider<HighlightFormCubit>(
              create: (_) => HighlightFormCubit(sl()),
              child: const HighlightFormPage(),
            ),

        // Times e jogadores
        AppRoutes.registerTeamPage: (_) => BlocProvider<TeamFormCubit>(
              create: (_) => TeamFormCubit(sl(), sl(), sl()),
              child: const TeamFormPage(),
            ),
        AppRoutes.teamPlayersPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<TeamPlayersCubit>(
            create: (_) => TeamPlayersCubit(sl(), sl()),
            child: TeamPlayersPage(team: args?['team'] as TeamDTO),
          );
        },
        AppRoutes.registerPlayerPage: (_) => BlocProvider<PlayerFormCubit>(
              create: (_) => PlayerFormCubit(sl(), sl(), sl()),
              child: const PlayerFormPage(),
            ),

        // Estatísticas. `region`/`season` opcionais: sem eles, usa o RegionCubit.
        AppRoutes.statsRankingPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<StatsRankingCubit>(
            create: (_) => StatsRankingCubit(sl()),
            child: StatsRankingPage(
              type: args?['type'] as StatsRankingType? ?? StatsRankingType.goals,
              region: args?['region'] as String?,
              season: args?['season'] as String?,
            ),
          );
        },

        // Partidas. `region`/`season` opcionais: sem eles, usa o RegionCubit.
        AppRoutes.matchesPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<MatchesCubit>(
            create: (_) => MatchesCubit(sl(), sl(), sl(), sl()),
            child: MatchesPage(
              championshipId: args?['championshipId'] as int,
              region: args?['region'] as String?,
              season: args?['season'] as String?,
            ),
          );
        },
        AppRoutes.registerMatchPage: (_) => BlocProvider<MatchFormCubit>(
              create: (_) => MatchFormCubit(sl(), sl(), sl()),
              child: const MatchFormPage(),
            ),

        // Campeonatos, grupos e classificação
        AppRoutes.championshipDetailsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ChampionshipDetailsPage(championship: args?['championship'] as ChampionshipDTO);
        },
        AppRoutes.groupsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<GroupsCubit>(
            create: (_) => GroupsCubit(sl()),
            child: GroupsPage(region: args?['region'] as String?, season: args?['season'] as String?),
          );
        },
        AppRoutes.standingsPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<StandingsCubit>(
            create: (_) => StandingsCubit(sl()),
            child: StandingsPage(
              region: args?['region'] as String,
              season: args?['season'] as String,
              group: args?['group'] as String,
            ),
          );
        },

        // Votação de melhor jogador
        AppRoutes.voteBestPlayerPage: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider<VoteBestPlayerCubit>(
            create: (_) => VoteBestPlayerCubit(sl(), sl()),
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

        AppRoutes.globalResultsPage: (_) => BlocProvider<GlobalResultsCubit>(
              create: (_) => GlobalResultsCubit(sl()),
              child: const GlobalResultsPage(),
            ),
      },
    );
  }
}
