import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class DeleteRegionsCacheUseCase {
  final IRegionsRepository _repository;

  DeleteRegionsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.deleteRegionsCache();
}
