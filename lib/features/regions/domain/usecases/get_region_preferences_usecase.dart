import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

/// Região e temporada salvas pelo usuário.
class RegionPreferences {
  final String region;
  final String season;

  const RegionPreferences({required this.region, required this.season});
}

class GetRegionPreferencesUseCase {
  /// Região usada quando o usuário nunca escolheu uma.
  static const String defaultRegion = 'Floresta';

  final IRegionsRepository _repository;

  GetRegionPreferencesUseCase(this._repository);

  Future<RegionPreferences> call() async {
    final region = await _repository.getSavedRegion();
    final season = await _repository.getSavedSeason();
    return RegionPreferences(
      region: (region == null || region.isEmpty) ? defaultRegion : region,
      season: (season == null || season.isEmpty) ? SeasonCollection.defaultSeason : season,
    );
  }
}
