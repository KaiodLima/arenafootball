import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/features/scoring/domain/repositories/scoring_repository_interface.dart';

/// Tabela padrão do Arena Fantasy (`config/pontuacao_fantasy`).
class WatchFantasyScoringTableUseCase {
  final IScoringRepository _repository;

  WatchFantasyScoringTableUseCase(this._repository);

  Stream<Either<Failure, FantasyScoringTable>> call() => _repository.watchFantasyTable();
}

/// Pontos do bolão (`config/bolao`).
class WatchPredictionRulesUseCase {
  final IScoringRepository _repository;

  WatchPredictionRulesUseCase(this._repository);

  Stream<Either<Failure, PredictionRules>> call() => _repository.watchPredictionRules();
}

/// Admin grava a tabela padrão do Fantasy (vale para as rodadas que fecharem depois).
class SaveFantasyScoringTableUseCase {
  final IScoringRepository _repository;

  SaveFantasyScoringTableUseCase(this._repository);

  Future<Either<Failure, void>> call(FantasyScoringTable table) => _repository.saveFantasyTable(table);
}

/// Admin grava os pontos do bolão (vale para as partidas que terminarem depois).
class SavePredictionRulesUseCase {
  final IScoringRepository _repository;

  SavePredictionRulesUseCase(this._repository);

  Future<Either<Failure, void>> call(PredictionRules rules) => _repository.savePredictionRules(rules);
}
