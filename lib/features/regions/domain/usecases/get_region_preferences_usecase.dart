import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

/// Região e temporada salvas pelo usuário, e as regiões escolhidas por último.
class RegionPreferences {
  final String region;
  final String season;
  final List<String> recent;

  const RegionPreferences({required this.region, required this.season, this.recent = const []});
}

class GetRegionPreferencesUseCase {
  /// Região usada quando o usuário nunca escolheu uma.
  static const String defaultRegion = 'Floresta';

  final IRegionsRepository _repository;

  GetRegionPreferencesUseCase(this._repository);

  Future<RegionPreferences> call() async {
    final region = await _repository.getSavedRegion();
    final season = await _repository.getSavedSeason();
    final recent = await _repository.getRecentRegions();
    return RegionPreferences(
      recent: recent,
      region: (region == null || region.isEmpty) ? defaultRegion : region,
      season: (season == null || season.isEmpty) ? SeasonCollection.defaultSeason : season,
    );
  }
}
