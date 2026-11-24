import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/features/scoring/data/datasources/scoring_datasource.dart';
import 'package:arena_soccer/features/scoring/domain/repositories/scoring_repository_interface.dart';

class ScoringRepositoryImpl implements IScoringRepository {
  final ScoringDataSource _dataSource;

  ScoringRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, FantasyScoringTable>> watchFantasyTable() => _dataSource.watchFantasyTable();

  @override
  Stream<Either<Failure, PredictionRules>> watchPredictionRules() => _dataSource.watchPredictionRules();

  @override
  Future<Either<Failure, void>> saveFantasyTable(FantasyScoringTable table) => _dataSource.saveFantasyTable(table);

  @override
  Future<Either<Failure, void>> savePredictionRules(PredictionRules rules) => _dataSource.savePredictionRules(rules);
}
