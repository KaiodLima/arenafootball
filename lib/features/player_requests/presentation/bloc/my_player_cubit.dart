import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';

/// Global: acompanha `solicitacoes_jogador/{uid}` da conta logada (o
/// `OwnedTeamSync` chama [follow] quando a sessão muda) para o menu mostrar
/// "Jogador do {time}".
class MyPlayerCubit extends Cubit<MyPlayerState> {
  final WatchMyPlayerRequestUseCase watchMyPlayerRequestUseCase;
  StreamSubscription<Either<Failure, PlayerRequestDTO?>>? _subscription;
  String? _userId;

  MyPlayerCubit(this.watchMyPlayerRequestUseCase) : super(const MyPlayerState());

  void follow(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _subscription?.cancel();
    emit(const MyPlayerState());
    if (userId == null) return;
    // Falha de leitura: segue como "não é jogador" (o menu só deixa de mostrar o selo).
    _subscription = watchMyPlayerRequestUseCase(userId).listen((response) {
      if (response.isRight) emit(MyPlayerState(request: response.right));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
