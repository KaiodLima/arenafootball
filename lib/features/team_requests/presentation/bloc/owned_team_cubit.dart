import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_my_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_state.dart';

/// Global: acompanha `solicitacoes_time/{uid}` da conta logada (o
/// `OwnedTeamSync` chama [follow] quando a sessão muda). As telas usam
/// [OwnedTeamState.owns] para liberar ao dono o que hoje é só do admin.
class OwnedTeamCubit extends Cubit<OwnedTeamState> {
  final WatchMyTeamRequestUseCase watchMyTeamRequestUseCase;
  StreamSubscription<Either<Failure, TeamRequestDTO?>>? _subscription;
  String? _userId;

  OwnedTeamCubit(this.watchMyTeamRequestUseCase) : super(const OwnedTeamState());

  void follow(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _subscription?.cancel();
    emit(const OwnedTeamState());
    if (userId == null) return;
    // Falha de leitura: segue como "não é dono" (as regras é que protegem).
    _subscription = watchMyTeamRequestUseCase(userId).listen((response) {
      if (response.isRight) emit(OwnedTeamState(request: response.right));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
