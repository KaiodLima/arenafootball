import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';

abstract class IMaintenanceRepository {
  Stream<Either<Failure, RecompressStatusDTO>> watchRecompress();

  Future<Either<Failure, void>> requestRecompress();
}
