import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';

class _FakeStorage implements StorageUploadService {
  int uploads = 0;

  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async {
    uploads++;
    return Right('https://storage/${file.path}');
  }
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
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) async => const Right([]);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region}) => const Stream.empty();

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag) => const Stream.empty();
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
}
