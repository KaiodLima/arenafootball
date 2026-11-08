import 'dart:ui';

/// Formato da arte para as redes. A arte é desenhada no tamanho lógico
/// ([logicalSize], px ÷ [pixelRatio]) e exportada no tamanho final exato
/// ([width] × [height]); cada template reorganiza o layout pelo [shape].
enum ArtFormat {
  feed(1080, 1350),
  story(1080, 1920),
  square(1080, 1080),
  landscape(1200, 630);

  final int width;
  final int height;

  const ArtFormat(this.width, this.height);

  /// Escala da exportação (o tamanho lógico é px ÷ 3).
  static const double pixelRatio = 3;

  Size get logicalSize => Size(width / pixelRatio, height / pixelRatio);

  /// Alta (story/feed), quadrada ou deitada (paisagem): o layout muda.
  ArtShape get shape => switch (this) {
        ArtFormat.story || ArtFormat.feed => ArtShape.tall,
        ArtFormat.square => ArtShape.square,
        ArtFormat.landscape => ArtShape.wide,
      };
}

enum ArtShape { tall, square, wide }
