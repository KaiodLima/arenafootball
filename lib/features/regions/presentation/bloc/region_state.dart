import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';

/// Região e temporada selecionadas. São globais: toda tela que filtra por
/// região/ano lê daqui em vez de receber por construtor.
class RegionState extends Equatable {
  final List<String> regions;
  final String selectedRegion;
  final String selectedSeason;
  final List<String> seasons;

  const RegionState({
    this.regions = const [],
    this.selectedRegion = GetRegionPreferencesUseCase.defaultRegion,
    this.selectedSeason = SeasonCollection.defaultSeason,
    this.seasons = SeasonCollection.seasons,
  });

  RegionState copyWith({List<String>? regions, String? selectedRegion, String? selectedSeason}) {
    return RegionState(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      seasons: seasons,
    );
  }

  @override
  List<Object?> get props => [regions, selectedRegion, selectedSeason, seasons];
}
