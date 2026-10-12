import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/reorder_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/set_highlight_visible_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_state.dart';

/// Painel do admin: todos os destaques em tempo real, com reordenação,
/// mostrar/ocultar e exclusão. As mudanças aparecem na hora (otimistas) e
/// voltam se a gravação falhar.
class ManageHighlightsCubit extends Cubit<ManageHighlightsState> {
  final WatchAllHighlightsUseCase watchAllHighlightsUseCase;
  final ReorderHighlightsUseCase reorderHighlightsUseCase;
  final SetHighlightVisibleUseCase setHighlightVisibleUseCase;
  final DeleteHighlightUseCase deleteHighlightUseCase;
  StreamSubscription<Either<Failure, List<HighlightDTO>>>? _subscription;

  ManageHighlightsCubit(
    this.watchAllHighlightsUseCase,
    this.reorderHighlightsUseCase,
    this.setHighlightVisibleUseCase,
    this.deleteHighlightUseCase,
  ) : super(const LoadingManageHighlightsState());

  void watch() {
    _subscription?.cancel();
    _subscription = watchAllHighlightsUseCase().listen((response) {
      response.fold(
        (failure) => emit(ErrorManageHighlightsState(errorMessage: failure.toString(), highlights: state.highlights)),
        (highlights) => emit(SuccessManageHighlightsState(highlights: highlights)),
      );
    });
  }

  /// Índices do `ReorderableListView` (o [newIndex] conta o item ainda no
  /// lugar antigo).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final before = state.highlights;
    if (oldIndex < 0 || oldIndex >= before.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex == oldIndex) return;

    final list = [...before];
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), moved);
    final reordered = [
      for (var i = 0; i < list.length; i++) list[i].copyWith(priority: highlightPriorityAt(i)),
    ];
    emit(SuccessManageHighlightsState(highlights: reordered));

    final response = await reorderHighlightsUseCase(reordered.map((h) => h.id).toList());
    if (isClosed || response.isRight) return;
    emit(ErrorManageHighlightsState(errorMessage: response.left.toString(), highlights: before));
  }

  Future<void> toggleVisible(HighlightDTO highlight, bool visible) async {
    final before = state.highlights;
    emit(SuccessManageHighlightsState(
      highlights: [for (final h in before) h.id == highlight.id ? h.copyWith(isVisible: visible) : h],
    ));
    final response = await setHighlightVisibleUseCase(id: highlight.id, visible: visible);
    if (isClosed || response.isRight) return;
    emit(ErrorManageHighlightsState(errorMessage: response.left.toString(), highlights: before));
  }

  Future<void> delete(HighlightDTO highlight) async {
    final before = state.highlights;
    final remaining = before.where((h) => h.id != highlight.id).toList();
    emit(SuccessManageHighlightsState(highlights: remaining));
    final response = await deleteHighlightUseCase(highlight);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorManageHighlightsState(errorMessage: failure.toString(), highlights: before)),
      (_) => emit(DeletedManageHighlightsState(title: highlight.title, highlights: remaining)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
