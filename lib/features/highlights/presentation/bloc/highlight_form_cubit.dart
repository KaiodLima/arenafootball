import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';

/// Cadastro/edição de destaque: carrega os existentes (prévia e duplicado)
/// e publica ou salva.
class HighlightFormCubit extends Cubit<HighlightFormState> {
  final CreateHighlightUseCase createHighlightUseCase;
  final GetHighlightsUseCase getHighlightsUseCase;
  final UpdateHighlightUseCase updateHighlightUseCase;

  HighlightFormCubit(this.createHighlightUseCase, this.getHighlightsUseCase, this.updateHighlightUseCase)
      : super(const EditingHighlightFormState());

  void _edit(HighlightFormData form) {
    if (!isClosed) emit(EditingHighlightFormState(form: form));
  }

  /// Falhar só deixa a prévia sem os existentes (e sem checar duplicado).
  Future<void> load({HighlightDTO? highlight}) async {
    if (highlight != null) _edit(HighlightFormData.editing(highlight));
    final response = await getHighlightsUseCase();
    if (response.isRight) _edit(state.form.copyWith(existing: response.right));
  }

  void changeTitle(String value) => _edit(state.form.copyWith(title: value));

  void changeLink(String value) => _edit(state.form.copyWith(link: value));

  void changeVisible(bool value) => _edit(state.form.copyWith(isVisible: value));

  void setImage(File file) => _edit(state.form.copyWith(image: file, imageRemoved: false));

  /// Sem foto nova escolhida, remove a foto salva (edição).
  void clearImage() {
    final form = state.form;
    _edit(form.image != null ? form.copyWith(clearImage: true) : form.copyWith(imageRemoved: true));
  }

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingHighlightFormState) return;
    emit(SubmittingHighlightFormState(form: form));

    final original = form.original;
    final response = original == null
        ? await createHighlightUseCase(highlight: form.toHighlight(), image: form.image)
        : await updateHighlightUseCase(highlight: form.toHighlight(), oldTitle: original.title, image: form.image);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorHighlightFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessHighlightFormState(form: form)),
    );
  }
}
