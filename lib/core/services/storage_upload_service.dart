import 'dart:io';
import 'dart:typed_data';

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

  /// Foto da conta (carteirinha de torcedor).
  static const String users = 'usuarios';

  /// Banner e regulamento (PDF) dos campeonatos.
  static const String championships = 'campeonatos';
}

/// Upload de imagens e documentos para o Firebase Storage. Devolve a URL
/// pública do arquivo enviado.
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

  /// Envia bytes com o tipo informado (ex.: `application/pdf`). Usado para
  /// documentos escolhidos no aparelho, que no Android nem sempre têm caminho.
  Future<Either<Failure, String>> uploadData({
    required Uint8List bytes,
    required String folder,
    required String contentType,
    String extension = '',
  }) async {
    const fallback = 'Não foi possível enviar o arquivo.';
    final name = '${DateTime.now().millisecondsSinceEpoch}${extension.isEmpty ? '' : '.$extension'}';
    try {
      final result = await _storage.ref('$folder/$name').putData(bytes, SettableMetadata(contentType: contentType));
      final url = await result.ref.getDownloadURL();
      return Right(url);
    } catch (e) {
      AppLogger.e('uploadData folder=$folder', name: 'StorageUploadService', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }
}
