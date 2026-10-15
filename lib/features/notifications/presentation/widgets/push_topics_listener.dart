import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/core/utils/push_topics.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/injection_container.dart';

/// Mantém os tópicos de push do aparelho iguais à região escolhida, ao time
/// do coração e à conta logada (usuário/admin): trocar um deles troca a inscrição.
class PushTopicsListener extends StatelessWidget {
  final Widget child;

  const PushTopicsListener({super.key, required this.child});

  /// Assina os tópicos atuais (a home chama ao abrir; depois, só mudanças).
  static void syncNow(BuildContext context) {
    final region = BlocProvider.of<RegionCubit>(context).state.selectedRegion;
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    sl<PushTopicSync>().sync(desiredTopics(
      region: region,
      regionId: RegionRegistry.idOf(region),
      favoriteTeam: user?.favoriteTeam,
      favoriteTeamId: user?.favoriteTeamId,
      userId: user?.id,
      isAdmin: user?.isAdmin ?? false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegionCubit, RegionState>(
          listenWhen: (previous, current) => previous.selectedRegion != current.selectedRegion,
          listener: (context, _) => syncNow(context),
        ),
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              current is! CheckingSessionState &&
              (previous.user?.favoriteTeam != current.user?.favoriteTeam ||
                  previous.user?.favoriteTeamId != current.user?.favoriteTeamId ||
                  previous.user?.id != current.user?.id ||
                  previous.isAdmin != current.isAdmin),
          listener: (context, _) => syncNow(context),
        ),
      ],
      child: child,
    );
  }
}
