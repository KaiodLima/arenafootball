import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_standings_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Classificação de um grupo em tempo real. O escudo vem do próprio registro
/// da classificação; quando falta, da coleção de times (mesma fonte dos grupos).
class StandingsCubit extends Cubit<StandingsState> {
  final WatchStandingsUseCase watchStandingsUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  StreamSubscription<Either<Failure, List<StandingDTO>>>? _subscription;
  Map<String, String> _crests = const {};

  StandingsCubit(this.watchStandingsUseCase, this.getTeamsUseCase) : super(const LoadingStandingsState());

  void watch({required String region, required String group, required String season}) {
    _subscription?.cancel();
    emit(LoadingStandingsState(standings: state.standings));
    _loadCrests(region: region, season: season);
    _subscription = watchStandingsUseCase(region: region, group: group, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorStandingsState(errorMessage: failure.toString(), standings: state.standings)),
        (standings) => emit(SuccessStandingsState(standings: _withCrests(standings))),
      );
    });
  }

  /// Escudos são só decoração: se falhar, a linha mostra o ícone padrão.
  Future<void> _loadCrests({required String region, required String season}) async {
    final response = await getTeamsUseCase(region: region, season: season);
    if (isClosed) return;
    response.fold((_) => null, (teams) {
      _crests = {
        for (final team in teams)
          if (team.imageUrl.isNotEmpty) normalizeTeamName(team.name): team.imageUrl,
      };
      final s = state;
      final standings = _withCrests(s.standings);
      if (s is SuccessStandingsState) emit(SuccessStandingsState(standings: standings));
    });
  }

  List<StandingDTO> _withCrests(List<StandingDTO> standings) => standings
      .map((s) => s.imageUrl.isNotEmpty ? s : s.copyWith(imageUrl: _crests[normalizeTeamName(s.teamName)] ?? ''))
      .toList();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
