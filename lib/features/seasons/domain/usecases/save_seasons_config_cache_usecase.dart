import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

class SaveSeasonsConfigCacheUseCase {
  final ISeasonsRepository _repository;

  SaveSeasonsConfigCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(SeasonsConfigDTO config) => _repository.saveConfigCache(config);
}
