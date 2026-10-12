import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';

const _existing = [
  HighlightDTO(id: '1', title: 'Seleção Floresta', isVisible: true, priority: '1'),
  HighlightDTO(id: '2', title: 'Bastidores', priority: '1'),
];

class _FakeRepository implements IHighlightsRepository {
  final created = <HighlightDTO>[];

  @override
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() async => const Right(_existing);

  @override
  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight) async {
    created.add(highlight);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights() => const Stream.empty();
}

class _FakeStorage implements StorageUploadService {
  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async =>
      const Right('https://img/h.png');
}

void main() {
  group('HighlightFormData', () {
    test('título: obrigatório, curto e duplicado (sem acento/caixa)', () {
      const form = HighlightFormData(existing: _existing);
      expect(form.titleError, HighlightTitleError.required);
      expect(form.copyWith(title: 'Oi').titleError, HighlightTitleError.tooShort);
      expect(form.copyWith(title: '  selecao FLORESTA ').titleError, HighlightTitleError.duplicate);
      expect(form.copyWith(title: 'Copa 2023').canSubmit, isTrue);
    });

    test('link opcional, normalizado e validado', () {
      const form = HighlightFormData(title: 'Copa 2023');
      expect(form.copyWith(link: 'abc').canSubmit, isFalse);
      expect(form.copyWith(link: 'instagram.com/arena').toHighlight().link, 'https://instagram.com/arena');
      expect(form.toHighlight().link, '');
    });

    test('nasce visível; isDirty com título, link ou foto', () {
      const form = HighlightFormData();
      expect(form.isVisible, isTrue);
      expect(form.isDirty, isFalse);
      expect(form.copyWith(title: 'x').isDirty, isTrue);
      expect(form.copyWith(image: File('a.png')).isDirty, isTrue);
      expect(form.copyWith(image: File('a.png')).copyWith(clearImage: true).isDirty, isFalse);
    });
  });

  group('HighlightFormCubit', () {
    late _FakeRepository repository;
    late HighlightFormCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = HighlightFormCubit(
        CreateHighlightUseCase(repository, _FakeStorage()),
        GetHighlightsUseCase(repository),
      );
      await cubit.load();
    });

    test('carrega os existentes e bloqueia duplicado', () async {
      expect(cubit.state.form.existing.length, 2);
      cubit.changeTitle('Bastidores');
      await cubit.submit();
      expect(repository.created, isEmpty);
    });

    test('publica com link normalizado e foto enviada', () async {
      cubit.changeTitle('Copa 2023');
      cubit.changeLink('arena.com.br');
      cubit.setImage(File('foto.png'));
      await cubit.submit();
      expect(cubit.state, isA<SuccessHighlightFormState>());
      final saved = repository.created.single;
      expect([saved.title, saved.link, saved.imageUrl, saved.isVisible],
          ['Copa 2023', 'https://arena.com.br', 'https://img/h.png', true]);
    });
  });
}
