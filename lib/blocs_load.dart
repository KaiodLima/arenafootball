import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/notifications/presentation/widgets/push_topics_listener.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
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
        BlocProvider<SessionCubit>(create: (_) => SessionCubit(sl(), sl(), sl())),

        // Região e temporada — global: filtram notícias, times, tabelas...
        BlocProvider<RegionCubit>(create: (_) => RegionCubit(sl(), sl(), sl(), sl(), sl())..load()),

        // Time do qual o usuário logado é dono ("Sou dono de time") — global:
        // libera ao dono a edição do elenco e do time.
        BlocProvider<OwnedTeamCubit>(create: (_) => OwnedTeamCubit(sl())),

        // Time em que o usuário logado joga ("Sou jogador" aprovado) — global:
        // o menu mostra "Jogador do {time}".
        BlocProvider<MyPlayerCubit>(create: (_) => MyPlayerCubit(sl())),
      ],
      // Tópicos de push acompanham a região e o time do coração.
      child: OwnedTeamSync(child: PushTopicsListener(child: child)),
    );
  }
}

/// Faz o [OwnedTeamCubit] e o [MyPlayerCubit] seguirem a conta logada.
class OwnedTeamSync extends StatelessWidget {
  final Widget child;

  const OwnedTeamSync({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (previous, current) => previous.user?.id != current.user?.id,
      listener: (context, state) {
        BlocProvider.of<OwnedTeamCubit>(context).follow(state.user?.id);
        BlocProvider.of<MyPlayerCubit>(context).follow(state.user?.id);
      },
      child: child,
    );
  }
}
