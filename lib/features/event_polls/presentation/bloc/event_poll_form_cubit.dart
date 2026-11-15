import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll_draft.dart';
import 'package:arena_soccer/features/event_polls/domain/usecases/manage_event_poll_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

class EventPollFormState extends Equatable {
  /// Card em edição; nulo = evento novo.
  final NewsDTO? editing;
  final EventPollDraft draft;

  /// Capa nova escolhida no aparelho; [coverUrl] = a salva (vazio = sem capa).
  final File? cover;
  final String coverUrl;

  /// Já há votos: as opções ficam travadas.
  final bool locked;
  final bool saving;

  /// Tentou salvar: os erros aparecem.
  final bool submitted;

  /// Salvo (a tela fecha).
  final bool saved;
  final String errorMessage;
  final int errorSeq;

  const EventPollFormState({
    this.editing,
    this.draft = const EventPollDraft(),
    this.cover,
    this.coverUrl = '',
    this.locked = false,
    this.saving = false,
    this.submitted = false,
    this.saved = false,
    this.errorMessage = '',
    this.errorSeq = 0,
  });

  EventPollFormState copyWith({
    NewsDTO? editing,
    EventPollDraft? draft,
    File? cover,
    bool clearCover = false,
    String? coverUrl,
    bool? locked,
    bool? saving,
    bool? submitted,
    bool? saved,
  }) =>
      EventPollFormState(
        editing: editing ?? this.editing,
        draft: draft ?? this.draft,
        cover: clearCover ? null : cover ?? this.cover,
        coverUrl: clearCover ? '' : coverUrl ?? this.coverUrl,
        locked: locked ?? this.locked,
        saving: saving ?? this.saving,
        submitted: submitted ?? this.submitted,
        saved: saved ?? this.saved,
        errorMessage: errorMessage,
        errorSeq: errorSeq,
      );

  EventPollFormState withError(String message) => EventPollFormState(
        editing: editing,
        draft: draft,
        cover: cover,
        coverUrl: coverUrl,
        locked: locked,
        submitted: submitted,
        errorMessage: message,
        errorSeq: errorSeq + 1,
      );

  @override
  List<Object?> get props =>
      [editing, draft, cover?.path, coverUrl, locked, saving, submitted, saved, errorMessage, errorSeq];
}

/// Formulário do evento de votação (admin): cria ou edita; com votos, as
/// opções travam.
class EventPollFormCubit extends Cubit<EventPollFormState> {
  final ManageEventPollUseCase manageEventPollUseCase;
  final DateTime Function() now;

  EventPollFormCubit(this.manageEventPollUseCase, {DateTime Function()? now})
      : now = now ?? DateTime.now,
        super(const EventPollFormState());

  Future<void> start({NewsDTO? editing, required String region}) async {
    if (editing == null) {
      emit(EventPollFormState(draft: EventPollDraft.blank(region: region, now: now())));
      return;
    }
    emit(EventPollFormState(editing: editing, draft: EventPollDraft.of(editing), coverUrl: editing.imageUrl));
    final votes = await manageEventPollUseCase.hasVotes(editing.id);
    if (isClosed) return;
    // Sem saber (erro), trava: mexer nas opções com votos estragaria a apuração.
    emit(state.copyWith(locked: votes.fold((_) => true, (has) => has)));
  }

  void update(EventPollDraft draft) => emit(state.copyWith(draft: draft));

  void setCover(File? file) => emit(file == null ? state.copyWith(clearCover: true) : state.copyWith(cover: file));

  void addOption() {
    if (state.locked || state.draft.options.length >= EventPoll.maxOptions) return;
    update(state.draft.copyWith(options: [...state.draft.options, EventOptionDraft(id: EventOptionDraft.newId())]));
  }

  void removeOption(String id) {
    if (state.locked || state.draft.options.length <= EventPoll.minOptions) return;
    update(state.draft.copyWith(options: state.draft.options.where((o) => o.id != id).toList()));
  }

  void moveOption(int from, int to) {
    if (state.locked) return;
    final options = [...state.draft.options];
    final item = options.removeAt(from);
    options.insert(to.clamp(0, options.length), item);
    update(state.draft.copyWith(options: options));
  }

  void updateOption(EventOptionDraft option) {
    if (state.locked) return;
    update(state.draft.copyWith(options: [
      for (final current in state.draft.options) current.id == option.id ? option : current,
    ]));
  }

  Future<void> save({required String authorId}) async {
    if (state.saving) return;
    emit(state.copyWith(submitted: true));
    if (state.draft.validate(now(), checkOptions: !state.locked) != null) return;
    emit(state.copyWith(saving: true));
    final card = state.draft.toNews(base: state.editing, authorId: authorId, imageUrl: state.coverUrl);
    final editing = state.editing;
    final response = editing == null
        ? (await manageEventPollUseCase.create(card, cover: state.cover, optionPhotos: state.draft.optionPhotos))
            .map((_) {})
        : await manageEventPollUseCase.update(
            card,
            withOptions: !state.locked,
            cover: state.cover,
            optionPhotos: state.draft.optionPhotos,
          );
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false).withError(failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }
}
