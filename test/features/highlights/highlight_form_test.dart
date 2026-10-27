import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/domain/usecases/pending_news_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_pending_partner_requests_count_usecase.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_cached_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_cache_first_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/save_highlights_cache_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/reorder_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/set_highlight_visible_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_form_state.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_cubit.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/manage_highlights_state.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_cubit.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_pending_player_requests_count_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_pending_team_requests_count_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';

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

  /// Cache local em memória (o real é o Hive).
  CachedValue<List<HighlightDTO>>? cached;
  List<HighlightDTO> remote = _existing;
  int remoteCalls = 0;

  @override
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() async {
    remoteCalls++;
    return Right(remote);
  }

  @override
  Future<Either<Failure, CachedValue<List<HighlightDTO>>?>> getCachedHighlights() async => Right(cached);

  @override
  Future<Either<Failure, void>> saveHighlightsCache(List<HighlightDTO> highlights) async {
    cached = CachedValue(highlights, DateTime.now());
    return const Right(null);
  }

  @override
  Future<void> deleteHighlightsCache() async => cached = null;

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
  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle, String? newsAuthorId}) async {
    updated.add('${highlight.id}:${highlight.title}<-$oldTitle');
    return _result;
  }

  @override
  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight, {String? newsAuthorId}) async {
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GetHighlightsCacheFirstUseCase _cacheFirst(_FakeRepository repository) => GetHighlightsCacheFirstUseCase(
      GetHighlightsUseCase(repository),
      GetCachedHighlightsUseCase(repository),
      SaveHighlightsCacheUseCase(repository),
    );

HighlightFormCubit _formCubit(_FakeRepository repository) => HighlightFormCubit(
      CreateHighlightUseCase(repository, _FakeStorage()),
      _cacheFirst(repository),
      UpdateHighlightUseCase(repository, _FakeStorage()),
      _UnusedSlots(),
    );

class _UnusedTeam implements GetTeamByNameCacheFirstUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPlayerRequests implements WatchPendingPlayerRequestsCountUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedTeamRequests implements WatchPendingTeamRequestsCountUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPartnerRequests implements WatchPendingPartnerRequestsCountUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPendingNews implements PendingNewsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedSlots implements GetPartnerSlotsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  group('cache local', () {
    test('formulário: mostra o cache e confere no Firestore (force, para o duplicado)', () async {
      final repository = _FakeRepository()..cached = CachedValue([_existing.first], DateTime.now());
      final cubit = _formCubit(repository);
      final seen = <int>[];
      final sub = cubit.stream.listen((s) => seen.add(s.form.existing.length));
      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      expect(seen, [1, 3]);
      expect(repository.remoteCalls, 1);
      expect(repository.cached!.data, _existing);
      await sub.cancel();
      await cubit.close();
    });

    test('deep link: cache válido não lê o Firestore; vencido, revalida', () async {
      final repository = _FakeRepository()..cached = CachedValue(_existing, DateTime.now());
      final home = HomeCubit(
        _UnusedTeam(),
        _UnusedPlayerRequests(),
        _UnusedTeamRequests(),
        _cacheFirst(repository),
        _UnusedPartnerRequests(),
        _UnusedPendingNews(),
      );
      expect((await home.findHighlight('3')).right?.title, 'Copa');
      expect(repository.remoteCalls, 0);

      // Vencido (validade de 15 min): mostra o cache e busca de novo.
      repository
        ..cached = CachedValue(_existing, DateTime.now().subtract(const Duration(hours: 1)))
        ..remote = [_existing.first];
      expect((await home.findHighlight('1')).right?.title, 'Seleção Floresta');
      expect(repository.remoteCalls, 1);

      // Destaque novo, ainda fora do cache válido: busca de novo (force).
      repository.remote = [..._existing, const HighlightDTO(id: '9', title: 'Novo')];
      expect((await home.findHighlight('9')).right?.title, 'Novo');
      expect(repository.remoteCalls, 2);
      await home.close();
    });

    test('gravar um destaque apaga o cache', () async {
      final repository = _FakeRepository()..cached = CachedValue(_existing, DateTime.now());
      await repository.deleteHighlightsCache();
      expect(repository.cached, isNull);
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
