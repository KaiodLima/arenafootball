import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/maintenance/data/datasources/maintenance_datasource.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';
import 'package:arena_soccer/features/maintenance/domain/repositories/maintenance_repository_interface.dart';

class MaintenanceRepositoryImpl implements IMaintenanceRepository {
  final MaintenanceDataSource _dataSource;

  MaintenanceRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, RecompressStatusDTO>> watchRecompress() => _dataSource.watchRecompress();

  @override
  Future<Either<Failure, void>> requestRecompress() => _dataSource.requestRecompress();
}
