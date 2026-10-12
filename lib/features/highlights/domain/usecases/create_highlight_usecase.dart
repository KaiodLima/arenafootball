import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Cadastra um destaque: envia a imagem e grava o documento.
class CreateHighlightUseCase {
  final IHighlightsRepository _repository;
  final StorageUploadService _storage;

  CreateHighlightUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call({required HighlightDTO highlight, File? image}) async {
    String imageUrl = highlight.imageUrl;
    if (image != null) {
      final upload = await _storage.uploadImage(file: image, folder: StorageFolder.highlights);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }

    // O novo destaque entra no fim do carrossel.
    final existing = await _repository.getHighlights();
    if (existing.isLeft) return Left(existing.left);
    final numbers = existing.right.map((item) => int.tryParse(item.priority.trim())).whereType<int>();
    final last = numbers.isEmpty ? -1 : numbers.reduce((a, b) => a > b ? a : b);
    final priority = highlightPriorityAt(last + 1);

    return _repository.createHighlight(highlight.copyWith(imageUrl: imageUrl, priority: priority));
  }
}
