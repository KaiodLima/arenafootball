import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_highlights_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';

class _FakeStorage implements StorageUploadService {
  int uploads = 0;

  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async {
    uploads++;
    return Right('https://storage/${file.path}');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepository implements INewsRepository {
  NewsDTO? updated;

  @override
  Future<Either<Failure, void>> updateNews(NewsDTO news) async {
    updated = news;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> createNews(NewsDTO news) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteNews(String id) async => const Right(null);

  @override
  Future<Either<Failure, NewsDTO?>> getNewsById(String id) async => const Right(null);

  @override
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) async => const Right([]);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20}) => const Stream.empty();

  @override
  Future<Either<Failure, List<NewsDTO>>> getNewsPage(
          {String? region, required String afterNewsId, int limit = 20}) async =>
      const Right([]);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _saved = NewsDTO(
  id: 'n1',
  title: 'Final do campeonato',
  description: 'Texto',
  imageUrl: 'https://img/capa.jpg',
  region: 'Floresta',
  images: ['https://img/a.jpg', 'https://img/b.jpg'],
);

NewsFormData _editing() => const NewsFormData(
      original: _saved,
      title: 'Final do campeonato',
      description: 'Texto',
      selectedRegion: 'Floresta',
      keptImages: ['https://img/a.jpg', 'https://img/b.jpg'],
    );

void main() {
  group('NewsFormData', () {
    test('criação vazia não está "suja"; com título passa a estar', () {
      expect(const NewsFormData().isDirty, isFalse);
      expect(const NewsFormData(title: 'Oi').isDirty, isTrue);
      expect(NewsFormData(album: [File('x.jpg')]).isDirty, isTrue);
    });

    test('edição sem mudanças não está "suja"', () {
      final form = _editing();
      expect(form.isDirty, isFalse);
      expect(form.copyWith(tag: 'Açaí no gralle').isDirty, isTrue);
      expect(form.copyWith(keptImages: ['https://img/a.jpg']).isDirty, isTrue);
      expect(form.copyWith(clearCover: true, coverRemoved: true).isDirty, isTrue);
    });

    test('toNews leva o destaque, as fotos mantidas e a capa atual', () {
      final news = _editing().copyWith(tag: 'Açaí no gralle', keptImages: ['https://img/b.jpg']).toNews();
      expect(news.tag, 'Açaí no gralle');
      expect(news.images, ['https://img/b.jpg']);
      expect(news.imageUrl, 'https://img/capa.jpg');
    });

    test('capa removida some do toNews; capa nova esconde a atual', () {
      final removed = _editing().copyWith(clearCover: true, coverRemoved: true);
      expect(removed.toNews().imageUrl, isEmpty);
      expect(removed.hasCover, isFalse);

      final replaced = _editing().copyWith(cover: File('nova.jpg'), coverRemoved: false);
      expect(replaced.currentCoverUrl, isEmpty);
      expect(replaced.hasCover, isTrue);
    });

    test('título: obrigatório, curto avisa, anúncio dispensa', () {
      expect(const NewsFormData().titleError, NewsTitleError.required);
      expect(const NewsFormData(title: 'Oi').titleError, NewsTitleError.tooShort);
      expect(const NewsFormData(title: 'Oi', selectedRegion: 'F').canSubmit, isTrue);
      expect(const NewsFormData(tag: NewsDTO.adTag).titleError, isNull);
    });

    test('anúncio: exige banner e link válido (se houver)', () {
      const ad = NewsFormData(tag: NewsDTO.adTag, selectedRegion: 'F');
      expect(ad.canSubmit, isFalse);
      final withBanner = ad.copyWith(cover: File('banner.jpg'));
      expect(withBanner.canSubmit, isTrue);
      expect(withBanner.copyWith(link: 'abc').canSubmit, isFalse);
      expect(withBanner.copyWith(link: 'loja.com.br').canSubmit, isTrue);
      // Edição: o banner já salvo vale.
      const saved = NewsFormData(
        tag: NewsDTO.adTag,
        selectedRegion: 'F',
        original: NewsDTO(id: 'a1', tag: NewsDTO.adTag, imageUrl: 'https://img/a.png'),
      );
      expect(saved.canSubmit, isTrue);
    });

    test('link sem esquema ganha https:// ao gravar', () {
      expect(const NewsFormData(link: ' loja.com.br ').toNews().link, 'https://loja.com.br');
      expect(const NewsFormData(link: 'http://x.com').toNews().link, 'http://x.com');
      expect(const NewsFormData().toNews().link, '');
    });
  });

  group('UpdateNewsUseCase', () {
    test('mantém as fotos salvas e soma as novas', () async {
      final storage = _FakeStorage();
      final repository = _FakeRepository();

      await UpdateNewsUseCase(repository, storage)(
        news: _editing().copyWith(keptImages: ['https://img/a.jpg']).toNews(),
        album: [File('c.jpg'), File('d.jpg')],
      );

      expect(storage.uploads, 2);
      expect(repository.updated!.images, ['https://img/a.jpg', 'https://storage/c.jpg', 'https://storage/d.jpg']);
      expect(repository.updated!.imageUrl, 'https://img/capa.jpg');
    });

    test('sem capa, a primeira foto do álbum vira a capa', () async {
      final repository = _FakeRepository();

      await UpdateNewsUseCase(repository, _FakeStorage())(
        news: _editing().copyWith(clearCover: true, coverRemoved: true).toNews(),
      );

      expect(repository.updated!.imageUrl, 'https://img/a.jpg');
    });

    test('capa nova é enviada e substitui a atual', () async {
      final repository = _FakeRepository();

      await UpdateNewsUseCase(repository, _FakeStorage())(news: _editing().toNews(), cover: File('nova.jpg'));

      expect(repository.updated!.imageUrl, 'https://storage/nova.jpg');
    });
  });

  test('nova notícia aberta pelo destaque já vem marcada com ele', () async {
    final repository = _FakeRepository();
    final cubit = NewsFormCubit(
      CreateNewsUseCase(repository, _FakeStorage()),
      UpdateNewsUseCase(repository, _FakeStorage()),
      _FakeRegions(),
      _FakeHighlights(),
    );
    await cubit.load(initialRegion: 'Floresta', tag: 'Seleção Floresta');
    expect(cubit.state.form.tag, 'Seleção Floresta');
    expect(cubit.state.form.isEditing, isFalse);
    await cubit.close();
  });
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta']);
}

class _FakeHighlights implements WatchHighlightsUseCase {
  @override
  Stream<Either<Failure, List<HighlightDTO>>> call() =>
      Stream.value(const Right([HighlightDTO(id: '1', title: 'Seleção Floresta', isVisible: true)]));
}
