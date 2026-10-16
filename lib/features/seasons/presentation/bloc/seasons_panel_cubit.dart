import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_cache_first_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/start_season_usecase.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/seasons_panel_state.dart';

class SeasonsPanelCubit extends Cubit<SeasonsPanelState> {
  final GetSeasonsConfigCacheFirstUseCase getSeasonsConfigCacheFirstUseCase;
  final StartSeasonUseCase startSeasonUseCase;

  SeasonsPanelCubit(this.getSeasonsConfigCacheFirstUseCase, this.startSeasonUseCase)
      : super(ReadySeasonsPanelState(current: SeasonCollection.currentSeason, seasons: SeasonCollection.seasons));

  /// Relê do Firestore ignorando a validade do cache (outro admin pode ter
  /// iniciado uma temporada); o cache aparece antes, se houver.
  Future<void> load() async {
    await for (final config in getSeasonsConfigCacheFirstUseCase(force: true)) {
      if (isClosed) return;
      emit(ReadySeasonsPanelState(current: config.current, seasons: config.seasons, copyTeams: state.copyTeams));
    }
  }

  void setCopyTeams(bool value) => emit(ReadySeasonsPanelState(
        current: state.current,
        seasons: state.seasons,
        copyTeams: value,
      ));

  Future<void> startNext() async {
    if (state is StartingSeasonsPanelState) return;
    emit(StartingSeasonsPanelState(state));
    final response = await startSeasonUseCase(copyTeams: state.copyTeams);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorSeasonsPanelState(state, errorMessage: failure.toString())),
      (config) => emit(StartedSeasonsPanelState(current: config.current, seasons: config.seasons)),
    );
  }
}
