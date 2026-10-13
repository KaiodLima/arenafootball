import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_elected_player_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_state.dart';

/// Apura a votação de uma partida e carrega o eleito.
class ElectedPlayerCubit extends Cubit<ElectedPlayerState> {
  final GetElectedPlayerUseCase getElectedPlayerUseCase;

  ElectedPlayerCubit(this.getElectedPlayerUseCase) : super(const LoadingElectedPlayerState());

  Future<void> load({required MatchDTO match, required String season}) async {
    emit(const LoadingElectedPlayerState());
    final response = await getElectedPlayerUseCase(MatchVoteRef.of(match, season));
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorElectedPlayerState(errorMessage: failure.toString())),
      (result) => emit(SuccessElectedPlayerState(result: result)),
    );
  }
}
