import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Cadastra um jogador. Como no app antigo, sempre na temporada corrente
/// (coleção `jogadores` sem sufixo). Com [photo], envia a foto para
/// `jogadores/` antes de gravar; sem ela, a foto pode ser enviada depois pela
/// tela do elenco.
class CreatePlayerUseCase {
  final IPlayersRepository _repository;
  final StorageUploadService _storage;

  CreatePlayerUseCase(this._repository, this._storage);

  Future<Either<Failure, PlayerDTO>> call(PlayerDTO player, {File? photo}) async {
    var imageUrl = '';
    if (photo != null) {
      final upload = await _storage.uploadImage(file: photo, folder: StorageFolder.players);
      if (upload.isLeft) return Left(upload.left);
      imageUrl = upload.right;
    }
    final created = player.copyWith(name: player.name.trim(), imageUrl: imageUrl);
    final response = await _repository.createPlayer(created);
    return response.map((_) => created);
  }
}
