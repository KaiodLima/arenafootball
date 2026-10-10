import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class SaveSeasonUseCase {
  final IRegionsRepository _repository;

  SaveSeasonUseCase(this._repository);

  Future<void> call(String season) => _repository.saveSeason(season);
}
