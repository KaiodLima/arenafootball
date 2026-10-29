import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  /// Fotos das figurinhas do álbum (evento).
  static const String album = 'album';
}

/// Tipo e extensão da imagem pela extensão do arquivo local. Sem extensão
/// conhecida (foto recortada/comprimida), `image/jpeg`. As regras do Storage
/// só aceitam `image/*`: sem o tipo, o envio chega como binário e é negado.
({String contentType, String extension}) imageContentType(String path) {
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf(RegExp(r'[/\\]'));
  final ext = dot > slash ? path.substring(dot + 1).toLowerCase() : '';
  return switch (ext) {
    'png' => (contentType: 'image/png', extension: 'png'),
    'webp' => (contentType: 'image/webp', extension: 'webp'),
    'gif' => (contentType: 'image/gif', extension: 'gif'),
    'heic' || 'heif' => (contentType: 'image/heic', extension: ext),
    _ => (contentType: 'image/jpeg', extension: 'jpg'),
  };
}

/// Como a imagem de cada pasta é otimizada antes do envio: o **menor lado**
/// fica com até [size] px (proporção mantida, nunca amplia) e o formato é
/// JPEG com [quality] ou PNG (escudos, que podem ter fundo transparente).
class ImageUploadProfile {
  final int size;
  final int quality;
  final bool png;

  const ImageUploadProfile({required this.size, this.quality = 80, this.png = false});

  String get contentType => png ? 'image/png' : 'image/jpeg';

  String get extension => png ? 'png' : 'jpg';

  /// Foto de perfil e de atleta.
  static const ImageUploadProfile photo = ImageUploadProfile(size: 600);

  /// Escudo do time.
  static const ImageUploadProfile crest = ImageUploadProfile(size: 512, png: true);

  /// Capa, banner e fotos de notícia/destaque/campeonato (e pasta desconhecida).
  static const ImageUploadProfile cover = ImageUploadProfile(size: 1280);

  static ImageUploadProfile forFolder(String folder) => switch (folder) {
        StorageFolder.users || StorageFolder.players || StorageFolder.album => photo,
        StorageFolder.teams => crest,
        _ => cover,
      };
}

/// Bytes a enviar: o comprimido quando existe e ficou menor que o original;
/// senão o original, com o tipo pela extensão do arquivo local.
({Uint8List bytes, String contentType, String extension}) chooseUploadBytes({
  required Uint8List original,
  required Uint8List? compressed,
  required ImageUploadProfile profile,
  required String path,
}) {
  if (compressed != null && compressed.isNotEmpty && compressed.length < original.length) {
    return (bytes: compressed, contentType: profile.contentType, extension: profile.extension);
  }
  final type = imageContentType(path);
  return (bytes: original, contentType: type.contentType, extension: type.extension);
}

/// Redimensiona/comprime a imagem do caminho [path] pelo [profile]; nulo se não conseguir.
abstract class ImageCompressor {
  Future<Uint8List?> compress(String path, ImageUploadProfile profile);
}

/// Compressão nativa (`flutter_image_compress`): corrige a orientação da
/// câmera e descarta os metadados (EXIF/GPS).
class NativeImageCompressor implements ImageCompressor {
  const NativeImageCompressor();

  @override
  Future<Uint8List?> compress(String path, ImageUploadProfile profile) => FlutterImageCompress.compressWithFile(
        path,
        minWidth: profile.size,
        minHeight: profile.size,
        quality: profile.quality,
        format: profile.png ? CompressFormat.png : CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: true,
      );
}

/// Upload de imagens e documentos para o Firebase Storage. Devolve a URL
/// pública do arquivo enviado.
class StorageUploadService {
  final FirebaseStorage _storage;
  final ImageCompressor _compressor;

  StorageUploadService(this._storage, [this._compressor = const NativeImageCompressor()]);

  /// Arquivos têm nome único (hora do envio) e nunca mudam: o aparelho e o
  /// CDN podem guardar por 1 ano sem baixar de novo.
  static const String cacheControl = 'public, max-age=31536000';

  /// Otimiza a imagem pela pasta ([ImageUploadProfile]) e envia com o tipo
  /// (`image/*`), a extensão no nome e o cache longo. Se a compressão falhar,
  /// envia o original.
  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    const fallback = 'Não foi possível enviar a imagem.';
    try {
      final original = await file.readAsBytes();
      Uint8List? compressed;
      try {
        compressed = await _compressor.compress(file.path, ImageUploadProfile.forFolder(folder));
      } catch (e) {
        AppLogger.e('compress folder=$folder', name: 'StorageUploadService', error: e);
      }
      final upload = chooseUploadBytes(
        original: original,
        compressed: compressed,
        profile: ImageUploadProfile.forFolder(folder),
        path: file.path,
      );
      final name = '${fileName ?? DateTime.now().millisecondsSinceEpoch}.${upload.extension}';
      final result = await _storage.ref('$folder/$name').putData(
            upload.bytes,
            SettableMetadata(contentType: upload.contentType, cacheControl: cacheControl),
          );
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
