import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/cast_vote_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';

/// Votação de melhor jogador: elencos dos dois times em tempo real, escolha
/// de um jogador e envio do voto.
class VoteBestPlayerCubit extends Cubit<VoteBestPlayerState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final CastVoteUseCase castVoteUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _homeSubscription;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _awaySubscription;
  String _homeTeam = '';
  String _awayTeam = '';

  VoteBestPlayerCubit(this.watchTeamPlayersUseCase, this.castVoteUseCase) : super(const LoadingVoteBestPlayerState());

  void watch({required String homeTeam, required String awayTeam, required String season}) {
    _homeTeam = homeTeam;
    _awayTeam = awayTeam;
    _homeSubscription?.cancel();
    _awaySubscription?.cancel();
    emit(const LoadingVoteBestPlayerState());
    _homeSubscription = watchTeamPlayersUseCase(teamName: homeTeam, season: season).listen(
      (response) => _onPlayers(response, isHome: true),
    );
    _awaySubscription = watchTeamPlayersUseCase(teamName: awayTeam, season: season).listen(
      (response) => _onPlayers(response, isHome: false),
    );
  }

  void _onPlayers(Either<Failure, List<PlayerDTO>> response, {required bool isHome}) {
    response.fold(
      (failure) => emit(ErrorVoteBestPlayerState(
        errorMessage: failure.toString(),
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: state.selected,
      )),
      (players) => emit(ReadyVoteBestPlayerState(
        homePlayers: isHome ? players : state.homePlayers,
        awayPlayers: isHome ? state.awayPlayers : players,
        selected: state.selected,
      )),
    );
  }

  void select(PlayerDTO player) => emit(ReadyVoteBestPlayerState(
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: player,
      ));

  /// [voterId] vazio = convidado (o UseCase recusa).
  Future<void> vote({required String voterId}) async {
    if (state is SubmittingVoteBestPlayerState) return;
    final selected = state.selected;
    emit(SubmittingVoteBestPlayerState(
      homePlayers: state.homePlayers,
      awayPlayers: state.awayPlayers,
      selected: selected,
    ));

    final response = await castVoteUseCase(
      homeTeam: _homeTeam,
      awayTeam: _awayTeam,
      vote: VoteDTO(voterId: voterId, playerName: selected?.name ?? '', team: selected?.team ?? ''),
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorVoteBestPlayerState(
        errorMessage: failure.toString(),
        errorCode: failure is ErrorWithMessage ? failure.code : null,
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: selected,
      )),
      (_) => emit(SuccessVoteBestPlayerState(
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: selected,
      )),
    );
  }

  @override
  Future<void> close() {
    _homeSubscription?.cancel();
    _awaySubscription?.cancel();
    return super.close();
  }
}
