import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';
import 'package:arena_soccer/features/maintenance/domain/repositories/maintenance_repository_interface.dart';

/// Recompressão das imagens antigas do Storage: acompanhar e pedir.
class RecompressImagesUseCase {
  final IMaintenanceRepository _repository;

  RecompressImagesUseCase(this._repository);

  Stream<Either<Failure, RecompressStatusDTO>> watch() => _repository.watchRecompress();

  Future<Either<Failure, void>> request() => _repository.requestRecompress();
}
