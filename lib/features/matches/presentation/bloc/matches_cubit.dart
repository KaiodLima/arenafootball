import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delete_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_state.dart';

/// Partidas de um campeonato em tempo real + ações do admin (placar,
/// abrir/fechar votação, excluir). As ações gravam na mesma temporada da
/// lista; o stream traz a atualização.
class MatchesCubit extends Cubit<MatchesState> {
  final WatchMatchesUseCase watchMatchesUseCase;
  final UpdateMatchScoreUseCase updateMatchScoreUseCase;
  final ToggleMatchVotingUseCase toggleMatchVotingUseCase;
  final DeleteMatchUseCase deleteMatchUseCase;
  StreamSubscription<Either<Failure, List<MatchDTO>>>? _subscription;
  String? _season;

  MatchesCubit(
    this.watchMatchesUseCase,
    this.updateMatchScoreUseCase,
    this.toggleMatchVotingUseCase,
    this.deleteMatchUseCase,
  ) : super(const LoadingMatchesState());

  void watch({required int championshipId, required MatchesFilter filter, required String season}) {
    _season = season;
    _subscription?.cancel();
    emit(LoadingMatchesState(matches: state.matches));
    _subscription = watchMatchesUseCase(championshipId: championshipId, filter: filter, season: season).listen(
      (response) {
        response.fold(
          (failure) => emit(ErrorMatchesState(errorMessage: failure.toString(), matches: state.matches)),
          (matches) => emit(SuccessMatchesState(matches: matches)),
        );
      },
    );
  }

  Future<void> updateScore(MatchDTO match, {required String homeGoals, required String awayGoals}) async {
    final response = await updateMatchScoreUseCase(
      match: match,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      season: _season,
    );
    _emitIfFailed(response);
  }

  Future<void> toggleVoting(MatchDTO match) async {
    _emitIfFailed(await toggleMatchVotingUseCase(match: match, season: _season));
  }

  Future<void> delete(MatchDTO match) async {
    _emitIfFailed(await deleteMatchUseCase(matchId: match.id, season: _season));
  }

  void _emitIfFailed(Either<Failure, Object?> response) {
    if (isClosed || response.isRight) return;
    emit(ErrorMatchesState(errorMessage: response.left.toString(), matches: state.matches));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
