import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class SaveRegionsCacheUseCase {
  final IRegionsRepository _repository;

  SaveRegionsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<RegionRef> regions) => _repository.saveRegionsCache(regions);
}
