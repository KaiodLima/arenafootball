import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/repositories/event_polls_repository_interface.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Lado do admin: cria/edita o evento, enviando a capa e as fotos novas das
/// opções (pasta `noticias/`, compressão do `StorageUploadService`).
class ManageEventPollUseCase {
  final IEventPollsRepository _repository;
  final StorageUploadService _storage;

  ManageEventPollUseCase(this._repository, this._storage);

  Future<Either<Failure, bool>> hasVotes(String eventId) => _repository.hasVotes(eventId);

  /// Envia a capa e as fotos das opções ([optionPhotos], por id da opção) e
  /// devolve o card com as URLs.
  Future<Either<Failure, NewsDTO>> _withUploads(NewsDTO card, File? cover, Map<String, File> optionPhotos) async {
    var imageUrl = card.imageUrl;
    if (cover != null) {
      final upload = await _storage.uploadImage(file: cover, folder: StorageFolder.news);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    final event = card.event ?? const EventPoll();
    final options = <EventPollOption>[];
    for (final option in event.options) {
      final photo = optionPhotos[option.id];
      if (photo == null) {
        options.add(option);
        continue;
      }
      final upload = await _storage.uploadImage(
        file: photo,
        folder: StorageFolder.news,
        fileName: 'evento_${option.id}_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (upload.isLeft) return Left(upload.left);
      options.add(option.copyWith(imageUrl: upload.right));
    }
    return Right(card.copyWith(imageUrl: imageUrl, event: event.copyWith(options: options)));
  }

  Future<Either<Failure, String>> create(NewsDTO card, {File? cover, Map<String, File> optionPhotos = const {}}) async {
    final ready = await _withUploads(card, cover, optionPhotos);
    if (ready.isLeft) return Left(ready.left);
    return _repository.create(ready.right);
  }

  /// [withOptions] falso quando já há votos: as opções não mudam.
  Future<Either<Failure, void>> update(
    NewsDTO card, {
    required bool withOptions,
    File? cover,
    Map<String, File> optionPhotos = const {},
  }) async {
    final ready = await _withUploads(card, cover, withOptions ? optionPhotos : const {});
    if (ready.isLeft) return Left(ready.left);
    return _repository.update(ready.right, withOptions: withOptions);
  }
}
