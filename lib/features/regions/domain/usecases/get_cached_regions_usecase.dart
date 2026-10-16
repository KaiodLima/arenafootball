import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

/// Regiões do cache local (nunca falha: sem cache = `Right(null)`). Achando,
/// já carrega o `RegionRegistry`.
class GetCachedRegionsUseCase {
  final IRegionsRepository _repository;

  GetCachedRegionsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<RegionRef>>?>> call() => _repository.getCachedRegions();
}
