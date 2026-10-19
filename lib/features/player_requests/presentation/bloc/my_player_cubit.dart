import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_user_player_usecase.dart';

/// Global: acompanha o atleta da conta logada (temporada atual) e o pedido
/// `solicitacoes_jogador/{uid}` (o `OwnedTeamSync` chama [follow] quando a
/// sessão muda) para o menu mostrar "Jogador do {time}".
class MyPlayerCubit extends Cubit<MyPlayerState> {
  final WatchMyPlayerRequestUseCase watchMyPlayerRequestUseCase;
  final WatchUserPlayerUseCase watchUserPlayerUseCase;
  StreamSubscription<Either<Failure, PlayerRequestDTO?>>? _requestSubscription;
  StreamSubscription<Either<Failure, PlayerDTO?>>? _playerSubscription;
  String? _userId;

  MyPlayerCubit(this.watchMyPlayerRequestUseCase, this.watchUserPlayerUseCase) : super(const MyPlayerState());

  void follow(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _requestSubscription?.cancel();
    _playerSubscription?.cancel();
    emit(const MyPlayerState());
    if (userId == null) return;
    // Falha de leitura: segue como "não é jogador" (o menu só deixa de mostrar o selo).
    _requestSubscription = watchMyPlayerRequestUseCase(userId).listen((response) {
      if (response.isRight) emit(MyPlayerState(player: state.player, request: response.right));
    });
    _playerSubscription =
        watchUserPlayerUseCase(userId: userId, season: SeasonCollection.currentSeason).listen((response) {
      if (response.isRight) emit(MyPlayerState(player: response.right, request: state.request));
    });
  }

  @override
  Future<void> close() {
    _requestSubscription?.cancel();
    _playerSubscription?.cancel();
    return super.close();
  }
}
