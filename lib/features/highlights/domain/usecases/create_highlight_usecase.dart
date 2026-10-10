import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Cadastra um destaque: envia a imagem e grava o documento.
class CreateHighlightUseCase {
  /// Prioridade usada quando ainda não há nenhum destaque cadastrado.
  static const String defaultPriority = '1';

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

    // Como no app antigo: o novo destaque herda a prioridade do primeiro
    // destaque da coleção.
    final existing = await _repository.getHighlights();
    if (existing.isLeft) return Left(existing.left);
    final priorities = existing.right.map((item) => item.priority).where((p) => p.isNotEmpty);
    final priority = priorities.isEmpty ? defaultPriority : priorities.first;

    return _repository.createHighlight(highlight.copyWith(imageUrl: imageUrl, priority: priority));
  }
}
