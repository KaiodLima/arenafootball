import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';
import 'package:arena_soccer/features/scoring/domain/usecases/scoring_usecases.dart';

/// Resultado do salvar (snackbar).
enum ScoringSaveResult { none, saved, failed }

class ScoringSettingsState extends Equatable {
  final bool loaded;
  final FantasyScoringTable savedFantasy;
  final FantasyScoringTable draftFantasy;
  final PredictionRules savedBolao;
  final PredictionRules draftBolao;
  final bool saving;
  final ScoringSaveResult result;
  final String? failure;

  const ScoringSettingsState({
    this.loaded = false,
    this.savedFantasy = FantasyScoringTable.defaults,
    this.draftFantasy = FantasyScoringTable.defaults,
    this.savedBolao = PredictionRules.defaults,
    this.draftBolao = PredictionRules.defaults,
    this.saving = false,
    this.result = ScoringSaveResult.none,
    this.failure,
  });

  bool get fantasyDirty => draftFantasy != savedFantasy;
  bool get bolaoDirty => draftBolao != savedBolao;

  ScoringSettingsState copyWith({
    bool? loaded,
    FantasyScoringTable? savedFantasy,
    FantasyScoringTable? draftFantasy,
    PredictionRules? savedBolao,
    PredictionRules? draftBolao,
    bool? saving,
    ScoringSaveResult? result,
    String? failure,
  }) =>
      ScoringSettingsState(
        loaded: loaded ?? this.loaded,
        savedFantasy: savedFantasy ?? this.savedFantasy,
        draftFantasy: draftFantasy ?? this.draftFantasy,
        savedBolao: savedBolao ?? this.savedBolao,
        draftBolao: draftBolao ?? this.draftBolao,
        saving: saving ?? this.saving,
        result: result ?? ScoringSaveResult.none,
        failure: failure,
      );

  @override
  List<Object?> get props => [loaded, savedFantasy, draftFantasy, savedBolao, draftBolao, saving, result, failure];
}

/// Painel do admin → "Pontuações": a tabela padrão do Arena Fantasy e os
/// pontos do bolão. Vale para o que for apurado depois (as rodadas e os
/// palpites já pontuados guardam a tabela deles).
class ScoringSettingsCubit extends Cubit<ScoringSettingsState> {
  final WatchFantasyScoringTableUseCase _watchFantasy;
  final WatchPredictionRulesUseCase _watchBolao;
  final SaveFantasyScoringTableUseCase _saveFantasy;
  final SavePredictionRulesUseCase _saveBolao;

  ScoringSettingsCubit(this._watchFantasy, this._watchBolao, this._saveFantasy, this._saveBolao)
      : super(const ScoringSettingsState());

  /// Os valores atuais (a 1ª resposta de cada doc).
  Future<void> load() async {
    final fantasy = await _watchFantasy().first;
    final bolao = await _watchBolao().first;
    if (isClosed) return;
    final table = fantasy.isRight ? fantasy.right : FantasyScoringTable.defaults;
    final rules = bolao.isRight ? bolao.right : PredictionRules.defaults;
    emit(state.copyWith(
      loaded: true,
      savedFantasy: table,
      draftFantasy: table,
      savedBolao: rules,
      draftBolao: rules,
      failure: fantasy.isLeft ? fantasy.left.toString() : (bolao.isLeft ? bolao.left.toString() : null),
    ));
  }

  void editFantasy(FantasyScoringTable Function(FantasyScoringTable draft) change) =>
      emit(state.copyWith(draftFantasy: change(state.draftFantasy)));

  /// Bolão: sobe/desce mantendo exato ≥ saldo ≥ vencedor.
  void editBolao(PredictionRules Function(PredictionRules draft) change) {
    final next = change(state.draftBolao);
    if (!next.isValid) return;
    emit(state.copyWith(draftBolao: next));
  }

  void restoreFantasyDefaults() => emit(state.copyWith(draftFantasy: FantasyScoringTable.defaults));

  void restoreBolaoDefaults() => emit(state.copyWith(draftBolao: PredictionRules.defaults));

  Future<void> saveFantasy() async {
    if (state.saving || !state.fantasyDirty) return;
    emit(state.copyWith(saving: true));
    final draft = state.draftFantasy;
    final response = await _saveFantasy(draft);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, result: ScoringSaveResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(saving: false, savedFantasy: draft, result: ScoringSaveResult.saved)),
    );
  }

  Future<void> saveBolao() async {
    if (state.saving || !state.bolaoDirty) return;
    emit(state.copyWith(saving: true));
    final draft = state.draftBolao;
    final response = await _saveBolao(draft);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, result: ScoringSaveResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(saving: false, savedBolao: draft, result: ScoringSaveResult.saved)),
    );
  }
}
