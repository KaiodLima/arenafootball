import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

/// Config de temporadas do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedSeasonsConfigUseCase {
  final ISeasonsRepository _repository;

  GetCachedSeasonsConfigUseCase(this._repository);

  Future<Either<Failure, CachedValue<SeasonsConfigDTO>?>> call() => _repository.getCachedConfig();
}
