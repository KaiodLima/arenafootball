import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

class DeleteSeasonsConfigCacheUseCase {
  final ISeasonsRepository _repository;

  DeleteSeasonsConfigCacheUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.deleteConfigCache();
}
