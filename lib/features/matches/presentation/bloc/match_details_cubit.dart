import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_match_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

/// Detalhes da partida: a partida ao vivo, os elencos dos dois lados (na
/// competição da partida) e o lado escolhido na seção "Elencos".
class MatchDetailsState extends Equatable {
  final MatchDTO match;
  final List<PlayerDTO> homeSquad;
  final List<PlayerDTO> awaySquad;
  final bool squadsLoading;
  final MatchSide selectedSide;

  /// A partida foi apagada enquanto a tela estava aberta.
  final bool deleted;
  final String? errorMessage;

  const MatchDetailsState({
    required this.match,
    this.homeSquad = const [],
    this.awaySquad = const [],
    this.squadsLoading = true,
    this.selectedSide = MatchSide.home,
    this.deleted = false,
    this.errorMessage,
  });

  List<PlayerDTO> squadOf(MatchSide side) => side == MatchSide.home ? homeSquad : awaySquad;

  /// Elenco do lado escolhido com os números da partida.
  List<MatchPlayerLine> get selectedLines => MatchPlayerLine.of(match.goals, squadOf(selectedSide));

  /// Atleta eleito (pelo nome gravado na partida), se estiver num dos elencos.
  PlayerDTO? get bestPlayer {
    final name = match.bestPlayer.trim().toLowerCase();
    if (name.isEmpty) return null;
    for (final p in [...homeSquad, ...awaySquad]) {
      if (p.name.trim().toLowerCase() == name) return p;
    }
    return null;
  }

  MatchDetailsState copyWith({
    MatchDTO? match,
    List<PlayerDTO>? homeSquad,
    List<PlayerDTO>? awaySquad,
    bool? squadsLoading,
    MatchSide? selectedSide,
    bool? deleted,
    String? Function()? errorMessage,
  }) {
    return MatchDetailsState(
      match: match ?? this.match,
      homeSquad: homeSquad ?? this.homeSquad,
      awaySquad: awaySquad ?? this.awaySquad,
      squadsLoading: squadsLoading ?? this.squadsLoading,
      selectedSide: selectedSide ?? this.selectedSide,
      deleted: deleted ?? this.deleted,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [match, homeSquad, awaySquad, squadsLoading, selectedSide, deleted, errorMessage];
}

class MatchDetailsCubit extends Cubit<MatchDetailsState> {
  final WatchMatchUseCase watchMatchUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final ToggleMatchVotingUseCase toggleMatchVotingUseCase;
  StreamSubscription? _subscription;
  String? _season;

  MatchDetailsCubit(
    this.watchMatchUseCase,
    this.watchTeamPlayersUseCase,
    this.toggleMatchVotingUseCase, {
    required MatchDTO match,
  }) : super(MatchDetailsState(match: match));

  /// Começa com a partida recebida da lista; o stream traz as mudanças.
  Future<void> start({String? season}) async {
    _season = season;
    final match = state.match;
    if (match.id.isNotEmpty) {
      _subscription = watchMatchUseCase(matchId: match.id, season: season).listen((response) {
        if (isClosed) return;
        response.fold(
          (failure) => emit(state.copyWith(errorMessage: () => failure.toString())),
          (updated) => emit(updated == null
              ? state.copyWith(deleted: true)
              : state.copyWith(match: updated, errorMessage: () => null)),
        );
      });
    }
    final home = watchTeamPlayersUseCase(teamId: match.homeTeamId, teamName: match.homeTeam, season: season).first;
    final away = watchTeamPlayersUseCase(teamId: match.awayTeamId, teamName: match.awayTeam, season: season).first;
    final homeResponse = await home;
    final awayResponse = await away;
    if (isClosed) return;
    // Elenco é complemento: se falhar, a seção fica vazia.
    emit(state.copyWith(
      homeSquad: homeResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.home)),
      awaySquad: awayResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.away)),
      squadsLoading: false,
    ));
  }

  void selectSide(MatchSide side) => emit(state.copyWith(selectedSide: side));

  /// Admin: abre/fecha a votação (o stream traz a partida nova).
  Future<void> toggleVoting() async {
    final response = await toggleMatchVotingUseCase(match: state.match, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.toString())),
      (updated) => emit(state.copyWith(match: updated, errorMessage: () => null)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
