import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_voting_rules_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/save_voting_rules_usecase.dart';

/// Tela "Regras da votação" (admin): os valores em edição e o andamento.
class VotingRulesState extends Equatable {
  final VotingRulesDTO rules;
  final bool loading;
  final bool saving;

  /// Salvou: a tela avisa e fecha.
  final bool saved;
  final String? errorMessage;

  const VotingRulesState({
    this.rules = const VotingRulesDTO(),
    this.loading = true,
    this.saving = false,
    this.saved = false,
    this.errorMessage,
  });

  VotingRulesState copyWith({
    VotingRulesDTO? rules,
    bool? loading,
    bool? saving,
    bool? saved,
    String? Function()? errorMessage,
  }) {
    return VotingRulesState(
      rules: rules ?? this.rules,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [rules, loading, saving, saved, errorMessage];
}

class VotingRulesCubit extends Cubit<VotingRulesState> {
  final GetVotingRulesCacheFirstUseCase getVotingRulesCacheFirstUseCase;
  final SaveVotingRulesUseCase saveVotingRulesUseCase;

  static const int maxVotes = 500;

  VotingRulesCubit(this.getVotingRulesCacheFirstUseCase, this.saveVotingRulesUseCase) : super(const VotingRulesState());

  /// Lê do servidor (o admin vê o valor atual, não o do cache).
  Future<void> load() async {
    final response = await getVotingRulesCacheFirstUseCase(force: true).last;
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(loading: false, errorMessage: () => failure.toString())),
      (rules) => emit(state.copyWith(rules: rules, loading: false)),
    );
  }

  void changeMinVotes(int value) => emit(state.copyWith(
        rules: VotingRulesDTO(minVotes: value.clamp(1, maxVotes), minPercent: state.rules.minPercent),
        errorMessage: () => null,
      ));

  void changeMinPercent(int value) => emit(state.copyWith(
        rules: VotingRulesDTO(minVotes: state.rules.minVotes, minPercent: value.clamp(1, 100)),
        errorMessage: () => null,
      ));

  Future<void> save() async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, errorMessage: () => null));
    final response = await saveVotingRulesUseCase(state.rules);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, errorMessage: () => failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }
}
