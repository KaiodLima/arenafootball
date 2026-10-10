import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';

class HighlightFormCubit extends Cubit<HighlightFormState> {
  final CreateHighlightUseCase createHighlightUseCase;

  HighlightFormCubit(this.createHighlightUseCase) : super(const EditingHighlightFormState());

  void _edit(HighlightFormData form) => emit(EditingHighlightFormState(form: form));

  void changeTitle(String value) => _edit(state.form.copyWith(title: value));

  void changeLink(String value) => _edit(state.form.copyWith(link: value));

  void changeVisible(bool value) => _edit(state.form.copyWith(isVisible: value));

  void setImage(File file) => _edit(state.form.copyWith(image: file));

  Future<void> submit() async {
    final form = state.form;
    if (!form.isTitleValid || state is SubmittingHighlightFormState) return;
    emit(SubmittingHighlightFormState(form: form));

    final response = await createHighlightUseCase(highlight: form.toHighlight(), image: form.image);
    response.fold(
      (failure) => emit(ErrorHighlightFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessHighlightFormState(form: form)),
    );
  }
}
