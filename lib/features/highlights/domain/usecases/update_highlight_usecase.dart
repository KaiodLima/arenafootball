import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Atualiza um destaque: com [image], envia a foto nova antes de gravar.
/// Renomeado, as notícias do título antigo ([oldTitle]) vão junto.
class UpdateHighlightUseCase {
  final IHighlightsRepository _repository;
  final StorageUploadService _storage;

  UpdateHighlightUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call({required HighlightDTO highlight, String? oldTitle, File? image}) async {
    var updated = highlight;
    if (image != null) {
      final upload = await _storage.uploadImage(file: image, folder: StorageFolder.highlights);
      if (upload.isLeft) return Left(upload.left);
      updated = updated.copyWith(imageUrl: upload.right);
    }
    return _repository.updateHighlight(updated, oldTitle: oldTitle);
  }
}
