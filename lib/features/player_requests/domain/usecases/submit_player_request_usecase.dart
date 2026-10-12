import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';

/// Envia (ou reenvia) o pedido "Sou jogador". Com [photo], sobe a foto para
/// `jogadores/` antes (ela vira a foto do jogador se o pedido for aprovado);
/// sem ela, mantém a [PlayerRequestDTO.imageUrl] que já estava no pedido.
class SubmitPlayerRequestUseCase {
  final IPlayerRequestsRepository _repository;
  final StorageUploadService _storage;

  SubmitPlayerRequestUseCase(this._repository, this._storage);

  Future<Either<Failure, void>> call(PlayerRequestDTO request, {File? photo}) async {
    var imageUrl = request.imageUrl;
    if (photo != null) {
      final upload = await _storage.uploadImage(file: photo, folder: StorageFolder.players);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    return _repository.submit(
      request.copyWith(name: request.name.trim(), message: request.message.trim(), imageUrl: imageUrl),
    );
  }
}
