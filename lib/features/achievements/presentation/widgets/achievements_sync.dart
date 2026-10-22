import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/share_service.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_state.dart';

/// Faz o [AchievementsCubit] seguir a conta logada, conta os
/// compartilhamentos ([ShareService.onShared]) e passa os números que o app
/// já sabe (time do coração, foto, atleta, dono de time).
class AchievementsSync extends StatefulWidget {
  final Widget child;

  const AchievementsSync({super.key, required this.child});

  @override
  State<AchievementsSync> createState() => _AchievementsSyncState();
}

class _AchievementsSyncState extends State<AchievementsSync> {
  late final AchievementsCubit _cubit = BlocProvider.of<AchievementsCubit>(context);

  @override
  void initState() {
    super.initState();
    ShareService.onShared = () => _cubit.record(AchievementMetric.shares);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cubit.follow(BlocProvider.of<SessionCubit>(context).state.user?.id);
      _syncDerived();
    });
  }

  @override
  void dispose() {
    ShareService.onShared = null;
    super.dispose();
  }

  void _syncDerived() {
    final user = BlocProvider.of<SessionCubit>(context).state.user;
    final player = BlocProvider.of<MyPlayerCubit>(context).state.player;
    final ownsTeam = BlocProvider.of<OwnedTeamCubit>(context).state.teamName != null;
    int flag(bool value) => value ? 1 : 0;
    _cubit.updateDerived({
      AchievementMetric.favoriteTeam:
          flag(user != null && (user.favoriteTeamId.isNotEmpty || user.favoriteTeam.trim().isNotEmpty)),
      AchievementMetric.cardPhoto: flag(user != null && user.photoUrl.isNotEmpty),
      AchievementMetric.athlete: flag(player != null),
      AchievementMetric.athleteGoals: player?.goals ?? 0,
      AchievementMetric.athleteAssists: player?.assists ?? 0,
      AchievementMetric.teamOwner: flag(ownsTeam),
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listener: (context, state) {
            _cubit.follow(state.user?.id);
            _syncDerived();
          },
        ),
        BlocListener<MyPlayerCubit, MyPlayerState>(listener: (context, _) => _syncDerived()),
        BlocListener<OwnedTeamCubit, OwnedTeamState>(listener: (context, _) => _syncDerived()),
      ],
      child: widget.child,
    );
  }
}
