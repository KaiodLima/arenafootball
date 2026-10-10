import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Atualiza uma notícia existente; se houver [cover] nova, ela substitui a
/// imagem atual.
class UpdateNewsUseCase {
  final INewsRepository _repository;
  final StorageUploadService _storage;

  UpdateNewsUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call({required NewsDTO news, File? cover}) async {
    String imageUrl = news.imageUrl;
    if (cover != null) {
      final upload = await _storage.uploadImage(file: cover, folder: StorageFolder.news);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    return _repository.updateNews(news.copyWith(imageUrl: imageUrl));
  }
}
