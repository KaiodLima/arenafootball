import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Publica uma notícia (ou card de gol/anúncio): envia a capa e as fotos do
/// álbum para o Storage e grava o documento.
class CreateNewsUseCase {
  final INewsRepository _repository;
  final StorageUploadService _storage;

  CreateNewsUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call({
    required NewsDTO news,
    File? cover,
    List<File> album = const [],
  }) async {
    String imageUrl = news.imageUrl;
    if (cover != null) {
      final upload = await _storage.uploadImage(file: cover, folder: StorageFolder.news);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }

    final images = <String>[];
    for (final photo in album) {
      final upload = await _storage.uploadImage(
        file: photo,
        folder: StorageFolder.news,
        fileName: 'album_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (upload.isLeft) return Left(upload.left);
      images.add(upload.right);
    }

    // Sem capa, a primeira foto do álbum vira a imagem do card.
    if (imageUrl.isEmpty && images.isNotEmpty) imageUrl = images.first;

    return _repository.createNews(news.copyWith(imageUrl: imageUrl, images: images));
  }
}
