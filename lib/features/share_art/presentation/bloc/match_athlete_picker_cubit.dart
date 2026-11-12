import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

class MatchAthletePickerState extends Equatable {
  /// Cada lado só deixa de carregar na 1ª resposta dele.
  final bool homeLoading;
  final bool awayLoading;
  final List<PlayerDTO> home;
  final List<PlayerDTO> away;

  const MatchAthletePickerState({
    this.homeLoading = true,
    this.awayLoading = true,
    this.home = const [],
    this.away = const [],
  });

  bool get loading => homeLoading && awayLoading;

  MatchAthletePickerState copyWith(
          {bool? homeLoading, bool? awayLoading, List<PlayerDTO>? home, List<PlayerDTO>? away}) =>
      MatchAthletePickerState(
        homeLoading: homeLoading ?? this.homeLoading,
        awayLoading: awayLoading ?? this.awayLoading,
        home: home ?? this.home,
        away: away ?? this.away,
      );

  @override
  List<Object?> get props => [homeLoading, awayLoading, home, away];
}

/// Elencos dos dois times da partida para o admin escolher o atleta da arte:
/// o **elenco geral** de cada time (todos os atletas, sem filtrar pela
/// competição), ao vivo — a resposta do servidor completa o que o cache do
/// aparelho ainda não tinha.
class MatchAthletePickerCubit extends Cubit<MatchAthletePickerState> {
  final WatchTeamPlayersUseCase _watchTeamPlayers;
  final List<StreamSubscription<Either<Failure, List<PlayerDTO>>>> _subscriptions = [];

  MatchAthletePickerCubit(this._watchTeamPlayers) : super(const MatchAthletePickerState());

  static List<PlayerDTO> _sorted(List<PlayerDTO> players) =>
      [...players]..sort((a, b) => foldForSearch(a.name).compareTo(foldForSearch(b.name)));

  void load(MatchDTO match, String season) {
    _subscriptions.add(
      _watchTeamPlayers(teamId: match.homeTeamId, teamName: match.homeTeam, season: season).listen((response) {
        if (isClosed) return;
        emit(state.copyWith(homeLoading: false, home: response.fold((_) => state.home, _sorted)));
      }),
    );
    _subscriptions.add(
      _watchTeamPlayers(teamId: match.awayTeamId, teamName: match.awayTeam, season: season).listen((response) {
        if (isClosed) return;
        emit(state.copyWith(awayLoading: false, away: response.fold((_) => state.away, _sorted)));
      }),
    );
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
