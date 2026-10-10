import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Atualiza um jogador (nome, gols, assistências) e, com [image], envia a
/// nova foto para `jogadores/` antes de gravar. Devolve o jogador gravado.
class UpdatePlayerUseCase {
  final IPlayersRepository _repository;
  final StorageUploadService _storage;

  UpdatePlayerUseCase(this._repository, this._storage);

  Future<Either<Failure, PlayerDTO>> call({required PlayerDTO player, File? image, String? season}) async {
    var updated = player;
    if (image != null) {
      final upload = await _storage.uploadImage(file: image, folder: StorageFolder.players);
      if (upload.isLeft) return Left(upload.left);
      updated = updated.copyWith(imageUrl: upload.right);
    }
    final response = await _repository.updatePlayer(updated, season: season);
    return response.map((_) => updated);
  }
}
