import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// O atleta troca a própria foto: envia a imagem para `jogadores/` e grava só
/// o campo `urlImagem` (as regras não deixam o atleta mexer em mais nada).
/// Devolve o jogador com a foto nova.
class UpdatePlayerPhotoUseCase {
  final IPlayersRepository _repository;
  final StorageUploadService _storage;

  UpdatePlayerPhotoUseCase(this._repository, this._storage);

  Future<Either<Failure, PlayerDTO>> call({required PlayerDTO player, required File image, String? season}) async {
    final upload = await _storage.uploadImage(file: image, folder: StorageFolder.players);
    if (upload.isLeft) return Left(upload.left);
    final response = await _repository.updatePlayerPhoto(id: player.id, url: upload.right, season: season);
    return response.map((_) => player.copyWith(imageUrl: upload.right));
  }
}
