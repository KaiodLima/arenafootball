import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';

/// Tira o "print" da arte no tamanho final exato do formato: a arte é
/// desenhada no tamanho lógico (a prévia só a reduz) e capturada com
/// `pixelRatio` = largura final ÷ largura lógica. A imagem é liberada logo
/// depois de virar PNG.
class ArtExporter {
  const ArtExporter._();

  static Future<Uint8List?> capture(GlobalKey key, ArtFormat format) async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || boundary.size.width <= 0) return null;
    final image = await boundary.toImage(pixelRatio: format.width / boundary.size.width);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
