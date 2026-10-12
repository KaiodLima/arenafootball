import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/reorder_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/set_highlight_visible_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_state.dart';

const _existing = [
  HighlightDTO(id: '1', title: 'Seleção Floresta', isVisible: true, priority: '000'),
  HighlightDTO(id: '2', title: 'Bastidores', priority: '001'),
  HighlightDTO(id: '3', title: 'Copa', isVisible: true, priority: '002'),
];

class _FakeRepository implements IHighlightsRepository {
  final created = <HighlightDTO>[];
  final updated = <String>[];
  final deleted = <String>[];
  final visibility = <String>[];
  List<String>? order;
  bool fail = false;

  Either<Failure, void> get _result => fail ? Left(ErrorWithMessage('erro')) : const Right(null);

  @override
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() async => const Right(_existing);

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchAllHighlights() => Stream.value(const Right(_existing));

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights() => const Stream.empty();

  @override
  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight) async {
    created.add(highlight);
    return _result;
  }

  @override
  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle}) async {
    updated.add('${highlight.id}:${highlight.title}<-$oldTitle');
    return _result;
  }

  @override
  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight) async {
    deleted.add(highlight.id);
    return _result;
  }

  @override
  Future<Either<Failure, void>> reorderHighlights(List<String> ids) async {
    order = ids;
    return _result;
  }

  @override
  Future<Either<Failure, void>> setHighlightVisible({required String id, required bool visible}) async {
    visibility.add('$id:$visible');
    return _result;
  }
}

class _FakeStorage implements StorageUploadService {
  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async =>
      const Right('https://img/h.png');
}

HighlightFormCubit _formCubit(_FakeRepository repository) => HighlightFormCubit(
      CreateHighlightUseCase(repository, _FakeStorage()),
      GetHighlightsUseCase(repository),
      UpdateHighlightUseCase(repository, _FakeStorage()),
    );

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

    test('edição: duplicado ignora a si mesmo; isDirty contra o original; renomear', () {
      final form = HighlightFormData.editing(_existing[0]).copyWith(existing: _existing);
      expect(form.titleError, isNull);
      expect(form.isDirty, isFalse);
      expect(form.isRenamed, isFalse);
      expect(form.copyWith(title: 'Bastidores').titleError, HighlightTitleError.duplicate);
      expect(form.copyWith(title: 'Seleção 2023').isRenamed, isTrue);
      expect(form.copyWith(isVisible: false).isDirty, isTrue);
      // Remover a foto salva grava sem imagem.
      expect(form.copyWith(imageRemoved: true).toHighlight().imageUrl, '');
    });
  });

  group('HighlightFormCubit', () {
    late _FakeRepository repository;
    late HighlightFormCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = _formCubit(repository);
      await cubit.load();
    });

    test('carrega os existentes e bloqueia duplicado', () async {
      expect(cubit.state.form.existing.length, 3);
      cubit.changeTitle('Bastidores');
      await cubit.submit();
      expect(repository.created, isEmpty);
    });

    test('publica no fim do carrossel, com link normalizado e foto enviada', () async {
      cubit.changeTitle('Copa 2023');
      cubit.changeLink('arena.com.br');
      cubit.setImage(File('foto.png'));
      await cubit.submit();
      expect(cubit.state, isA<SuccessHighlightFormState>());
      final saved = repository.created.single;
      expect([saved.title, saved.link, saved.imageUrl, saved.isVisible, saved.priority],
          ['Copa 2023', 'https://arena.com.br', 'https://img/h.png', true, '003']);
    });

    test('edição salva pelo update com o título antigo', () async {
      final editing = _formCubit(repository);
      await editing.load(highlight: _existing[0]);
      editing.changeTitle('Seleção 2023');
      await editing.submit();
      expect(repository.updated, ['1:Seleção 2023<-Seleção Floresta']);
      expect(repository.created, isEmpty);
    });
  });

  group('ManageHighlightsCubit', () {
    late _FakeRepository repository;
    late ManageHighlightsCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = ManageHighlightsCubit(
        WatchAllHighlightsUseCase(repository),
        ReorderHighlightsUseCase(repository),
        SetHighlightVisibleUseCase(repository),
        DeleteHighlightUseCase(repository),
      )..watch();
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() => cubit.close());

    test('arrastar o 1º para o fim grava a ordem nova', () async {
      await cubit.reorder(0, 3);
      expect(repository.order, ['2', '3', '1']);
      expect(cubit.state.highlights.map((h) => h.priority), ['000', '001', '002']);
    });

    test('falha ao reordenar volta a lista', () async {
      repository.fail = true;
      await cubit.reorder(2, 0);
      expect(cubit.state, isA<ErrorManageHighlightsState>());
      expect(cubit.state.highlights.map((h) => h.id), ['1', '2', '3']);
    });

    test('mostrar/ocultar e excluir', () async {
      await cubit.toggleVisible(_existing[1], true);
      expect(repository.visibility, ['2:true']);
      expect(cubit.state.highlights[1].isVisible, isTrue);

      await cubit.delete(_existing[0]);
      expect(repository.deleted, ['1']);
      expect(cubit.state, isA<DeletedManageHighlightsState>());
      expect(cubit.state.highlights.map((h) => h.id), ['2', '3']);
    });
  });

  test('ordem do carrossel por priority numérica; sem priority vai para o fim', () {
    const list = [
      HighlightDTO(id: 'a', priority: '10'),
      HighlightDTO(id: 'b'),
      HighlightDTO(id: 'c', priority: '2'),
    ];
    expect(sortHighlightsByPriority(list).map((h) => h.id), ['c', 'a', 'b']);
  });
}
