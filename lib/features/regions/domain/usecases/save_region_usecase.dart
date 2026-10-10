import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class SaveRegionUseCase {
  final IRegionsRepository _repository;

  SaveRegionUseCase(this._repository);

  Future<void> call(String region) => _repository.saveRegion(region);
}
