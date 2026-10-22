import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievement_usecase.dart';

class AchievementFormState extends Equatable {
  final AchievementDTO draft;
  final bool saving;

  /// Salvou: a tela avisa e fecha.
  final bool saved;

  /// Tentou salvar sem título.
  final bool missingTitle;
  final String? errorMessage;

  const AchievementFormState({
    required this.draft,
    this.saving = false,
    this.saved = false,
    this.missingTitle = false,
    this.errorMessage,
  });

  bool get isNew => draft.id.isEmpty;

  AchievementFormState copyWith({
    AchievementDTO? draft,
    bool? saving,
    bool? saved,
    bool? missingTitle,
    String? Function()? errorMessage,
  }) {
    return AchievementFormState(
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      missingTitle: missingTitle ?? this.missingTitle,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [draft, saving, saved, missingTitle, errorMessage];
}

/// Admin: cadastro/edição de uma conquista.
class AchievementFormCubit extends Cubit<AchievementFormState> {
  final SaveAchievementUseCase saveAchievementUseCase;

  /// [initial] nulo = conquista nova (vai para a posição [order]).
  AchievementFormCubit(this.saveAchievementUseCase, {AchievementDTO? initial, int order = 0})
      : super(AchievementFormState(
          draft: initial ?? AchievementDTO(title: '', metric: AchievementMetric.votes, order: order),
        ));

  void edit(AchievementDTO Function(AchievementDTO draft) change) {
    var draft = change(state.draft);
    // Métrica de sim/não: a meta é sempre 1.
    if (draft.metric?.isBoolean ?? false) draft = draft.copyWith(goal: 1);
    emit(state.copyWith(
      draft: draft,
      missingTitle: state.missingTitle && draft.title.trim().isEmpty,
      errorMessage: () => null,
    ));
  }

  Future<void> save() async {
    if (state.saving) return;
    final draft = state.draft.copyWith(title: state.draft.title.trim(), description: state.draft.description.trim());
    if (draft.title.isEmpty) {
      emit(state.copyWith(missingTitle: true));
      return;
    }
    emit(state.copyWith(draft: draft, saving: true, errorMessage: () => null));
    final response = await saveAchievementUseCase(draft);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, errorMessage: () => failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }
}
