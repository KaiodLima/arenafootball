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
    // Regiões antes da escolha salva: carregam o vínculo id ↔ nome, que
    // resolve a região salva pelo id (mesmo renomeada) e as consultas.
    final response = await getRegionsUseCase();
    final regions = response.fold((_) => const <String>[], (list) => list);
    final preferences = await getRegionPreferencesUseCase();
    final season = seasons.seasons.contains(preferences.season) ? preferences.season : seasons.current;

    // Região salva que não existe mais (excluída): a primeira da lista.
    var region = preferences.region;
    if (regions.isNotEmpty && !regions.contains(region)) region = regions.first;
    // Grava de novo: completa o id para quem só tinha o nome salvo.
    if (regions.contains(region)) await saveRegionUseCase(region);
    emit(state.copyWith(
      selectedRegion: region,
      selectedSeason: season,
      seasons: seasons.seasons,
      // Sem a lista, o seletor mostra só a região salva; não bloqueia o app.
      regions: regions.isEmpty ? [region] : regions,
    ));
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
