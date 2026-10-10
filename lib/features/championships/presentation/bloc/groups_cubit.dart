import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_groups_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/groups_state.dart';

/// Grupos da região na temporada, em tempo real.
class GroupsCubit extends Cubit<GroupsState> {
  final WatchGroupsUseCase watchGroupsUseCase;
  StreamSubscription<Either<Failure, List<GroupDTO>>>? _subscription;

  GroupsCubit(this.watchGroupsUseCase) : super(const LoadingGroupsState());

  void watch({required String region, required String season}) {
    _subscription?.cancel();
    emit(LoadingGroupsState(groups: state.groups));
    _subscription = watchGroupsUseCase(region: region, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorGroupsState(errorMessage: failure.toString(), groups: state.groups)),
        (groups) => emit(SuccessGroupsState(groups: groups)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
