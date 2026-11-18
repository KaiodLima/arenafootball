import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/datasources/fantasy_datasource.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';

class FantasyRepositoryImpl implements IFantasyRepository {
  final FantasyDataSource _dataSource;

  FantasyRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) =>
      _dataSource.watchConfig(championship);

  @override
  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config) => _dataSource.saveConfig(config);
}
