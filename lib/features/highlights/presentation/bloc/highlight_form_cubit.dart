import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_cache_first_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';

/// Cadastro/edição de destaque: carrega os existentes (prévia e duplicado)
/// e publica ou salva. O parceiro publica na região dele, numa vaga livre
/// (`PartnerSlots`), e renomeia só nas notícias dele.
class HighlightFormCubit extends Cubit<HighlightFormState> {
  final CreateHighlightUseCase createHighlightUseCase;
  final GetHighlightsCacheFirstUseCase getHighlightsCacheFirstUseCase;
  final UpdateHighlightUseCase updateHighlightUseCase;
  final GetPartnerSlotsUseCase getPartnerSlotsUseCase;
  PartnerRequestDTO? _partner;

  HighlightFormCubit(
    this.createHighlightUseCase,
    this.getHighlightsCacheFirstUseCase,
    this.updateHighlightUseCase,
    this.getPartnerSlotsUseCase,
  ) : super(const EditingHighlightFormState());

  void _edit(HighlightFormData form) {
    if (!isClosed) emit(EditingHighlightFormState(form: form));
  }

  /// Falhar só deixa a prévia sem os existentes (e sem checar duplicado).
  /// [partner]: quem publica é o parceiro (não admin).
  Future<void> load({HighlightDTO? highlight, PartnerRequestDTO? partner}) async {
    _partner = partner;
    if (highlight != null) _edit(HighlightFormData.editing(highlight));
    // force: a checagem de duplicado precisa da lista atual (o cache só
    // adianta a prévia enquanto o Firestore responde).
    await for (final response in getHighlightsCacheFirstUseCase(force: true)) {
      if (response.isRight && state is EditingHighlightFormState) {
        _edit(state.form.copyWith(existing: response.right));
      }
    }
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
    final partner = _partner;
    var highlight = form.toHighlight();
    if (original == null && partner != null) {
      final slots = await getPartnerSlotsUseCase(partner);
      if (isClosed) return;
      if (slots.isLeft) {
        emit(ErrorHighlightFormState(form: form, errorMessage: slots.left.toString()));
        return;
      }
      final slot = slots.right.freeHighlight;
      if (slot == null) {
        emit(ErrorHighlightFormState(form: form, errorMessage: '', limitReached: true));
        return;
      }
      highlight = highlight.copyWith(id: slot, region: partner.region, authorId: partner.userId);
    }
    final response = original == null
        ? await createHighlightUseCase(highlight: highlight, image: form.image)
        : await updateHighlightUseCase(
            highlight: highlight,
            oldTitle: original.title,
            image: form.image,
            newsAuthorId: partner?.userId,
          );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorHighlightFormState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessHighlightFormState(form: form)),
    );
  }
}
