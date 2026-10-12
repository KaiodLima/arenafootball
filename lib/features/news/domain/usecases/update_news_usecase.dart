import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Atualiza uma notícia existente. Se houver [cover] nova, ela substitui a
/// imagem atual; as fotos novas de [album] são enviadas e somadas às que
/// ficaram em `news.images`. Sem capa, a primeira foto do álbum vira a capa
/// (mesma regra da criação).
class UpdateNewsUseCase {
  final INewsRepository _repository;
  final StorageUploadService _storage;

  UpdateNewsUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call({required NewsDTO news, File? cover, List<File> album = const []}) async {
    String imageUrl = news.imageUrl;
    if (cover != null) {
      final upload = await _storage.uploadImage(file: cover, folder: StorageFolder.news);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }

    final images = [...news.images];
    for (final photo in album) {
      final upload = await _storage.uploadImage(
        file: photo,
        folder: StorageFolder.news,
        fileName: 'album_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (upload.isLeft) return Left(upload.left);
      images.add(upload.right);
    }

    if (imageUrl.isEmpty && images.isNotEmpty) imageUrl = images.first;

    return _repository.updateNews(news.copyWith(imageUrl: imageUrl, images: images));
  }
}
