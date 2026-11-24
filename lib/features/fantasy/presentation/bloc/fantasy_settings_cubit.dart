import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_settings.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';

/// Resultado do último "Salvar" (para o snackbar).
enum FantasySaveResult { none, saved, failed }

class FantasySettingsState extends Equatable {
  /// O que está gravado (nulo enquanto carrega).
  final FantasyConfigDTO? saved;

  /// O rascunho editado na tela.
  final FantasyConfigDTO? draft;
  final bool saving;
  final FantasySaveResult result;
  final String? failure;

  const FantasySettingsState({
    this.saved,
    this.draft,
    this.saving = false,
    this.result = FantasySaveResult.none,
    this.failure,
  });

  bool get loading => draft == null;

  bool get dirty => draft != null && draft != saved;

  FantasySettingsError? get error => draft == null
      ? null
      : FantasySettings.validate(
          minMinutes: draft!.minMinutes,
          minDefenseMinutes: draft!.minDefenseMinutes,
          captainMultiplier: draft!.captainMultiplier,
        );

  FantasySettingsState copyWith({
    FantasyConfigDTO? saved,
    FantasyConfigDTO? draft,
    bool? saving,
    FantasySaveResult? result,
    String? failure,
  }) =>
      FantasySettingsState(
        saved: saved ?? this.saved,
        draft: draft ?? this.draft,
        saving: saving ?? this.saving,
        result: result ?? FantasySaveResult.none,
        failure: failure,
      );

  @override
  List<Object?> get props => [saved, draft, saving, result, failure];
}

/// Admin → Arena Fantasy do campeonato: liga/desliga e os parâmetros
/// (tempo mínimo para pontuar, para o bônus defensivo e o capitão).
class FantasySettingsCubit extends Cubit<FantasySettingsState> {
  final WatchFantasyConfigUseCase _watch;
  final SaveFantasyConfigUseCase _save;

  FantasySettingsCubit(this._watch, this._save) : super(const FantasySettingsState());

  StreamSubscription<Object?>? _subscription;

  void load(ChampionshipDTO championship) {
    _subscription?.cancel();
    _subscription = _watch(championship).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) {
          // Sem a config: os padrões (a tela continua utilizável).
          if (state.draft == null) {
            final fallback = FantasyConfigDTO.forChampionship(championship);
            emit(state.copyWith(saved: fallback, draft: fallback, failure: failure.toString()));
          }
        },
        (config) {
          // Mudança vinda do servidor só troca o rascunho se não houver edição.
          final keepDraft = state.dirty && !state.saving;
          emit(state.copyWith(saved: config, draft: keepDraft ? state.draft : config));
        },
      );
    });
  }

  void _edit(FantasyConfigDTO Function(FantasyConfigDTO draft) change) {
    final draft = state.draft;
    if (draft == null || state.saving) return;
    emit(state.copyWith(draft: change(draft)));
  }

  void setActive(bool active) => _edit((d) => d.copyWith(active: active));

  void setMinMinutes(int minutes) => _edit((d) => d.copyWith(minMinutes: minutes.clamp(0, FantasyLimits.maxMinutes)));

  void setDefenseMinutes(int minutes) =>
      _edit((d) => d.copyWith(minDefenseMinutes: minutes.clamp(0, FantasyLimits.maxMinutes)));

  void setCaptain(double value) => _edit((d) => d.copyWith(
        captainMultiplier:
            FantasySettings.roundCaptain(value).clamp(FantasyLimits.minCaptain, FantasyLimits.maxCaptain).toDouble(),
      ));

  void restoreDefaults() => _edit((d) => d.withDefaults());

  /// Tabela própria do campeonato: ligada começa pela [base] (a padrão em
  /// vigor); desligada volta à padrão.
  void setOwnTable(bool own, FantasyScoringTable base) =>
      _edit((d) => d.withScoringTable(own ? (d.scoringTable ?? base) : null));

  void editTable(FantasyScoringTable table) => _edit((d) => d.withScoringTable(table));

  Future<void> save() async {
    final draft = state.draft;
    if (draft == null || state.saving || state.error != null) return;
    emit(state.copyWith(saving: true));
    final response = await _save(draft);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, result: FantasySaveResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: draft, result: FantasySaveResult.saved)),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
