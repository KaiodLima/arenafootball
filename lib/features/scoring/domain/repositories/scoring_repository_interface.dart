import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';

abstract class IScoringRepository {
  Stream<Either<Failure, FantasyScoringTable>> watchFantasyTable();

  Stream<Either<Failure, PredictionRules>> watchPredictionRules();

  Future<Either<Failure, void>> saveFantasyTable(FantasyScoringTable table);

  Future<Either<Failure, void>> savePredictionRules(PredictionRules rules);
}
