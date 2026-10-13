import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';

/// Troca a foto da conta: envia para `usuarios/` e grava a URL no perfil.
/// Devolve a URL nova.
class UpdateUserPhotoUseCase {
  final IAuthRepository _repository;
  final StorageUploadService _storage;

  UpdateUserPhotoUseCase(this._repository, this._storage);

  Future<Either<Failure, String>> call({required String userId, required File photo}) async {
    final upload = await _storage.uploadImage(file: photo, folder: StorageFolder.users);
    if (upload.isLeft) return Left(upload.left);
    final response = await _repository.updatePhoto(userId: userId, photoUrl: upload.right);
    return response.map((_) => upload.right);
  }
}
