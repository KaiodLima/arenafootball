import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/data/datasources/seasons_datasource.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';

class SeasonsRepositoryImpl implements ISeasonsRepository {
  final SeasonsDataSource _dataSource;

  SeasonsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig() => _dataSource.getConfig();

  @override
  Future<Either<Failure, SeasonsConfigDTO>> startSeason({
    required String season,
    required List<String> seasons,
    String? copyTeamsFrom,
  }) =>
      _dataSource.startSeason(season: season, seasons: seasons, copyTeamsFrom: copyTeamsFrom);
}
