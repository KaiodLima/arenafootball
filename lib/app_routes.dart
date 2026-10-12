import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String loginPage = '/login_page';
  static const String registerUserPage = '/register_user_page';
  static const String chooseTeamPage = '/choose_team_page';
  static const String fanCardPage = '/fan_card_page';
  static const String home = '/home';

  // Resultados globais (web scraping)
  static const String globalResultsPage = '/global_results_page';

  // Notícias e destaques
  static const String newsDetailsPage = '/news_details_page';
  static const String highlightDetailsPage = '/highlight_details_page';

  // Times, jogadores e estatísticas
  static const String teamPlayersPage = '/team_players_page';
  static const String playerProfilePage = '/player_profile_page';
  static const String statsRankingPage = '/stats_ranking_page';
  static const String playerRequestPage = '/player_request_page';
  static const String teamRequestPage = '/team_request_page';

  // Partidas, campeonatos e votação
  static const String matchesPage = '/matches_page';
  static const String championshipDetailsPage = '/championship_details_page';
  static const String groupsPage = '/groups_page';
  static const String standingsPage = '/standings_page';
  static const String voteBestPlayerPage = '/vote_best_player_page';
  static const String electedPlayerPage = '/elected_player_page';

  // Cadastros do admin
  static const String registerHighlightPage = '/register_highlight_page';
  static const String registerPlayerPage = '/register_player_page';
  static const String registerMatchPage = '/register_match_page';
  static const String registerNewsPage = '/register_news_page';
  static const String registerTeamPage = '/register_team_page';
  static const String publishAdPage = '/publish_ad_page';
  static const String manageHighlightsPage = '/manage_highlights_page';
  static const String notificationsPanelPage = '/notifications_panel_page';
  static const String goalNotificationPage = '/goal_notification_page';
  static const String playerRequestsPanelPage = '/player_requests_panel_page';
  static const String teamRequestsPanelPage = '/team_requests_panel_page';
  static const String manageChampionshipsPage = '/manage_championships_page';
  static const String championshipFormPage = '/championship_form_page';
  static const String seasonsPanelPage = '/seasons_panel_page';
}

class AppSession {
  /// Navigator do MaterialApp, para quem precisa navegar de fora da árvore
  /// de widgets.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
