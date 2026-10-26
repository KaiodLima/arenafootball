import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';

void main() {
  test('tipo da imagem pela extensão; sem extensão, jpeg', () {
    expect(imageContentType('/data/cache/foto.jpg'), (contentType: 'image/jpeg', extension: 'jpg'));
    expect(imageContentType('/data/cache/foto.JPEG'), (contentType: 'image/jpeg', extension: 'jpg'));
    expect(imageContentType('/data/cache/escudo.PNG'), (contentType: 'image/png', extension: 'png'));
    expect(imageContentType('/var/mobile/IMG_1.heic'), (contentType: 'image/heic', extension: 'heic'));
    expect(imageContentType('/data/cache/image_cropper_123'), (contentType: 'image/jpeg', extension: 'jpg'));
    // Ponto só no nome da pasta não conta como extensão.
    expect(imageContentType('/data/app.cache/foto'), (contentType: 'image/jpeg', extension: 'jpg'));
  });

  test('perfil por pasta: foto, escudo (PNG) e capa; pasta desconhecida = capa', () {
    expect(ImageUploadProfile.forFolder(StorageFolder.users).size, 600);
    expect(ImageUploadProfile.forFolder(StorageFolder.players).size, 600);
    final crest = ImageUploadProfile.forFolder(StorageFolder.teams);
    expect(crest.png, isTrue);
    expect(crest.contentType, 'image/png');
    expect(ImageUploadProfile.forFolder(StorageFolder.news).size, 1280);
    expect(ImageUploadProfile.forFolder('outra'), ImageUploadProfile.cover);
  });

  test('envia o comprimido quando ficou menor; senão, o original', () {
    final original = Uint8List(1000);
    final smaller = Uint8List(100);
    final chosen = chooseUploadBytes(
      original: original,
      compressed: smaller,
      profile: ImageUploadProfile.crest,
      path: '/x/escudo.jpg',
    );
    expect(chosen.bytes, smaller);
    expect(chosen.contentType, 'image/png');
    expect(chosen.extension, 'png');

    // Compressão falhou (nulo) ou saiu maior: original com o tipo do arquivo.
    for (final compressed in [null, Uint8List(2000)]) {
      final fallback = chooseUploadBytes(
        original: original,
        compressed: compressed,
        profile: ImageUploadProfile.photo,
        path: '/x/foto.png',
      );
      expect(fallback.bytes, original);
      expect(fallback.contentType, 'image/png');
    }
  });
}
