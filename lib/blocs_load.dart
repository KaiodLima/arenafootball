import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/notifications/presentation/widgets/push_topics_listener.dart';
import 'package:arena_soccer/injection_container.dart';

// Cubits em route-level (lib/arena_app.dart):
// - LoginCubit         → loginPage
// - RegisterUserCubit  → registerUserPage
// - ChooseTeamCubit    → chooseTeamPage
// - HomeCubit          → home
// - NewsFormCubit      → registerNewsPage, publishAdPage
// - GoalNotificationCubit → goalNotificationPage
// - HighlightNewsCubit → highlightDetailsPage
// - HighlightFormCubit → registerHighlightPage
// - ManageHighlightsCubit → manageHighlightsPage
// - NotificationsPanelCubit → notificationsPanelPage
// Cubits criados dentro de widgets: NewsFeedCubit (NewsTab), HighlightsCubit (HighlightsCarousel)

class BlocsLoad extends StatelessWidget {
  const BlocsLoad({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Sessão — global: usuário logado e flag de admin usados no app todo
        BlocProvider<SessionCubit>(create: (_) => SessionCubit(sl(), sl())),

        // Região e temporada — global: filtram notícias, times, tabelas...
        BlocProvider<RegionCubit>(create: (_) => RegionCubit(sl(), sl(), sl(), sl())..load()),
      ],
      // Tópicos de push acompanham a região e o time do coração.
      child: PushTopicsListener(child: child),
    );
  }
}
