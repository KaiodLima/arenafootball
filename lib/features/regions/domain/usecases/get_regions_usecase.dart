import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class GetRegionsUseCase {
  final IRegionsRepository _repository;

  GetRegionsUseCase(this._repository);

  Future<Either<Failure, List<String>>> call() => _repository.getRegions();
}
