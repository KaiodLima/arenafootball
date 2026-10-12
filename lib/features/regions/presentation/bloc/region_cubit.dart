import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_season_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';

class RegionCubit extends Cubit<RegionState> {
  final GetRegionsUseCase getRegionsUseCase;
  final GetRegionPreferencesUseCase getRegionPreferencesUseCase;
  final SaveRegionUseCase saveRegionUseCase;
  final SaveSeasonUseCase saveSeasonUseCase;
  final GetSeasonsConfigUseCase getSeasonsConfigUseCase;

  RegionCubit(
    this.getRegionsUseCase,
    this.getRegionPreferencesUseCase,
    this.saveRegionUseCase,
    this.saveSeasonUseCase,
    this.getSeasonsConfigUseCase,
  ) : super(const RegionState());

  Future<void> load() async {
    // Temporadas primeiro: a salva pelo usuário pode não existir mais na lista.
    final seasons = await getSeasonsConfigUseCase();
    final preferences = await getRegionPreferencesUseCase();
    final season = seasons.seasons.contains(preferences.season) ? preferences.season : seasons.current;
    emit(state.copyWith(selectedRegion: preferences.region, selectedSeason: season, seasons: seasons.seasons));

    final response = await getRegionsUseCase();
    response.fold(
      // Sem a lista, o seletor mostra só a região salva; não bloqueia o app.
      (_) => emit(state.copyWith(regions: [state.selectedRegion])),
      (regions) => emit(state.copyWith(regions: regions.isEmpty ? [state.selectedRegion] : regions)),
    );
  }

  Future<void> selectRegion(String region) async {
    emit(state.copyWith(selectedRegion: region));
    await saveRegionUseCase(region);
  }

  /// Depois que o admin inicia uma temporada: lista nova e a atual selecionada.
  Future<void> reloadSeasons() async {
    final seasons = await getSeasonsConfigUseCase();
    await selectSeason(seasons.current);
    emit(state.copyWith(seasons: seasons.seasons));
  }

  Future<void> selectSeason(String season) async {
    emit(state.copyWith(selectedSeason: season));
    await saveSeasonUseCase(season);
  }
}
