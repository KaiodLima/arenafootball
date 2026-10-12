import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/start_season_usecase.dart';
import 'package:arena_soccer/features/seasons/presentation/bloc/seasons_panel_state.dart';

class SeasonsPanelCubit extends Cubit<SeasonsPanelState> {
  final GetSeasonsConfigUseCase getSeasonsConfigUseCase;
  final StartSeasonUseCase startSeasonUseCase;

  SeasonsPanelCubit(this.getSeasonsConfigUseCase, this.startSeasonUseCase)
      : super(ReadySeasonsPanelState(current: SeasonCollection.currentSeason, seasons: SeasonCollection.seasons));

  /// Relê do Firestore (outro admin pode ter iniciado uma temporada).
  Future<void> load() async {
    final config = await getSeasonsConfigUseCase();
    if (isClosed) return;
    emit(ReadySeasonsPanelState(current: config.current, seasons: config.seasons, copyTeams: state.copyTeams));
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
