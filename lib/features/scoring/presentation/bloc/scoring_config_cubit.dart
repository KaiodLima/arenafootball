import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/features/scoring/domain/usecases/scoring_usecases.dart';

class ScoringConfigState extends Equatable {
  /// Tabela padrão do Fantasy (a do campeonato sem tabela própria).
  final FantasyScoringTable fantasyTable;
  final PredictionRules predictionRules;

  const ScoringConfigState({
    this.fantasyTable = FantasyScoringTable.defaults,
    this.predictionRules = PredictionRules.defaults,
  });

  ScoringConfigState copyWith({FantasyScoringTable? fantasyTable, PredictionRules? predictionRules}) =>
      ScoringConfigState(
        fantasyTable: fantasyTable ?? this.fantasyTable,
        predictionRules: predictionRules ?? this.predictionRules,
      );

  @override
  List<Object?> get props => [fantasyTable, predictionRules];
}

/// Pontuações em vigor (global, criada na 1ª tela que precisa): a tabela
/// padrão do Fantasy e os pontos do bolão, em stream (dois docs pequenos).
/// Sem os docs ou com erro, os padrões do código.
class ScoringConfigCubit extends Cubit<ScoringConfigState> {
  final WatchFantasyScoringTableUseCase watchFantasyTable;
  final WatchPredictionRulesUseCase watchPredictionRules;
  final List<StreamSubscription<Object?>> _subs = [];

  ScoringConfigCubit(this.watchFantasyTable, this.watchPredictionRules) : super(const ScoringConfigState());

  void follow() {
    if (_subs.isNotEmpty) return;
    _subs.add(watchFantasyTable().listen((response) {
      if (response.isRight && !isClosed) emit(state.copyWith(fantasyTable: response.right));
    }));
    _subs.add(watchPredictionRules().listen((response) {
      if (response.isRight && !isClosed) emit(state.copyWith(predictionRules: response.right));
    }));
  }

  /// O estado em vigor (e reconstrói quando muda); sem o cubit na árvore
  /// (testes de widget), os padrões.
  static ScoringConfigState of(BuildContext context) {
    try {
      return context.watch<ScoringConfigCubit>().state;
    } catch (_) {
      return const ScoringConfigState();
    }
  }

  @override
  Future<void> close() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    return super.close();
  }
}
