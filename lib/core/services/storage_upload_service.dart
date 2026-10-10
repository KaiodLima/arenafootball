import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Pastas do Firebase Storage usadas pelo app.
class StorageFolder {
  static const String news = 'noticias';
  static const String highlights = 'destaques';
  static const String teams = 'times';
  static const String players = 'jogadores';
}

/// Upload de imagens para o Firebase Storage. Devolve a URL pública do
/// arquivo enviado.
class StorageUploadService {
  final FirebaseStorage _storage;

  StorageUploadService(this._storage);

  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    const fallback = 'Não foi possível enviar a imagem.';
    final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final result = await _storage.ref('$folder/$name').putFile(file);
      final url = await result.ref.getDownloadURL();
      return Right(url);
    } catch (e) {
      AppLogger.e('uploadImage folder=$folder', name: 'StorageUploadService', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }
}
