import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_groups_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Grupos da região na temporada, em tempo real, com os escudos dos times
/// (o grupo só guarda os nomes; os escudos vêm da coleção de times).
class GroupsCubit extends Cubit<GroupsState> {
  final WatchGroupsUseCase watchGroupsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  StreamSubscription<Either<Failure, List<GroupDTO>>>? _subscription;

  GroupsCubit(this.watchGroupsUseCase, this.getTeamsCacheFirstUseCase) : super(const LoadingGroupsState());

  /// [championshipId] mostra só os grupos desse campeonato (ver
  /// [GroupDTO.forChampionship]); nulo = todos da região.
  void watch({required String region, required String season, int? championshipId}) {
    _subscription?.cancel();
    emit(LoadingGroupsState(groups: state.groups, crests: state.crests));
    _loadCrests(region: region, season: season);
    _subscription = watchGroupsUseCase(region: region, season: season).listen((response) {
      response.fold(
        (failure) => emit(
          ErrorGroupsState(errorMessage: failure.toString(), groups: state.groups, crests: state.crests),
        ),
        (groups) => emit(SuccessGroupsState(
          groups: GroupDTO.forChampionship(groups, championshipId),
          crests: state.crests,
        )),
      );
    });
  }

  /// Escudos são só decoração: se falhar, os cards mostram o ícone padrão.
  Future<void> _loadCrests({required String region, required String season}) async {
    await for (final response in getTeamsCacheFirstUseCase(region: region, season: season)) {
      if (isClosed) return;
      response.fold((_) => null, (teams) {
        final crests = {
          for (final team in teams)
            if (team.imageUrl.isNotEmpty) normalizeTeamName(team.name): team.imageUrl,
        };
        final s = state;
        if (s is LoadingGroupsState) {
          emit(LoadingGroupsState(groups: s.groups, crests: crests));
        } else if (s is ErrorGroupsState) {
          emit(ErrorGroupsState(errorMessage: s.errorMessage, groups: s.groups, crests: crests));
        } else {
          emit(SuccessGroupsState(groups: s.groups, crests: crests));
        }
      });
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
