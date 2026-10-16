import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/cast_vote_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_my_vote_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/vote_best_player_state.dart';

/// Votação de melhor jogador: elencos dos dois times em tempo real, o voto
/// atual do usuário (pré-selecionado), escolha de um jogador e envio do voto.
/// Também guarda o time exibido, a busca e os escudos.
class VoteBestPlayerCubit extends Cubit<VoteBestPlayerState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final CastVoteUseCase castVoteUseCase;
  final GetMyVoteUseCase getMyVoteUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _homeSubscription;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _awaySubscription;
  MatchVoteRef _ref = const MatchVoteRef(matchId: '', season: '', homeTeam: '', awayTeam: '');

  /// O voto atual só pré-seleciona uma vez (depois o usuário manda).
  bool _preselected = false;

  VoteBestPlayerCubit(
    this.watchTeamPlayersUseCase,
    this.castVoteUseCase,
    this.getMyVoteUseCase,
    this.getTeamsCacheFirstUseCase,
  ) : super(const LoadingVoteBestPlayerState());

  /// [voterId] vazio = convidado (não tem voto atual).
  void watch({required MatchDTO match, required String season, required String voterId}) {
    _ref = MatchVoteRef.of(match, season);
    _preselected = false;
    _homeSubscription?.cancel();
    _awaySubscription?.cancel();
    emit(const LoadingVoteBestPlayerState());
    _loadCrests(season: season);
    _loadMyVote(voterId: voterId);
    _homeSubscription =
        watchTeamPlayersUseCase(teamId: _ref.homeTeamId, teamName: _ref.homeTeam, season: season).listen(
      (response) => _onPlayers(response, isHome: true),
    );
    _awaySubscription =
        watchTeamPlayersUseCase(teamId: _ref.awayTeamId, teamName: _ref.awayTeam, season: season).listen(
      (response) => _onPlayers(response, isHome: false),
    );
  }

  /// Escudos são só decoração: se falhar, fica o ícone padrão.
  Future<void> _loadCrests({required String season}) async {
    await for (final response in getTeamsCacheFirstUseCase(season: season)) {
      if (isClosed) return;
      if (response.isLeft) continue;
      final directory = TeamDirectory(response.right);
      _emitSame(
        homeCrest: directory.resolve(id: _ref.homeTeamId, name: _ref.homeTeam)?.imageUrl ?? '',
        awayCrest: directory.resolve(id: _ref.awayTeamId, name: _ref.awayTeam)?.imageUrl ?? '',
      );
    }
  }

  /// Falhar ao ler o voto atual não impede votar: só não mostra o selo.
  Future<void> _loadMyVote({required String voterId}) async {
    final response = await getMyVoteUseCase(ref: _ref, voterId: voterId);
    if (isClosed || response.isLeft || response.right == null) return;
    _emitSame(myVote: response.right);
    _preselectMyVote();
  }

  void _onPlayers(Either<Failure, List<PlayerDTO>> response, {required bool isHome}) {
    response.fold(
      (failure) => emit(_error(failure)),
      (players) {
        emit(ReadyVoteBestPlayerState(
          homePlayers: isHome ? players : state.homePlayers,
          awayPlayers: isHome ? state.awayPlayers : players,
          selected: state.selected,
          myVote: state.myVote,
          showAway: state.showAway,
          query: state.query,
          homeCrest: state.homeCrest,
          awayCrest: state.awayCrest,
        ));
        _preselectMyVote();
      },
    );
  }

  /// Marca o jogador do voto atual e abre no time dele, assim que o voto e o
  /// elenco correspondente estiverem carregados.
  void _preselectMyVote() {
    final vote = state.myVote;
    if (_preselected || vote == null || state.selected != null) return;
    final isAway = sameTeam(idA: vote.teamId, nameA: vote.team, idB: _ref.awayTeamId, nameB: _ref.awayTeam);
    final squad = isAway ? state.awayPlayers : state.homePlayers;
    for (final player in squad) {
      if (player.name == vote.playerName &&
          sameTeam(idA: player.teamId, nameA: player.team, idB: vote.teamId, nameB: vote.team)) {
        _preselected = true;
        emit(_ready(selected: player, showAway: isAway));
        return;
      }
    }
  }

  void select(PlayerDTO player) => emit(_ready(selected: player));

  void setShowAway(bool showAway) {
    if (showAway == state.showAway) return;
    emit(_ready(showAway: showAway, query: ''));
  }

  void setQuery(String query) => emit(_ready(query: query));

  /// [voterId] vazio = convidado (o UseCase recusa).
  Future<void> vote({required String voterId}) async {
    if (state is SubmittingVoteBestPlayerState) return;
    final selected = state.selected;
    emit(SubmittingVoteBestPlayerState(
      homePlayers: state.homePlayers,
      awayPlayers: state.awayPlayers,
      selected: selected,
      myVote: state.myVote,
      showAway: state.showAway,
      query: state.query,
      homeCrest: state.homeCrest,
      awayCrest: state.awayCrest,
    ));

    final vote = VoteDTO(
      voterId: voterId,
      playerName: selected?.name ?? '',
      team: selected?.team ?? '',
      teamId: selected?.teamId ?? '',
    );
    final response = await castVoteUseCase(ref: _ref, vote: vote);
    if (isClosed) return;
    response.fold(
      (failure) => emit(_error(failure)),
      (_) => emit(SuccessVoteBestPlayerState(
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: selected,
        myVote: vote,
        showAway: state.showAway,
        query: state.query,
        homeCrest: state.homeCrest,
        awayCrest: state.awayCrest,
      )),
    );
  }

  /// Estado "pronto" com os campos trocados; os demais vêm do atual.
  ReadyVoteBestPlayerState _ready({PlayerDTO? selected, bool? showAway, String? query}) => ReadyVoteBestPlayerState(
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: selected ?? state.selected,
        myVote: state.myVote,
        showAway: showAway ?? state.showAway,
        query: query ?? state.query,
        homeCrest: state.homeCrest,
        awayCrest: state.awayCrest,
      );

  ErrorVoteBestPlayerState _error(Failure failure) => ErrorVoteBestPlayerState(
        errorMessage: failure.toString(),
        errorCode: failure is ErrorWithMessage ? failure.code : null,
        homePlayers: state.homePlayers,
        awayPlayers: state.awayPlayers,
        selected: state.selected,
        myVote: state.myVote,
        showAway: state.showAway,
        query: state.query,
        homeCrest: state.homeCrest,
        awayCrest: state.awayCrest,
      );

  /// Reemite o estado atual (mesmo tipo) com escudos/voto atualizados. Erro
  /// já mostrado vira "pronto" para não repetir o snackbar.
  void _emitSame({String? homeCrest, String? awayCrest, VoteDTO? myVote}) {
    final s = state;
    final homePlayers = s.homePlayers;
    final awayPlayers = s.awayPlayers;
    final crestHome = homeCrest ?? s.homeCrest;
    final crestAway = awayCrest ?? s.awayCrest;
    final vote = myVote ?? s.myVote;
    emit(s is LoadingVoteBestPlayerState
        ? LoadingVoteBestPlayerState(
            homePlayers: homePlayers,
            awayPlayers: awayPlayers,
            selected: s.selected,
            myVote: vote,
            showAway: s.showAway,
            query: s.query,
            homeCrest: crestHome,
            awayCrest: crestAway,
          )
        : ReadyVoteBestPlayerState(
            homePlayers: homePlayers,
            awayPlayers: awayPlayers,
            selected: s.selected,
            myVote: vote,
            showAway: s.showAway,
            query: s.query,
            homeCrest: crestHome,
            awayCrest: crestAway,
          ));
  }

  @override
  Future<void> close() {
    _homeSubscription?.cancel();
    _awaySubscription?.cancel();
    return super.close();
  }
}
