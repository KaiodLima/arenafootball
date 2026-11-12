import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

class MatchAthletePickerState extends Equatable {
  final bool loading;
  final List<PlayerDTO> home;
  final List<PlayerDTO> away;

  const MatchAthletePickerState({this.loading = true, this.home = const [], this.away = const []});

  @override
  List<Object?> get props => [loading, home, away];
}

/// Elencos dos dois times da partida (admin escolhe o atleta da arte): uma
/// leitura de cada (a mesma da folha de gols), filtrada pela competição.
class MatchAthletePickerCubit extends Cubit<MatchAthletePickerState> {
  final WatchTeamPlayersUseCase _watchTeamPlayers;

  MatchAthletePickerCubit(this._watchTeamPlayers) : super(const MatchAthletePickerState());

  Future<void> load(MatchDTO match, String season) async {
    final home = _watchTeamPlayers(teamId: match.homeTeamId, teamName: match.homeTeam, season: season).first;
    final away = _watchTeamPlayers(teamId: match.awayTeamId, teamName: match.awayTeam, season: season).first;
    final homeResponse = await home;
    final awayResponse = await away;
    if (isClosed) return;
    emit(MatchAthletePickerState(
      loading: false,
      home: homeResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.home)),
      away: awayResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.away)),
    ));
  }
}
