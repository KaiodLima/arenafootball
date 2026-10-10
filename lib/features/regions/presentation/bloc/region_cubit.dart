import 'package:flutter_bloc/flutter_bloc.dart';
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

  RegionCubit(
    this.getRegionsUseCase,
    this.getRegionPreferencesUseCase,
    this.saveRegionUseCase,
    this.saveSeasonUseCase,
  ) : super(const RegionState());

  Future<void> load() async {
    final preferences = await getRegionPreferencesUseCase();
    emit(state.copyWith(selectedRegion: preferences.region, selectedSeason: preferences.season));

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

  Future<void> selectSeason(String season) async {
    emit(state.copyWith(selectedSeason: season));
    await saveSeasonUseCase(season);
  }
}
